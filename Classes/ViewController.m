#import "ViewController.h"

#import "SimpleSound.h"
#import "UIViewQuadBody.h"
#import "BWButton.h"
#import "BWShooter.h"
#import "BWScorePost.h"
#import "BWBumper.h"
#import "Random.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageViewBody2.h"
#import "BWChipmunkLayer.h"
#import "UIViewBody.h"

#define kCountdownTimer 10

static NSString *borderType = @"borderType";

#pragma mark - Collisions

void postStepRemove(cpSpace *space, cpShape *shape, void *unused)
{
    BWScorePost *scorePost = shape->data;
    [scorePost retain];
    [scorePost removeFromSuperview];
    
    cpSpaceRemoveShape(space, shape);
    
    [scorePost release];
}

void postStepRemoveButton(cpSpace *space, cpShape *shape, void *unused) {
    BWButton *button = shape->data;
    [button retain];
    [button removeFromSuperview];
    
    cpSpaceRemoveBody(space, button.chipmunkLayer.body);
    cpSpaceRemoveShape(space, shape);
    
    [button release];
}

int beginCollisionWithButtonAndScorePost(cpArbiter *arbiter, cpSpace *space, void *data) {
    CP_ARBITER_GET_SHAPES(arbiter, a, b);
    BWButton *button = a->data;
    BWScorePost *scorePost = b->data;
    ViewController *viewController = data;
    
    if( button.color == ButtonColorGreen && scorePost.buttonColor != ButtonColorGreen ) {
        viewController.topScore.text = [NSString stringWithFormat:@"%d", [viewController.topScore.text intValue] + 1];

        if( scorePost.buttonColor == ButtonColorOrange ) {
            NSUInteger score = fmaxf([viewController.bottomScore.text intValue] - 1, 0);
            viewController.bottomScore.text = [NSString stringWithFormat:@"%d", score];
        }

    } 
    if( button.color == ButtonColorOrange && scorePost.buttonColor != ButtonColorOrange ) {
        viewController.bottomScore.text = [NSString stringWithFormat:@"%d", [viewController.bottomScore.text intValue] + 1];
        
        if( scorePost.buttonColor == ButtonColorGreen ) {
            NSUInteger score = fmaxf([viewController.topScore.text intValue] - 1, 0);
            viewController.topScore.text = [NSString stringWithFormat:@"%d", score];
        }
    }
    
    scorePost.buttonColor = button.color;
    [viewController checkForWinner];    
    
    return 0;
}

void postSolveCollisionWithButtonAndScorePost(cpArbiter *arbiter, cpSpace *space, void *data) {
    CP_ARBITER_GET_SHAPES(arbiter, a, b);
    BWButton *button = a->data;
    ViewController *viewController = data;
    
    if( button.color == ButtonColorGreen )
        viewController.topScore.text = [NSString stringWithFormat:@"%d", [viewController.topScore.text intValue] + 1];
    else
        viewController.bottomScore.text = [NSString stringWithFormat:@"%d", [viewController.bottomScore.text intValue] + 1];
    
    cpSpaceAddPostStepCallback(space, (cpPostStepFunc)postStepRemove, b, NULL);
}

void postSolveCollisionWithButtonAndShooter(cpArbiter *arbiter, cpSpace *space, void *data) {

    CP_ARBITER_GET_SHAPES(arbiter, a, b);
    BWButton *button = a->data;
    BWShooter *shooter = b->data;
    
    if( button.canDie == YES && button.color == shooter.buttonColor ) {
        shooter.activeButtonCount--;
        cpSpaceAddPostStepCallback(space, (cpPostStepFunc)postStepRemoveButton, a, NULL);
    }
}

