//
//  BWProgressBarAnimator.h
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ProgressDirectionNone,
    ProgressDirectionLeft,
    ProgressDirectionRight,
} ProgressDirection;

@protocol BWProgressAnimatorDelegate <NSObject>
- (void)valueMaxedOut:(ProgressDirection)maxedDirection;
@end

@class BWProgressBar;
@interface BWProgressBarAnimator : NSObject {
    NSMutableSet *bars;
    
    CGFloat value;
    CGFloat direction;
    
    BOOL hasMaxedOut;
}

@property (nonatomic, weak) id<BWProgressAnimatorDelegate> delegate;

- (void)addBar:(BWProgressBar *)bar;
- (void)removeBar:(BWProgressBar *)bar;

- (void)setRate:(CGFloat)newRate direction:(ProgressDirection)newDirection;

- (void)reset;
@end
