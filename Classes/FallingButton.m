// This class is a game object controller of sorts.
// It basically ties the physics and graphics objects together, and gives you a
// place to put your controlling logic.

#import "FallingButton.h"
#import <QuartzCore/QuartzCore.h>

@interface FallingButton(PrivateMethods)
- (CGAffineTransform)transformWithBody:(cpBody *)body;
@end

@implementation FallingButton
@synthesize shape;
@synthesize body;

static cpFloat frand_unit(){return 2.0f*((cpFloat)rand()/(cpFloat)RAND_MAX) - 1.0f;}

- (void)buttonClicked {

	// Apply a random velcity change to the body when the button is clicked.
    cpVect v = cpvmult(cpv(frand_unit(), frand_unit()), 300.0f);
	body->v = cpvadd(body->v, v);
	
	body->w += 5.0f*frand_unit();
}

- (void)updatePosition {
	self.transform = [self transformWithBody:body];
    //NSLog(@"body: %1.2f %1.2f", body->p.x, body->p.y);
//    NSLog(@"frame: %1.2f %1.2f", self.transform.tx, self.transform.ty);

}

- (id)initWithFrame:(CGRect)frame {
    if( (self = [super initWithFrame:frame]) ) {	
        
        
		self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.layer.shadowOffset = CGSizeMake(0, 1);
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowRadius = 2;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shouldRasterize = YES;
        
        self.userInteractionEnabled = YES;
        
        
		cpFloat mass = 1.0f;

		cpFloat moment = cpMomentForCircle(mass, 0, 1, cpvzero);
		
		body = cpBodyNew(mass, moment);
		body->p = cpv(frame.origin.x, frame.origin.y);
        self.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        
		shape = cpCircleShapeNew(body, frame.size.width/2.0, cpvzero);
		shape->e = 0.3f;
		shape->u = 0.3f;
		shape->collision_type = 1;
        shape->data = self;
		
		
	}
	return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    [self buttonClicked];
}

- (void)drawRect:(CGRect)rect {
    
    CGFloat innerOffset = 0;
    CGRect innerRect = CGRectMake(innerOffset/2.0, innerOffset/2.0, rect.size.width-innerOffset/2.0, rect.size.height-innerOffset/2.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor orangeColor].CGColor);
    CGContextFillEllipseInRect(context, innerRect);
    
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:165.0/255.0 green:83.0/255.0 blue:0 alpha:1.0].CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(14, 15, 10, 10));
    CGContextFillEllipseInRect(context, CGRectMake(31, 15, 10, 10));
    CGContextFillEllipseInRect(context, CGRectMake(14, 31, 10, 10));
    CGContextFillEllipseInRect(context, CGRectMake(31, 31, 10, 10));
    
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:165.0/255.0 green:83.0/255.0 blue:0 alpha:1.0].CGColor);
    CGContextStrokeEllipseInRect(context, innerRect);
}

- (void) dealloc {
    
	
	[super dealloc];
}

@end
@implementation FallingButton(PrivateMethods)
- (CGAffineTransform)transformWithBody:(cpBody *)theBody {

    //works
    CGAffineTransform translate = CGAffineTransformMakeTranslation(theBody->p.x-25, theBody->p.y-25);    
    CGAffineTransform transform = CGAffineTransformRotate(translate, theBody->a);
     
    
    return transform;
}
@end