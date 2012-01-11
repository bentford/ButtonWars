//
//  BWRotatingBumper.h
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChipmunkLayerView.h"

@interface BWRotatingBumper : UIImageView <ChipmunkLayerView> 

- (void)setupWithSpace:(cpSpace *)space position:(CGPoint)position;

@end
