#import "ViewController.h"

#import "SimpleSound.h"
#import "UIViewQuadBody.h"
#import "UIImageViewBody.h"

static NSString *borderType = @"borderType";

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	space = cpSpaceNew();
    cpSpaceSetIterations(space, 10);
    
    cpBody *floorBody = cpSpaceGetStaticBody(space);

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
    
    UIViewQuadBody *square = [[[UIViewQuadBody alloc] initWithFrame:CGRectMake(100, 200, 50, 50)] autorelease];
    cpSpaceAddBody(space, square.body);
    cpSpaceAddShape(space, square.shape);
    [self.view addSubview:square];
    
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

- (void)dealloc {
	[fallingButton release];
	
	[super dealloc];
}

@end
