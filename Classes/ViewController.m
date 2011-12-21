#import "ViewController.h"

#import "SimpleSound.h"
#import "UIViewQuadBody.h"
#import "BWButton.h"
#import "BWShooter.h"

static NSString *borderType = @"borderType";

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
    

    
    cpSpaceAddCollisionHandler(space, 0, 1, NULL, NULL, &postSolveCollision, NULL, NULL);


    BWShooter *shooter = [[[BWShooter alloc] initWithFrame:CGRectMake(0, 0, 270, 270)] autorelease];
    [shooter makeStaticBody:floorBody];
    shooter.gameDelegate = self;
//    shooter.center = CGPointMake(0, 0);
    cpSpaceAddShape(space, shooter.shape);
    [self.view addSubview:shooter];
    
    BWButton *greenButton = [[[BWButton alloc] initWithFrame:CGRectMake(200, 400, 50, 50)] autorelease];
    cpSpaceAddBody(space, greenButton.body);
    cpSpaceAddShape(space, greenButton.shape);
    [self.view addSubview:greenButton];
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

#pragma mark - Collisions


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


#pragma mark GameDelegate
- (void)shootWithShooter:(BWShooter *)shooter {
    BWButton *greenButton = [[[BWButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)] autorelease];
    cpSpaceAddBody(space, greenButton.body);
    cpSpaceAddShape(space, greenButton.shape);
    [self.view addSubview:greenButton];

    cpVect v = cpvmult(cpvforangle(shooter.body->a), 1000.0f);
	cpBodyApplyImpulse(greenButton.body, v, cpvzero);

}
#pragma mark -

- (void)dealloc {
	[fallingButton release];
	
	[super dealloc];
}

@end
