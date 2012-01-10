//
//  BWScorePost.h
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChipmunkLayerView.h"
#import "GameData.h"

@interface BWScorePost : UIImageView <ChipmunkLayerView> {
    ButtonColor buttonColor;
}
@property (nonatomic, assign) ButtonColor buttonColor;
@end
