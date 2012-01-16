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
#import "BWRotatingBumper.h"
#import "BWSlidingBox.h"

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

void postStepRemoveButtonBodyFromSpace(cpSpace *space, cpShape *shape, void *unused) {
    BWButton *button = shape->data;
    cpSpaceRemoveBody(space, button.chipmunkLayer.body);
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

void beginSolveCollisionWithButtonAndRotatingBumper(cpArbiter *arbiter, cpSpace *space, void *data) {
    CP_ARBITER_GET_SHAPES(arbiter, a, b);
    BWRotatingBumper *bumper = b->data;
    BWButton *button = a->data;

    [bumper trapButton:button withSpace:space];
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
- (void)populateMapWithFileNamed:(NSString *)textMapName;
@end

@implementation ViewController
@synthesize topScore;
@synthesize bottomScore;

- (void)viewDidLoad {
	[super viewDidLoad];
    self.wantsFullScreenLayout = YES;
    
    CALayer *background = [CALayer layer];
    background.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    background.contents = (id)[UIImage imageNamed:@"Background_1.png"].CGImage;
    [self.view.layer insertSublayer:background atIndex:0];
    
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
    floorShape = cpSegmentShapeNew(floorBody, cpv(0, 50), cpv(self.view.bounds.size.width/2.0, 0), 0);
    cpShapeSetElasticity(floorShape, 0.4f);
	cpShapeSetFriction(floorShape, 1.0f);
	cpShapeSetCollisionType(floorShape, kFloorCollisionType);
    cpSpaceAddShape(space, floorShape);
    
    floorShape = cpSegmentShapeNew(floorBody, cpv(self.view.bounds.size.width/2.0, 0), cpv(self.view.bounds.size.width, 50), 0);
    cpShapeSetElasticity(floorShape, 0.4f);
	cpShapeSetFriction(floorShape, 1.0f);
	cpShapeSetCollisionType(floorShape, kFloorCollisionType);
    cpSpaceAddShape(space, floorShape);


    // bottom
    floorShape = cpSegmentShapeNew(floorBody, cpv(0, self.view.bounds.size.height-50), cpv(self.view.bounds.size.width/2.0, self.view.bounds.size.height), 0);
    cpShapeSetElasticity(floorShape, 0.4f);
	cpShapeSetFriction(floorShape, 1.0f);
	cpShapeSetCollisionType(floorShape, kFloorCollisionType);
    cpSpaceAddShape(space, floorShape);
    
    floorShape = cpSegmentShapeNew(floorBody, cpv(self.view.bounds.size.width/2.0, self.view.bounds.size.height), cpv(self.view.bounds.size.width, self.view.bounds.size.height-50), 0);
    cpShapeSetElasticity(floorShape, 0.4f);
	cpShapeSetFriction(floorShape, 1.0f);
	cpShapeSetCollisionType(floorShape, kFloorCollisionType);
    cpSpaceAddShape(space, floorShape);

    cpSpaceAddCollisionHandler(space, 0, 1, NULL, NULL, (cpCollisionPostSolveFunc)postSolveCollision, NULL, NULL);
    cpSpaceAddCollisionHandler(space, 1, 2, (cpCollisionBeginFunc)beginCollisionWithButtonAndScorePost, NULL, NULL, NULL, self);
    cpSpaceAddCollisionHandler(space, 1, 3, NULL, NULL, (cpCollisionPostSolveFunc)postSolveCollisionWithButtonAndBumper, NULL, self);    
    cpSpaceAddCollisionHandler(space, 1, 4, NULL, NULL, (cpCollisionPostSolveFunc)postSolveCollisionWithButtonAndShooter, NULL, self);
    cpSpaceAddCollisionHandler(space, 1, 5, (cpCollisionBeginFunc)beginSolveCollisionWithButtonAndRotatingBumper, NULL, NULL, NULL, self);
    
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
    
    UISwipeGestureRecognizer *swipeCleanGesture = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(chooseNewLevel:)] autorelease];
    [self.view addGestureRecognizer:swipeCleanGesture];
    
    [self reloadMapWithLevelNamed:@"Level_1"];
    
    topScore = [[UILabel alloc] initWithFrame:CGRectMake(100, 25, 100, 50)];
    topScore.text = @"0";
    topScore.font = [UIFont boldSystemFontOfSize:24];
    topScore.backgroundColor = [UIColor clearColor];
    topScore.textColor = [UIColor whiteColor];    
    [self.view addSubview:topScore];
    
    bottomScore = [[UILabel alloc] initWithFrame:CGRectMake(100, self.view.bounds.size.height-75, 100, 50)];
    bottomScore.text = @"0";
    bottomScore.font = [UIFont boldSystemFontOfSize:24];
    bottomScore.backgroundColor = [UIColor clearColor];    
    bottomScore.textColor = [UIColor whiteColor];
    [self.view addSubview:bottomScore];
    
    countdownLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2.0-200, self.view.bounds.size.height/2.0-40, 400, 80)];
    countdownLabel.textAlignment = UITextAlignmentCenter;
    countdownLabel.backgroundColor = [UIColor clearColor];
    countdownLabel.text = @"";
    countdownLabel.font = [UIFont boldSystemFontOfSize:34];
    [self.view addSubview:countdownLabel];
    
    BWSlidingBox *slidingBox = [[[BWSlidingBox alloc] init] autorelease];
    [slidingBox setupWithSpace:space position:cpv(100,100)];
    [self.view addSubview:slidingBox];
    
    
    CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:@"bodyPosition.x"];
    moveAnimation.fromValue = [NSNumber numberWithInt:100];
    moveAnimation.toValue = [NSNumber numberWithInt:300];
    moveAnimation.duration = 3.0;
    moveAnimation.autoreverses = YES;
    moveAnimation.repeatCount = INFINITY;
    moveAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [slidingBox.chipmunkLayer addAnimation:moveAnimation forKey:@"bodyPosition.x"];
    
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
        if( [aView isKindOfClass:[BWButton class]] == YES && ((BWButton *)aView).ignoreGuideForce == NO ) {
            if( ((BWButton *)aView).color == ButtonColorGreen )
                [(BWButton *)aView guideTowardPlaneOfPoint:CGPointMake(self.view.bounds.size.width/2.0, 0)];
            else
                [(BWButton *)aView guideTowardPlaneOfPoint:CGPointMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height)];
        }

}

