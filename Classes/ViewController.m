#import "ViewController.h"

#import "SimpleSound.h"

static NSString *borderType = @"borderType";

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	space = [[ChipmunkSpace alloc] init];
	

	[space addBounds:self.view.bounds thickness:2.0f elasticity:1.0f friction:1.0f layers:CP_ALL_LAYERS group:CP_NO_GROUP collisionType:borderType];
	

	[space addCollisionHandler:self
		typeA:[FallingButton class] typeB:borderType
		begin:@selector(beginCollision:space:)
		preSolve:nil
		postSolve:@selector(postSolveCollision:space:)
		separate:@selector(separateCollision:space:)
	];
	
	fallingButton = [[FallingButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
	[self.view addSubview:fallingButton];

	[space add:fallingButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
	// Set up the display link to control the timing of the animation.
	displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
	displayLink.frameInterval = 1;
	[displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
	
	// Set up an accelerometer delegate.
	UIAccelerometer *accel = [UIAccelerometer sharedAccelerometer];
	accel.updateInterval = 1.0f/30.0f;
	accel.delegate = self;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
	[displayLink invalidate];
	displayLink = nil;
	
	[UIAccelerometer sharedAccelerometer].delegate = nil;
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)accel {
	// Setting the gravity based on the tilt of the device is easy.
	space.gravity = cpvmult(cpv(accel.x, -accel.y), 100.0f);
}

- (void)update {
	cpFloat dt = displayLink.duration*displayLink.frameInterval;
	[space step:dt];
	
	[fallingButton updatePosition];
}

#pragma mark - Collisions

- (bool)beginCollision:(cpArbiter*)arbiter space:(ChipmunkSpace*)space {
	// This macro gets the colliding shapes from the arbiter and defines variables for them.
	CHIPMUNK_ARBITER_GET_SHAPES(arbiter, buttonShape, border);
	
	// It expands to look something like this:
	// ChipmunkShape *buttonShape = GetShapeWithFirstCollisionType();
	// ChipmunkShape *border = GetShapeWithSecondCollisionType();
	
	// Lets log the data pointers just to make sure we are getting what we think we are.
	NSLog(@"First object in the collision is %@ second object is %@.", buttonShape.data, border.data);
	
	FallingButton *fb = buttonShape.data;
	fb.touchedShapes++;
	
	// begin and pre-solve callbacks MUST return a boolean.
	// Returning false from a begin callback ignores a collision permanently.
	// Returning false from a pre-solve callback ignores the collision for just one frame.
	// See the documentation on collision handlers for more information.
	return TRUE; 
}

- (void)postSolveCollision:(cpArbiter*)arbiter space:(ChipmunkSpace*)space {
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

static CGFloat frand(){return (CGFloat)rand()/(CGFloat)RAND_MAX;}

// The separate callback is called whenever shapes stop touching.
- (void)separateCollision:(cpArbiter*)arbiter space:(ChipmunkSpace*)space {
	CHIPMUNK_ARBITER_GET_SHAPES(arbiter, buttonShape, border);
	
	FallingButton *fb = buttonShape.data;
	fb.touchedShapes--;
	
	// If touchedShapes is 0, then we know the falling button isn't touching anything anymore.
	if(fb.touchedShapes == 0){
		
	}
}

#pragma mark -

- (void)dealloc {
	[fallingButton release];
	
	[super dealloc];
}

@end
