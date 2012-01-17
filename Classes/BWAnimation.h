//
//  BWAnimation.h
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    BWAnimationTimingLinear = 0,
    BWAnimationTimingEaseIn = 1,
    BWAnimationTimingEaseOut = 2,
    BWAnimationTimingEaseInEaseOut = 3,
} BWAnimationTiming;

typedef enum {
    AutoReverseDirectionForward = 0,
    AutoReverseDirectionBackward = 1,
} AutoReverseDirection;

@class BWChipmunkLayer;
@interface BWAnimation : NSObject {
    CGFloat elapsedTime;
    NSUInteger totalRepeatIterations;
    BOOL hasFinished;
    AutoReverseDirection autoreverseDirection;
    
}

+ (BWAnimation *)animation;

@property (nonatomic, assign) CGFloat fromAngle;
@property (nonatomic, assign) CGFloat toAngle;

@property (nonatomic, assign) CGPoint fromPoint;
@property (nonatomic, assign) CGPoint toPoint;

@property (nonatomic, assign) BOOL autoreverses;

@property (nonatomic, assign) NSUInteger repeatCount;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, assign) BWAnimationTiming timing;


@property (nonatomic, copy) void (^completionBlock)(void);

- (void)step:(CGFloat)timeDelta;
- (void)updateBody:(BWChipmunkLayer *)body;
- (BOOL)isFinished;

- (BOOL)isRotating;
- (BOOL)isMoving;

@end
