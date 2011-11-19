// This class is a game object controller of sorts.
// It basically ties the physics and graphics objects together, and gives you a
// place to put your controlling logic.

#import "FallingButton.h"
#import <QuartzCore/QuartzCore.h>

@implementation FallingButton

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
	self.transform = body.affineTransform;
}

- (id)initWithFrame:(CGRect)frame {
    if( (self = [super initWithFrame:frame]) ) {	
        self.clipsToBounds = NO;
		self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.layer.shadowOffset = CGSizeMake(0, 1);
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowRadius = 2;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        
		cpFloat mass = 1.0f;
        // this is why it's crooked.
		cpFloat moment = cpMomentForBox(mass, 0, frame.size.height);
		
		body = [[ChipmunkBody alloc] initWithMass:mass andMoment:moment];
		body.pos = cpv(200.0f, 200.0f);

		shape = [[ChipmunkPolyShape boxWithBody:body width:frame.size.width height:frame.size.height] retain];
		
		shape.elasticity = 0.3f;
		shape.friction = 0.3f;
		shape.collisionType = [FallingButton class];
        shape.data = self;
		
		chipmunkObjects = [ChipmunkObjectFlatten(body, shape, nil) retain];
	}
	return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    [self buttonClicked];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor orangeColor].CGColor);
    CGContextFillEllipseInRect(context, rect);

    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGContextSetLineWidth(context, 2.0);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, rect.size.width, 0);
    CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
    CGContextAddLineToPoint(context, 0, rect.size.height);
    CGContextAddLineToPoint(context, 0, 0);
    CGContextStrokePath(context);
    
    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
    CGContextSetLineWidth(context, 2.0);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, 0);
    for( NSUInteger vertexIndex = 0; vertexIndex < shape.count; vertexIndex++ ) {
        cpVect point = [shape getVertex:vertexIndex];
        CGContextAddLineToPoint(context, point.x, point.y);
    }
    CGContextStrokePath(context);
}

- (void) dealloc {
	[body release];
	[chipmunkObjects release];
	
	[super dealloc];
}

@end