void postSolveCollisionWithButtonAndBumper(cpArbiter *arbiter, cpSpace *space, void *data) {
    CP_ARBITER_GET_SHAPES(arbiter, a, b);
    BWBumper *bumper = b->data;
    BWButton *button = a->data;
    ViewController *viewController = data;
     

    cpVect collisionVector = cpvnormalize(cpvsub(cpBodyGetPos(bumper.chipmunkLayer.body), cpBodyGetPos(button.chipmunkLayer.body)));
    cpVect invertedCollisionVector = cpvrotate(collisionVector, cpvforangle(M_PI));
    cpVect impulseVector = cpvmult(invertedCollisionVector, 500);
    cpVect bounceVector = cpvmult(invertedCollisionVector, 10);
    
    // bounce button away
    cpBodyApplyImpulse(button.chipmunkLayer.body, impulseVector, cpvzero);
    
    
    
    if( bumper.isBumping == YES )
        return;

    // bounce the bumper if it's not bumping
    bumper.isBumping = YES;
    cpVect jumpPosition = cpvadd(cpBodyGetPos(bumper.chipmunkLayer.body), bounceVector);
    cpVect resetPosition = cpBodyGetPos(bumper.chipmunkLayer.body);
    cpBodySetPos(bumper.chipmunkLayer.body, jumpPosition);
    NSArray *parameters = [NSArray arrayWithObjects:bumper, [NSValue valueWithCGPoint:resetPosition], nil];
    [viewController performSelector:@selector(resetBumper:) withObject:parameters afterDelay:0.1];
}

void postSolveCollision(cpArbiter *arbiter, cpSpace *space, void *data) {
    
	if( cpArbiterIsFirstContact(arbiter) == NO ) 
        return;
    
	cpFloat impulse = cpvlength(cpArbiterTotalImpulse(arbiter));
	
	float volume = MIN(impulse/500.0f, 1.0f);
	if(volume > 0.05f){
		//[SimpleSound playSoundWithVolume:volume];
	}
}


#pragma mark -

@interface ViewController(PrivateMethods)
- (void)createScorePostsWithTextMapNamed:(NSString *)textMapName;
@end

@implementation ViewController
@synthesize topScore;
@synthesize bottomScore;

