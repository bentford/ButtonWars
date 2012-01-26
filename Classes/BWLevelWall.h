//
//  BWLevelWall.h
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChipmunkLayerView.h"

@interface BWLevelWall : UIImageView <ChipmunkLayerView> {
    
}
- (id)initWithLength:(CGFloat)newLength;
@end
