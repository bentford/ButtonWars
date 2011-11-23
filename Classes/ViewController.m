#import "ViewController.h"

#import "SimpleSound.h"

static NSString *borderType = @"borderType";

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	space = cpSpaceNew();
    cpSpaceSetIterations(space, 10);
    
    cpBody *floorBody = cpSpaceGetStaticBody(space);
	cpShape *floorShape = cpBoxShapeNew(floorBody, self.view.frame.size.width, 10);
	cpShapeSetCollisionType(floorShape, kFloorCollisionType);
    cpSpaceAddShape(space, floorShape);

		
	fallingButton = [[FallingButton alloc] initWithFrame:CGRectMake(10, 200, 50, 50)];
	[self.view addSubview:fallingButton];
    cpSpaceAddShape(space, fallingButton.shape);
    
    cpSpaceAddCollisionHandler(space, 0, 1, NULL, NULL, &postSolveCollision, NULL, NULL);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
	// Set up the display link to control the timing of the animation.
	displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
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
    NSLog(@"dt: %f", dt);
	cpSpaceStep(space, dt);
	
	[fallingButton updatePosition];
}

#pragma mark - Collisions


void postSolveCollision(cpArbiter *arbiter, cpSpace *space, void *data) {
    NSLog(@"postSolveCollision");
	// We only care about the first frame of the collision.
	// If the shapes have been colliding for more than one frame, return early.
	if(!cpArbiterIsFirstContact(arbiter)) return;
	
	// This method gets the impulse that was applied between the two objects to resolve
	// the collision. We'll use the length of the impulse vector to approximate the sound
	// volume to play for the collision.
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