#pragma mark GameDelegate
- (void)shootWithShooter:(BWShooter *)shooter {
    
    if( shooter.activeButtonCount >= 1 )
        return;
    
    shooter.activeButtonCount++;
    BWButton *greenButton = [[[BWButton alloc] initWithColor:shooter.buttonColor] autorelease];
    [greenButton setupWithSpace:space position:CGPointMake(shooter.body->p.x, shooter.body->p.y)];
    [self.view insertSubview:greenButton belowSubview:topScore];

    cpVect v = cpvmult(cpvforangle(shooter.body->a), 1000.0f);
	cpBodyApplyImpulse(greenButton.chipmunkLayer.body, v, cpvzero);
}
#pragma mark -

#pragma mark LevelPickerDelegate
- (void)didChooseLevel:(NSString *)levelName {
    NSLog(@"didChooseLeveL: %@", levelName);
    [self reloadMapWithLevelNamed:levelName];
}
#pragma mark -

- (void)chooseNewLevel:(UISwipeGestureRecognizer *)swipeGesture {
    if( levelPickerViewController == nil ) {
        levelPickerViewController = [[LevelPickerViewController alloc] init];
        levelPickerViewController.delegate = self;
    }
    
    [self presentViewController:levelPickerViewController animated:YES completion:nil];
}

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

