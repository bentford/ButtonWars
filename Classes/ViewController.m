#import "ViewController.h"

#import "SimpleSound.h"
#import "UIViewQuadBody.h"
#import "BWButton.h"
#import "BWShooter.h"
#import "BWScorePost.h"
#import "Random.h"

static NSString *borderType = @"borderType";

#pragma mark - Collisions

void postStepRemove(cpSpace *space, cpShape *shape, void *unused)
{
    UIView *scorePost = shape->data;
    [scorePost retain];
    [scorePost removeFromSuperview];
    
    cpSpaceRemoveShape(space, shape);
    
    [scorePost release];
}

int beginCollision(cpArbiter *arb, cpSpace *space, void *unused) {
    cpShape *a, *b; 
    cpArbiterGetShapes(arb, &a, &b);
    
    // Alternatively you can use the CP_ARBITER_GET_SHAPES() macro
    //CP_ARBITER_GET_SHAPES(arb, a, b);
    
    cpSpaceAddPostStepCallback(space, (cpPostStepFunc)postStepRemove, b, NULL);
    
    return 0;
}

void postSolveCollisionWithButtonAndScorePost(cpArbiter *arbiter, cpSpace *space, void *data) {
    CP_ARBITER_GET_SHAPES(arbiter, a, b);
    
    cpSpaceAddPostStepCallback(space, (cpPostStepFunc)postStepRemove, b, NULL);
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
    cpSpaceAddCollisionHandler(space, 1, 2, NULL, NULL, (cpCollisionPostSolveFunc)postSolveCollisionWithButtonAndScorePost, NULL, NULL);

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
    
    BWButton *greenButton = [[[BWButton alloc] initWithFrame:CGRectMake(500, 500, 50, 50) color:ButtonColorGreen] autorelease];
    cpSpaceAddBody(space, greenButton.body);
    cpSpaceAddShape(space, greenButton.shape);
    [self.view addSubview:greenButton];
    
    UISwipeGestureRecognizer *swipeCleanGesture = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeClean:)] autorelease];
    [self.view addGestureRecognizer:swipeCleanGesture];
    
    [Random seed];
    for( int scorePostCount = 0; scorePostCount < 10; scorePostCount++ ) {
        NSUInteger randomX = [Random randomWithMin:50 max:(NSUInteger)self.view.bounds.size.width-50];
        NSUInteger randomY = [Random randomWithMin:250 max:(NSUInteger)self.view.bounds.size.height-250];
        
        BWScorePost *scorePost = [[[BWScorePost alloc] initWithFrame:CGRectMake(560, 600, 60, 60)] autorelease];
        [scorePost makeStaticBodyWithPosition:CGPointMake(randomX, randomY)];
        cpSpaceAddShape(space, scorePost.shape);
        [self.view addSubview:scorePost];

    }
    

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
    
    for( UIView *potentialButton in self.view.subviews ) {
        if( [potentialButton isKindOfClass:[BWButton class]] ) {
            BWButton *buttonToRemove = (BWButton *)potentialButton;
            cpSpaceRemoveShape(space, buttonToRemove.shape);
            cpSpaceRemoveBody(space, buttonToRemove.body);
            [potentialButton removeFromSuperview];
        }
    }
}
#pragma mark -

- (void)dealloc {
	[fallingButton release];
	
	[super dealloc];
}

@end
