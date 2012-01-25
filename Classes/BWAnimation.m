//
//  BWAnimation.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BWAnimation.h"
#import "BWChipmunkLayer.h"

// Bezier cubic formula:
//	((1 - t) + t)3 = 1 
// Expands to… 
//   (1 - t)3 + 3t(1-t)2 + 3t2(1 - t) + t3 = 1 
static inline float bezierat( float a, float b, float c, float d, CGFloat t )
{
	return (powf(1-t,3) * a + 
			3*t*(powf(1-t,2))*b + 
			3*powf(t,2)*(1-t)*c +
			powf(t,3)*d );
}

@implementation BWAnimation
@synthesize fromAngle;
@synthesize toAngle;
@synthesize fromPoint;
@synthesize toPoint;
@synthesize duration;
@synthesize timing;
@synthesize autoreverses;
@synthesize repeatCount;
@synthesize completionBlock;

+ (BWAnimation *)animation {
    return [[[BWAnimation alloc] init] autorelease];
}

- (id)init {
    if( (self = [super init]) ) {
        elapsedTime = 0.0f;
        hasFinished = NO;
        repeatCount = 0;
        totalRepeatIterations = 0;
        autoreverses = NO;
        autoreverseDirection = AutoReverseDirectionForward;
    }
    return self;
}

- (void)step:(CGFloat)timeDelta {
    elapsedTime += timeDelta;

    if( elapsedTime > duration ) {
        elapsedTime = 0;

        if( autoreverses == NO || (autoreverses == YES && autoreverseDirection == AutoReverseDirectionBackward) )
            totalRepeatIterations++;

        if( totalRepeatIterations > repeatCount )
            hasFinished = YES;
        
        if( autoreverses == YES ) {
            // flip direction
            if( autoreverseDirection == AutoReverseDirectionForward ) 
                autoreverseDirection = AutoReverseDirectionBackward;
            else if( autoreverseDirection == AutoReverseDirectionBackward ) 
                autoreverseDirection = AutoReverseDirectionForward;
            
            // swap positions
            CGPoint placeHolderPoint = fromPoint;
            fromPoint = toPoint;
            toPoint = placeHolderPoint;
            
            // swap angles
            CGFloat placeHolderAngle = fromAngle;
            fromAngle = toAngle;
            toAngle = placeHolderAngle;
        }
    }
}

- (BOOL)isFinished {
    return hasFinished;
}

- (void)updateBody:(BWChipmunkLayer *)body {
    
    CGFloat interpolation = elapsedTime / duration;
    
    if( (timing == BWAnimationTimingEaseIn && interpolation > 0.5) ||
        (timing == BWAnimationTimingEaseOut && interpolation < 0.5) ||
        timing == BWAnimationTimingEaseInEaseOut ) {
        
        CAMediaTimingFunction *easeIn = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];

        CGFloat *points = calloc(4, sizeof(CGFloat));
        CGFloat *calculationValues = calloc(2, sizeof(CGFloat));
        for( int i = 0; i < 4; i++ ) {
            
            [easeIn getControlPointAtIndex:i values:calculationValues];
            points[i] = calculationValues[1];
        }
        
        interpolation = bezierat(points[0], points[1], points[2], points[3], interpolation);

        free(points);
        free(calculationValues);
    }

    if( [self isRotating] == YES ) { 
        
        // rotate in the shortest direction
        CGFloat angleDelta = toAngle - fromAngle;
        if( angleDelta < M_PI )
            body.angle = fromAngle + angleDelta*interpolation;
        else
            body.angle = fromAngle - (RADIANS(360) - angleDelta)*interpolation;
    }
    
    if( [self isMoving] == YES ) {
        CGFloat xPos = fromPoint.x+(toPoint.x-fromPoint.x)*interpolation;
        CGFloat yPos = fromPoint.y+(toPoint.y-fromPoint.y)*interpolation;
        body.position = CGPointMake(xPos, yPos);
    }
}

- (BOOL)isRotating {
    return fromAngle != toAngle;
}

- (BOOL)isMoving {
    return CGPointEqualToPoint(fromPoint, toPoint) == NO;
}

- (void)dealloc {
    [self.completionBlock release];
    
    [super dealloc];
}
@end
