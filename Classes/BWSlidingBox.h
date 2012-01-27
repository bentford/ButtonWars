//
//  BWSlidingBox.h
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChipmunkLayerView.h"
#import "AnimatedChipmunkLayer.h"

typedef enum {
    BWSlidingBoxDirectionStopped,
    BWSlidingBoxDirectionVertical,
    BWSlidingBoxDirectionHorizontal,
} BWSlidingBoxDirection;

@interface BWSlidingBox : UIImageView <ChipmunkLayerView, AnimatedChipmunkLayer> {
    CGPoint animationStartPoint;
    
    CGFloat slideAmount;
    BWSlidingBoxDirection slideDirection;
}

@property (nonatomic, assign) CGFloat slideAmount;
@property (nonatomic, assign) BWSlidingBoxDirection slideDirection;

- (void)startAnimation;
- (void)stopAnimation;

@end
