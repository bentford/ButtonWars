//
//  BWRotatingBumper.h
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChipmunkLayerView.h"
#import "BWImageView.h"
#import "BWChipmunkLayerDelegate.h"

@class BWButton;
@interface BWRotatingBumper : UIImageView <ChipmunkLayerView, BWChipmunkLayerDelegate> {
    NSMutableSet *recentlyTrappedButtons;
    CGPoint trappedButtonPosition;
    
    UIImageView *baseView;
    
    CGFloat targetAngleInDegrees;
}

- (void)setupWithSpace:(cpSpace *)space position:(CGPoint)position;

- (void)trapButton:(BWButton *)button withSpace:(cpSpace *)space;

- (void)addRelatedViewsToView:(UIView *)parentView withTopMark:(UIView *)topMark bottomMark:(UIView *)bottomMark angle:(CGFloat)angle;
@end