- (void)viewDidLoad {
	[super viewDidLoad];

	space = cpSpaceNew();
    cpSpaceSetIterations(space, 10);
    
    cpBody *floorBody = cpSpaceGetStaticBody(space);

    // left
	cpShape *floorShape = cpSegmentShapeNew(floorBody, cpv(0, 0), cpv(0, self.view.bounds.size.height), 0);
    cpShapeSetElasticity(floorShape, 1.0f);
	cpShapeSetFriction(floorShape, 1.0f);
	cpShapeSetCollisionType(floorShape, kFloorCollisionType);
    cpSpaceAddShape(space, floorShape);

    // right
    floorShape = cpSegmentShapeNew(floorBody, cpv(self.view.bounds.size.width, 0), cpv(self.view.bounds.size.width, self.view.bounds.size.height), 0);
    cpShapeSetElasticity(floorShape, 1.0f);
	cpShapeSetFriction(floorShape, 1.0f);
	cpShapeSetCollisionType(floorShape, kFloorCollisionType);
    cpSpaceAddShape(space, floorShape);

    // top
    floorShape = cpSegmentShapeNew(floorBody, cpv(0, 0), cpv(self.view.bounds.size.width, 0), 0);
    cpShapeSetElasticity(floorShape, 0.4f);
	cpShapeSetFriction(floorShape, 1.0f);
	cpShapeSetCollisionType(floorShape, kFloorCollisionType);
    cpSpaceAddShape(space, floorShape);

    // bottom
    floorShape = cpSegmentShapeNew(floorBody, cpv(0, self.view.bounds.size.height), cpv(self.view.bounds.size.width, self.view.bounds.size.height), 0);
    cpShapeSetElasticity(floorShape, 0.4f);
	cpShapeSetFriction(floorShape, 1.0f);
	cpShapeSetCollisionType(floorShape, kFloorCollisionType);
    cpSpaceAddShape(space, floorShape);
    


    cpSpaceAddCollisionHandler(space, 0, 1, NULL, NULL, (cpCollisionPostSolveFunc)postSolveCollision, NULL, NULL);
    cpSpaceAddCollisionHandler(space, 1, 2, (cpCollisionBeginFunc)beginCollisionWithButtonAndScorePost, NULL, NULL, NULL, self);
    cpSpaceAddCollisionHandler(space, 1, 3, NULL, NULL, (cpCollisionPostSolveFunc)postSolveCollisionWithButtonAndBumper, NULL, self);    
    cpSpaceAddCollisionHandler(space, 1, 4, NULL, NULL, (cpCollisionPostSolveFunc)postSolveCollisionWithButtonAndShooter, NULL, self);
    
    topShooter = [[BWShooter alloc] initWithFrame:CGRectMake(0, 0, 170, 170) color:ButtonColorGreen];
    [topShooter makeStaticBodyWithPosition:CGPointMake(self.view.bounds.size.width/2.0, 0)];
    topShooter.gameDelegate = self;
    cpSpaceAddShape(space, topShooter.shape);
    [self.view addSubview:topShooter];
    
    bottomShooter = [[BWShooter alloc] initWithFrame:CGRectMake(0, 0, 170, 170) color:ButtonColorOrange];
    [bottomShooter makeStaticBodyWithPosition:CGPointMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height)];
    bottomShooter.gameDelegate = self;
    cpSpaceAddShape(space, bottomShooter.shape);
    [self.view addSubview:bottomShooter];
    [bottomShooter updatePosition];
    
    UISwipeGestureRecognizer *swipeCleanGesture = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeClean:)] autorelease];
    [self.view addGestureRecognizer:swipeCleanGesture];
    
    [self createScorePosts];
    
    topScore = [[UILabel alloc] initWithFrame:CGRectMake(100, 25, 100, 50)];
    topScore.text = @"0";
    topScore.font = [UIFont boldSystemFontOfSize:24];    
    [self.view addSubview:topScore];
    
    bottomScore = [[UILabel alloc] initWithFrame:CGRectMake(100, self.view.bounds.size.height-75, 100, 50)];
    bottomScore.text = @"0";
    bottomScore.font = [UIFont boldSystemFontOfSize:24];
    [self.view addSubview:bottomScore];
    
    countdownLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2.0-200, self.view.bounds.size.height/2.0-40, 400, 80)];
    countdownLabel.textAlignment = UITextAlignmentCenter;
    countdownLabel.backgroundColor = [UIColor clearColor];
    countdownLabel.text = @"";
    countdownLabel.font = [UIFont boldSystemFontOfSize:34];
    [self.view addSubview:countdownLabel];
    
    
    UIViewQuadBody *wall = [[[UIViewQuadBody alloc] initWithFrame:CGRectMake(0, 0, 20, 200)] autorelease];
    cpBodySetAngle(wall.chipmunkLayer.body, M_PI-2);
    [wall setupWithSpace:space position:CGPointMake(100, 400)];
    [self.view addSubview:wall];
    
    wall = [[[UIViewQuadBody alloc] initWithFrame:CGRectMake(0, 0, 20, 200)] autorelease];
    cpBodySetAngle(wall.chipmunkLayer.body, M_PI-2);
    [wall setupWithSpace:space position:CGPointMake(self.view.bounds.size.width-100, self.view.bounds.size.height-400)];
    [self.view addSubview:wall];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
	// Set up the display link to control the timing of the animation.
	displayLink = [[CADisplayLink displayLinkWithTarget:self selector:@selector(update)] retain];
	displayLink.frameInterval = 1;
	[displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];	
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
	[displayLink invalidate];
	displayLink = nil;
}

- (void)update {
	cpFloat dt = displayLink.duration * displayLink.frameInterval;
	cpSpaceStep(space, dt);
	
    for( UIView *aView in self.view.subviews ) {
        if( [[aView class] isSubclassOfClass:[UIViewBody class]] == YES ||
           [[aView class] isSubclassOfClass:[UIImageViewBody class]] == YES )
            [(UIViewBody *)aView updatePosition];
    }
    
    for( CALayer *aLayer in self.view.layer.sublayers ) 
        if( [aLayer isKindOfClass:[BWChipmunkLayer class]] == YES )
            [(BWChipmunkLayer *)aLayer updatePosition];
    

    for( UIView *aView in self.view.subviews ) 
        if( [aView isKindOfClass:[BWButton class]] == YES ) {
            if( ((BWButton *)aView).color == ButtonColorGreen )
                [(BWButton *)aView guideTowardPoint:CGPointMake(self.view.bounds.size.width/2.0, 0)];
            else
                [(BWButton *)aView guideTowardPoint:CGPointMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height)];
        }

}

