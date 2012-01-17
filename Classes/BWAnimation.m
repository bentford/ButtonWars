//
//  BWAnimation.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BWAnimation.h"
#import "BWChipmunkLayer.h"


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

    if( [self isRotating] == YES ) 
        body.angle = fromAngle + (toAngle-fromAngle)*interpolation;
    
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
