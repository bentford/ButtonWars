//
//  BWBumper.h
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChipmunkLayerView.h"


@interface BWBumper : UIImageView <ChipmunkLayerView> 

@property (nonatomic, assign) BOOL isBumping;

- (void)setupWithSpace:(cpSpace *)space position:(CGPoint)position;
@end