#pragma mark GameDelegate
- (void)shootWithShooter:(BWShooter *)shooter {
    
    if( shooter.activeButtonCount >= 1 )
        return;
    
    shooter.activeButtonCount++;
    BWButton *greenButton = [[[BWButton alloc] initWithColor:shooter.buttonColor] autorelease];
    [greenButton setupWithSpace:space position:CGPointMake(shooter.body->p.x, shooter.body->p.y)];
    [self.view addSubview:greenButton];

    cpVect v = cpvmult(cpvforangle(shooter.body->a), 1000.0f);
	cpBodyApplyImpulse(greenButton.chipmunkLayer.body, v, cpvzero);
}
#pragma mark -


- (void)swipeClean:(UISwipeGestureRecognizer *)swipeGesture {
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Remove all buttons?" message:@"" delegate:self cancelButtonTitle:@"Nope" otherButtonTitles:@"Remove", nil] autorelease];
    [alert show];

}

#pragma mark UIAlertViewDelegate 
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if( buttonIndex == 0 )
        return;
    
    [self removeButtons];
    [self removeScorePosts];
    [self createScorePosts];
    
    topScore.text = @"0";
    bottomScore.text = @"0";

}
#pragma mark -

- (void)removeButtons {
    for( UIView *potentialButton in self.view.subviews ) {
        if( [potentialButton isKindOfClass:[BWButton class]] ) {
            BWButton *buttonToRemove = (BWButton *)potentialButton;
            cpSpaceRemoveShape(space, buttonToRemove.chipmunkLayer.shape);
            cpSpaceRemoveBody(space, buttonToRemove.chipmunkLayer.body);
            [potentialButton removeFromSuperview];
        }
    }  
    topShooter.activeButtonCount = 0;
    bottomShooter.activeButtonCount = 0;
}

- (void)removeScorePosts {
    for( UIView *potentialButton in self.view.subviews ) {
        if( [potentialButton isKindOfClass:[BWScorePost class]] ) {
            BWScorePost *buttonToRemove = (BWScorePost *)potentialButton;
            cpSpaceRemoveShape(space, buttonToRemove.chipmunkLayer.shape);
            [potentialButton removeFromSuperview];
        } else if( [potentialButton isKindOfClass:[BWBumper class]] ) {
            BWBumper *buttonToRemove = (BWBumper *)potentialButton;
            cpSpaceRemoveShape(space, buttonToRemove.chipmunkLayer.shape);
            [potentialButton removeFromSuperview];
        }
        
    }        
}

- (void)createScorePosts {
    countdownLabel.text = @"";
    currentWinner = 0;
    countdown = 0;
    
    
    [self createScorePostsWithTextMapNamed:@"Level_1"];
       
    BWBumper *bumper = [[[BWBumper alloc] init] autorelease];
    [bumper setupWithSpace:space position:CGPointMake(250, 500)];
    [self.view addSubview:bumper];
    
    bumper = [[[BWBumper alloc] init] autorelease];
    [bumper setupWithSpace:space position:CGPointMake(500, 500)];
    [self.view addSubview:bumper];
    
    [self.view bringSubviewToFront:countdownLabel];    
}

- (void)resetBumper:(NSArray *)parameters {
    BWBumper *theBumper = [parameters objectAtIndex:0];
    cpVect resetPosition = [(NSValue *)[parameters objectAtIndex:1] CGPointValue];
    cpBodySetPos(theBumper.chipmunkLayer.body, resetPosition);
    theBumper.isBumping = NO;
}

