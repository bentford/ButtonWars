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

@class BWProgressBar;
@interface BWProgressBarAnimator : NSObject {
    NSMutableSet *bars;
    
    CGFloat value;
    CGFloat direction;
}

- (void)addBar:(BWProgressBar *)bar;
- (void)removeBar:(BWProgressBar *)bar;

- (void)setRate:(CGFloat)newRate direction:(ProgressDirection)newDirection;
@end
