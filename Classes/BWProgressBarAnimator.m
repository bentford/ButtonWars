//
//  BWProgressBarAnimator.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BWProgressBarAnimator.h"
#import "BWProgressBar.h"

#define kDelta 0.005f

@interface BWProgressBarAnimator()
@property (nonatomic, retain) NSTimer *rateTimer;
@end

@interface BWProgressBarAnimator(PrivateMethods)
@end

@implementation BWProgressBarAnimator
@synthesize rateTimer;

- (id)init {
    if( (self = [super init]) ) {
        bars = [[NSMutableSet alloc] initWithCapacity:2];
        value = 0.5f;
    }
    return self;
}

- (void)addBar:(BWProgressBar *)bar {
    [bars addObject:bar];
}

- (void)removeBar:(BWProgressBar *)bar {
    [bars removeObject:bar];
}

- (void)setRate:(CGFloat)newRate direction:(ProgressDirection)newDirection {
    direction = newDirection;
    
    [self.rateTimer invalidate];
    self.rateTimer = [NSTimer scheduledTimerWithTimeInterval:newRate target:self selector:@selector(tickRateTimer:) userInfo:nil repeats:YES];
}

- (void)dealloc {
    [super dealloc];
    
    [self.rateTimer invalidate];
    self.rateTimer = nil;
    
    [bars release];
}
@end

@implementation BWProgressBarAnimator(PrivateMethods)
- (void)tickRateTimer:(NSTimer *)rateTimer {
    CGFloat delta = 0;
    if( direction == ProgressDirectionLeft )
        delta = -kDelta;
    else if( direction == ProgressDirectionRight )
        delta = kDelta;
    
    if( delta == 0 )
        return;
    
    value += delta;
    
    for( BWProgressBar *bar in bars )
        [bar setCurrentValue:value];
}
@end