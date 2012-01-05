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

void postSolveCollisionWithButtonAndBumper(cpArbiter *arbiter, cpSpace *space, void *data) {
    CP_ARBITER_GET_SHAPES(arbiter, a, b);
    BWBumper *bumper = b->data;
    BWButton *button = a->data;
    ViewController *viewController = data;
     

    cpVect collisionVector = cpvnormalize(cpvsub(cpBodyGetPos(bumper.chipmunkLayer.body), cpBodyGetPos(button.body)));
    cpVect invertedCollisionVector = cpvrotate(collisionVector, cpvforangle(M_PI));
    cpVect impulseVector = cpvmult(invertedCollisionVector, 500);
    cpVect bounceVector = cpvmult(invertedCollisionVector, 10);
    
    // bounce button away
    cpBodyApplyImpulse(button.body, impulseVector, cpvzero);
    
    
    
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
		[SimpleSound playSoundWithVolume:volume];
	}
}


#pragma mark -

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
    cpShapeSetElasticity(floorShape, 1.0f);
	cpShapeSetFriction(floorShape, 1.0f);
	cpShapeSetCollisionType(floorShape, kFloorCollisionType);
    cpSpaceAddShape(space, floorShape);

    // bottom
    floorShape = cpSegmentShapeNew(floorBody, cpv(0, self.view.bounds.size.height), cpv(self.view.bounds.size.width, self.view.bounds.size.height), 0);
    cpShapeSetElasticity(floorShape, 1.0f);
	cpShapeSetFriction(floorShape, 1.0f);
	cpShapeSetCollisionType(floorShape, kFloorCollisionType);
    cpSpaceAddShape(space, floorShape);
    

    
    cpSpaceAddCollisionHandler(space, 0, 1, NULL, NULL, (cpCollisionPostSolveFunc)postSolveCollision, NULL, NULL);
    cpSpaceAddCollisionHandler(space, 1, 2, NULL, NULL, (cpCollisionPostSolveFunc)postSolveCollisionWithButtonAndScorePost, NULL, self);
    cpSpaceAddCollisionHandler(space, 1, 3, NULL, NULL, (cpCollisionPostSolveFunc)postSolveCollisionWithButtonAndBumper, NULL, self);    

    BWShooter *shooter = [[[BWShooter alloc] initWithFrame:CGRectMake(0, 0, 270, 270) color:ButtonColorGreen] autorelease];
    [shooter makeStaticBodyWithPosition:CGPointMake(self.view.bounds.size.width/2.0, 0)];
    shooter.gameDelegate = self;
    cpSpaceAddShape(space, shooter.shape);
    [self.view addSubview:shooter];
    
    BWShooter *bottomShooter = [[[BWShooter alloc] initWithFrame:CGRectMake(0, 0, 270, 270) color:ButtonColorOrange] autorelease];
    [bottomShooter makeStaticBodyWithPosition:CGPointMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height)];
    bottomShooter.gameDelegate = self;
    cpSpaceAddShape(space, bottomShooter.shape);
    [self.view addSubview:bottomShooter];
    
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
}

#pragma mark GameDelegate
- (void)shootWithShooter:(BWShooter *)shooter {
    BWButton *greenButton = [[[BWButton alloc] initWithFrame:CGRectMake(shooter.body->p.x, shooter.body->p.y, 50, 50) color:shooter.buttonColor] autorelease];
    cpSpaceAddBody(space, greenButton.body);
    cpSpaceAddShape(space, greenButton.shape);
    [self.view addSubview:greenButton];

    cpVect v = cpvmult(cpvforangle(shooter.body->a), 1000.0f);
	cpBodyApplyImpulse(greenButton.body, v, cpvzero);
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
            cpSpaceRemoveShape(space, buttonToRemove.shape);
            cpSpaceRemoveBody(space, buttonToRemove.body);
            [potentialButton removeFromSuperview];
        }
    }    
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

    [Random seed];

    [self createScorePostsWithQuantity:5 inRect:CGRectMake(10, 50, self.view.bounds.size.width/2.0, self.view.bounds.size.height/2.0)];
    [self createScorePostsWithQuantity:5 inRect:CGRectMake(10, self.view.bounds.size.height/2.0, self.view.bounds.size.width/2.0, self.view.bounds.size.height/2.0)];
    
    BWBumper *bumper = [[[BWBumper alloc] init] autorelease];
    [bumper setupWithSpace:space position:CGPointMake(250, 500)];
    [self.view addSubview:bumper];
    
    bumper = [[[BWBumper alloc] init] autorelease];
    [bumper setupWithSpace:space position:CGPointMake(500, 500)];
    [self.view addSubview:bumper];
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
    }
}

- (void)dealloc {
	
	[super dealloc];
}

@end
