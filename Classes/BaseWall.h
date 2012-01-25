//
//  BaseWall.h
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChipmunkLayerView.h"

typedef enum {
    BaseWallDirectionNormal,
    BaseWallDirectionFlippedHorizontal,
    BaseWallDirectionFlippedVertical,
    BaseWallDirectionFlippedBoth,
} BaseWallDirection;

@interface BaseWall : UIImageView <ChipmunkLayerView> {
    
}

- (id)initWithDirection:(BaseWallDirection)direction;
@end
