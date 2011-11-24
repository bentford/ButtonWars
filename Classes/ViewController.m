#import "ViewController.h"

#import "SimpleSound.h"

static NSString *borderType = @"borderType";

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	space = cpSpaceNew();
    cpSpaceSetIterations(space, 10);
    
    cpBody *floorBody = cpSpaceGetStaticBody(space);
    NSLog(@"walls: %f, %f", floorBody->p.x, floorBody->p.y);
	cpShape *floorShape = cpSegmentShapeNew(floorBody, cpv(0, 0), cpv(0, 460), 0);
    cpShapeSetElasticity(floorShape, 1.0f);
	cpShapeSetFriction(floorShape, 1.0f);
	cpShapeSetCollisionType(floorShape, kFloorCollisionType);
    cpSpaceAddShape(space, floorShape);

    floorShape = cpSegmentShapeNew(floorBody, cpv(320, 0), cpv(320, 460), 0);
    cpShapeSetElasticity(floorShape, 1.0f);
	cpShapeSetFriction(floorShape, 1.0f);
	cpShapeSetCollisionType(floorShape, kFloorCollisionType);
    cpSpaceAddShape(space, floorShape);

    floorShape = cpSegmentShapeNew(floorBody, cpv(0, 0), cpv(320, 0), 0);
    cpShapeSetElasticity(floorShape, 1.0f);
	cpShapeSetFriction(floorShape, 1.0f);
	cpShapeSetCollisionType(floorShape, kFloorCollisionType);
    cpSpaceAddShape(space, floorShape);
    
    floorShape = cpSegmentShapeNew(floorBody, cpv(0, 460), cpv(320, 460), 0);
    cpShapeSetElasticity(floorShape, 1.0f);
	cpShapeSetFriction(floorShape, 1.0f);
	cpShapeSetCollisionType(floorShape, kFloorCollisionType);
    cpSpaceAddShape(space, floorShape);
    
	fallingButton = [[FallingButton alloc] initWithFrame:CGRectMake(10, 200, 50, 50)];
	[self.view addSubview:fallingButton];
    cpSpaceAddShape(space, fallingButton.shape);
    cpSpaceAddBody(space, fallingButton.body);
    
    cpSpaceAddCollisionHandler(space, 0, 1, NULL, NULL, &postSolveCollision, NULL, NULL);
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
	
	[fallingButton updatePosition];
}

#pragma mark - Collisions


void postSolveCollision(cpArbiter *arbiter, cpSpace *space, void *data) {

	if( cpArbiterIsFirstContact(arbiter) == NO ) 
        return;
	
    NSLog(@"body a: %1.2f, %1.2f", arbiter->body_a_private->p.x, arbiter->body_a_private->p.y);
    
	cpFloat impulse = cpvlength(cpArbiterTotalImpulse(arbiter));
	
	float volume = MIN(impulse/500.0f, 1.0f);
	if(volume > 0.05f){
		[SimpleSound playSoundWithVolume:volume];
	}
}


#pragma mark -

- (void)dealloc {
	[fallingButton release];
	
	[super dealloc];
}

@end
