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

@class BWButton;
@interface BWRotatingBumper : BWImageView <ChipmunkLayerView> {
    NSMutableSet *recentlyTrappedButtons;
}

- (void)setupWithSpace:(cpSpace *)space position:(CGPoint)position;

- (void)trapButton:(BWButton *)button withSpace:(cpSpace *)space;

@end
