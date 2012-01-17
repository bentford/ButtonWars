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
@synthesize duration;
@synthesize timing;
@synthesize completionBlock;

+ (BWAnimation *)animation {
    return [[[BWAnimation alloc] init] autorelease];
}

- (id)init {
    if( (self = [super init]) ) {
        elapsedTime = 0.0f;
    }
    return self;
}

- (void)step:(CGFloat)timeDelta {
    elapsedTime += timeDelta;    
}

- (BOOL)isFinished {
    return elapsedTime > duration;
}

- (void)updateBody:(BWChipmunkLayer *)body {

    body.angle = fromAngle + (toAngle-fromAngle)*(elapsedTime/duration);
}

- (BOOL)isRotating {
    return fromAngle != toAngle;
}

- (BOOL)isMoving {
    return NO;
}

- (void)dealloc {
    [self.completionBlock release];
    
    [super dealloc];
}
@end