- (void)createScorePostsWithQuantity:(NSUInteger)quantity inRect:(CGRect)insideRect {
    for( int i = 0; i < quantity; i++ ) {
        
        BWScorePost *scorePost = [[[BWScorePost alloc] init] autorelease];
        [scorePost setupWithSpace:space position:[Random randomPointInRect:insideRect]];
        [self.view addSubview:scorePost];
        [scorePost.chipmunkLayer updatePosition];
    }
}
- (void)checkForWinner {
    if( [topScore.text intValue] >= 15 )
        [self startCountdownForColor:ButtonColorGreen];
    else if( currentWinner == ButtonColorGreen )
        [self stopCountdownForColor:ButtonColorGreen];
    
    if( [bottomScore.text intValue] >= 15 )
        [self startCountdownForColor:ButtonColorOrange];
    else if( currentWinner == ButtonColorOrange )
        [self stopCountdownForColor:ButtonColorOrange];
}

- (void)startCountdownForColor:(ButtonColor)winningColor {

    if( winningColor == currentWinner )
        return;
    
    currentWinner = winningColor;
    
    [winnerTimer invalidate];
    [winnerTimer release];
    
    countdown = 0;
    winnerTimer = [[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(iterateCountdown:) userInfo:[NSNumber numberWithInt:winningColor] repeats:YES] retain];
}

- (void)stopCountdownForColor:(ButtonColor)theColor {

    currentWinner = ButtonColorNotSet;

    [winnerTimer invalidate];
    [winnerTimer release];
    winnerTimer = nil;
    
    countdown = 0;
    
    countdownLabel.text = @"";
}

- (void)iterateCountdown:(NSTimer *)countdownTimer {
    if( countdown == kCountdownTimer ) {
        [winnerTimer invalidate];
        [winnerTimer release];
        winnerTimer = nil;
        
        NSString *winnerLabel = currentWinner == ButtonColorGreen ? @"Green" : @"Orange";
        countdownLabel.text = [NSString stringWithFormat:@"%@ wins", winnerLabel];
    } else {
        countdown++;
        countdownLabel.text = [NSString stringWithFormat:@"%d", (kCountdownTimer+1)-countdown];
        
    }
}

- (void)dealloc {
	
	[super dealloc];
}

@end

@implementation ViewController(PrivateMethods)
- (void)createScorePostsWithTextMapNamed:(NSString *)textMapName {
    
    NSUInteger mapRowCount = 40;
    NSUInteger mapColumnCount = 72;
    
    CGFloat perRowAmount = 1020.0/(CGFloat)mapRowCount;
    CGFloat perColumnAmount = 768.0/(CGFloat)mapColumnCount;
    
    NSString *mapPath = [[NSBundle mainBundle] pathForResource:textMapName ofType:@"txt"];
    NSError *fileLoadError = nil;
    NSString *mapText = [NSString stringWithContentsOfFile:mapPath encoding:NSUTF8StringEncoding error:&fileLoadError];
    if( fileLoadError != nil ) {
        NSLog(@"Error reading file: %@ with reason: %@", mapPath, [fileLoadError localizedDescription]);
        return;
    }
    
    NSArray *mapRows = [mapText componentsSeparatedByString:@"\n"];
    
    if( [mapRows count] < mapRowCount - 1)
        NSLog(@"WARNDING: map is missing %d rows", mapRowCount - [mapRows count]);
    
    NSUInteger currentRow = 0;
    NSUInteger currentColumn = 0;
    for( NSString *row in mapRows ) {
        NSMutableArray *columns = [NSMutableArray arrayWithCapacity:row.length];
        for( NSUInteger i = 0; i < row.length; i++) {
            NSString *character  = [NSString stringWithFormat:@"%c", [row characterAtIndex:i]];
            [columns addObject:character];
        }
        for( NSString *character in columns ) {
            if( [character isEqualToString:@"p"] == YES ) {
                CGPoint newPosition = CGPointMake(currentColumn*perColumnAmount, currentRow*perRowAmount);
                NSLog(@"creating post at: %@", NSStringFromCGPoint(newPosition));
                BWScorePost *scorePost = [[[BWScorePost alloc] init] autorelease];
                [scorePost setupWithSpace:space position:newPosition];
                [self.view addSubview:scorePost];
                [scorePost.chipmunkLayer updatePosition];
            }
                
            currentColumn++;
            if( currentColumn == mapColumnCount+1 )
                break;
        }
        currentColumn = 0;
        currentRow++;
        
        if( currentRow == mapRowCount+1 )
            break;
    }
}
@end