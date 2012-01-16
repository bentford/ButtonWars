//
//  BWSlidingBox.h
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChipmunkLayerView.h"

@interface BWSlidingBox : UIView <ChipmunkLayerView>

- (void)startAnimation;
- (void)stopAnimation;

@end
