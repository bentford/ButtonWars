//
//  BWButton.h
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameData.h"
#import "ChipmunkLayerView.h"

@interface BWButton : UIImageView <ChipmunkLayerView> {
    ButtonColor color;
    BOOL canDie;
    
    CGPoint currentGuideVector;
}

- (id)initWithColor:(ButtonColor)aColor;

@property (nonatomic, readonly) ButtonColor color;
@property (nonatomic, readonly) BOOL canDie;

- (void)guideTowardPoint:(CGPoint)guidePoint;
- (void)guideTowardPlaneOfPoint:(CGPoint)guidePoint;

- (void)applyImpulseWithVector:(CGPoint)baseVector basedOnDistance:(CGFloat)distance;
@end