- (void)removeLevelItems {
    for( UIView *potentialButton in self.view.subviews ) {

        // score posts
        if( [potentialButton isKindOfClass:[BWScorePost class]] ) {
            BWScorePost *buttonToRemove = (BWScorePost *)potentialButton;
            [buttonToRemove removeFromSpace:space];
            [potentialButton removeFromSuperview];
        
        // bumpers
        } else if( [potentialButton isKindOfClass:[BWBumper class]] ) {
            BWBumper *buttonToRemove = (BWBumper *)potentialButton;
            [buttonToRemove removeFromSpace:space];
            [potentialButton removeFromSuperview];

        // rotating bumper
        } else if( [potentialButton isKindOfClass:[BWRotatingBumper class]] ) {
            BWRotatingBumper *buttonToRemove = (BWRotatingBumper *)potentialButton;
            [buttonToRemove removeFromSpace:space];
            [potentialButton removeFromSuperview];
        
        // walls
        } else if( [potentialButton isKindOfClass:[UIViewQuadBody class]] ) {
            UIViewQuadBody *buttonToRemove = (UIViewQuadBody *)potentialButton;
            [buttonToRemove removeFromSpace:space];
            [potentialButton removeFromSuperview];
        }
        
    }        
}

- (void)reloadMapWithLevelNamed:(NSString *)levelName {
    countdownLabel.text = @"";
    currentWinner = 0;
    countdown = 0;
    
    topScore.text = @"0";
    bottomScore.text = @"0";
    
    [self removeButtons];
    [self removeLevelItems];
    
    [self populateMapWithFileNamed:levelName];
    
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
    if( [topScore.text intValue] >= pointsToWin )
        [self startCountdownForColor:ButtonColorGreen];
    else if( currentWinner == ButtonColorGreen )
        [self stopCountdownForColor:ButtonColorGreen];
    
    if( [bottomScore.text intValue] >= pointsToWin )
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

- (void)fireTrappedButton:(NSArray *)parameters {
    BWButton *button = [parameters objectAtIndex:0];
    BWRotatingBumper *bumper = [parameters objectAtIndex:1];

    cpBodySetAngVel(bumper.chipmunkLayer.body, 0);
    cpBodySetVel(button.chipmunkLayer.body, cpvzero);
    cpSpaceAddBody(space, button.chipmunkLayer.body);
    cpBodyApplyImpulse(button.chipmunkLayer.body, cpv(-1000,0), cpvzero);
}

- (void)dealloc {
	
	[super dealloc];
}

@end

@implementation ViewController(PrivateMethods)
- (void)populateMapWithFileNamed:(NSString *)textMapName {
    
    NSUInteger mapRowCount = 33;
    NSUInteger mapColumnCount = 65;
    
    CGFloat perRowAmount = 1024.0/((CGFloat)mapRowCount-1);
    CGFloat perColumnAmount = 768.0/((CGFloat)mapColumnCount-1);
    
    NSUInteger middleRow = ((mapRowCount-1)/2)+1; // 17
    NSUInteger middleColumn = ((mapColumnCount-1)/2)+1; // 33
    
    NSString *cacheFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *mapPath = [cacheFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", textMapName]];
    NSError *fileLoadError = nil;
    NSString *mapText = [NSString stringWithContentsOfFile:mapPath encoding:NSUTF8StringEncoding error:&fileLoadError];
    if( fileLoadError != nil ) {
        NSLog(@"Error reading file: %@ with reason: %@", mapPath, [fileLoadError localizedDescription]);
        return;
    }
    
    NSArray *mapRows = [mapText componentsSeparatedByString:@"\n"];
    
    if( [mapRows count] < mapRowCount - 1)
        NSLog(@"WARNDING: map is missing %d rows", mapRowCount - [mapRows count]);
    
    NSMutableDictionary *wallPointDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
    
    NSUInteger currentRow = 0;
    NSUInteger currentColumn = 0;
    for( NSString *row in mapRows ) {
        NSMutableArray *columns = [NSMutableArray arrayWithCapacity:row.length];
        for( NSUInteger i = 0; i < row.length; i++) {
            NSString *character  = [NSString stringWithFormat:@"%c", [row characterAtIndex:i]];
            [columns addObject:character];
        }
        for( NSString *character in columns ) {
            
            
            CGFloat xPoint = 0;
            CGFloat yPoint = 0;
            
            // get xPoint 
            if( currentRow < middleRow )
                yPoint = currentRow*perRowAmount;
            else if( currentRow == middleRow )
                yPoint = 1024.0/2.0;
            else if( currentRow > middleRow )
                yPoint = ((currentRow-(middleRow-1))*perRowAmount)+(1024.0/2.0);
            
            // get yPoint
            if( currentColumn < middleColumn )
                xPoint = currentColumn * perColumnAmount;
            else if( currentColumn == middleColumn ) 
                xPoint = 768.0/2.0;
            else if( currentColumn > middleColumn )
                xPoint = ((currentColumn-(middleColumn-1))*perColumnAmount)+(768.0/2.0);
            
            CGPoint currentPosition = CGPointMake(xPoint, yPoint);
            
            if( [character isEqualToString:@"p"] == YES ) {
                BWScorePost *scorePost = [[[BWScorePost alloc] init] autorelease];
                [scorePost setupWithSpace:space position:currentPosition];
                [self.view addSubview:scorePost];
                [scorePost.chipmunkLayer updatePosition];
            }
            
            if( [character isEqualToString:@"b"] == YES && ( currentColumn == 0 || [[columns objectAtIndex:currentColumn-1] isEqualToString:@"r"] == NO) ) {
                BWBumper *bumper = [[[BWBumper alloc] init] autorelease];
                [bumper setupWithSpace:space position:currentPosition];
                [self.view addSubview:bumper];
            }
            
            if( [character isEqualToString:@"r"] == YES && currentColumn+1 < [columns count] && [[columns objectAtIndex:currentColumn+1] isEqualToString:@"b"] == YES ) {
                BWRotatingBumper *bumper = [[[BWRotatingBumper alloc] init] autorelease];
                [bumper setupWithSpace:space position:currentPosition];
                [self.view addSubview:bumper];
            }
            
            // walls
            if( [character isEqualToString:@"w"] == YES ) {
                NSString *wallNumber = [columns objectAtIndex:currentColumn+1];
                NSString *wallIdentifier = [NSString stringWithFormat:@"%@%@", character, wallNumber];
                
                if( [wallPointDictionary.allKeys containsObject:wallIdentifier] == NO )
                    [wallPointDictionary setObject:[NSMutableArray array] forKey:wallIdentifier];
                
                [[wallPointDictionary objectForKey:wallIdentifier] addObject:[NSValue valueWithCGPoint:currentPosition]];
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
    
    for( NSString *wallNumber in wallPointDictionary.allKeys ) {
        NSArray *wallPoints = [wallPointDictionary objectForKey:wallNumber];
        
        if( [wallPoints count] != 2 ) {
            NSLog(@"skipping wall because it had %d point(s)", [wallPoints count]);
            continue;
        }
        
        CGPoint firstPoint = [[wallPoints objectAtIndex:0] CGPointValue];
        CGPoint secondPoint = [[wallPoints objectAtIndex:1] CGPointValue];
        
        CGFloat length = cpvlength(cpvsub(firstPoint, secondPoint));
        CGFloat angle = cpvtoangle(cpvnormalize(cpvsub(firstPoint, secondPoint))) - M_PI/2.0;
        
        CGPoint midVect = cpvadd(cpvclamp(cpvsub(firstPoint, secondPoint), length/2.0), secondPoint);
        
        UIViewQuadBody *wall = [[[UIViewQuadBody alloc] initWithFrame:CGRectMake(0, 0, 20, length)] autorelease];
        cpBodySetAngle(wall.chipmunkLayer.body, angle);
        [wall setupWithSpace:space position:midVect];
        [self.view addSubview:wall];
    }
    
    if( [mapRows count] >= 34 ) {
        pointsToWin = [[mapRows objectAtIndex:33] intValue];
        if( pointsToWin == 0 )
            pointsToWin = 15;
    } else
        pointsToWin = 15;
}
@end