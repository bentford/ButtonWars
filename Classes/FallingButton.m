// This class is a game object controller of sorts.
// It basically ties the physics and graphics objects together, and gives you a
// place to put your controlling logic.

#import "FallingButton.h"

#define SIZE 100.0f

@implementation FallingButton

@synthesize button;
@synthesize touchedShapes;
@synthesize chipmunkObjects;

static cpFloat frand_unit(){return 2.0f*((cpFloat)rand()/(cpFloat)RAND_MAX) - 1.0f;}

- (void)buttonClicked {
	// Apply a random velcity change to the body when the button is clicked.
	cpVect v = cpvmult(cpv(frand_unit(), frand_unit()), 300.0f);
	body.vel = cpvadd(body.vel, v);
	
	body.angVel += 5.0f*frand_unit();
}

- (void)updatePosition {
	button.transform = body.affineTransform;	
}

- (id)init {
	if( (self = [super init]) ) {
		button = [UIButton buttonWithType:UIButtonTypeCustom];
		[button setTitle:@"Click Me!" forState:UIControlStateNormal];
		[button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
		[button setBackgroundImage:[UIImage imageNamed:@"logo.png"] forState:UIControlStateNormal];
		button.bounds = CGRectMake(0, 0, SIZE, SIZE);
		
		[button addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchDown];
		
		cpFloat mass = 1.0f;
		cpFloat moment = cpMomentForBox(mass, SIZE, SIZE);
		
		body = [[ChipmunkBody alloc] initWithMass:mass andMoment:moment];
		body.pos = cpv(200.0f, 200.0f);

		ChipmunkShape *shape = [ChipmunkPolyShape boxWithBody:body width:SIZE height:SIZE];
		
		shape.elasticity = 0.3f;
		shape.friction = 0.3f;
		shape.collisionType = [FallingButton class];
        shape.data = self;
		
		chipmunkObjects = [ChipmunkObjectFlatten(body, shape, nil) retain];
	}
	return self;
}

- (void) dealloc
{
	[button release];
	[body release];
	[chipmunkObjects release];
	
	[super dealloc];
}

@end
