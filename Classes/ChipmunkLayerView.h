//
//  ChipmunkLayerView.h
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "chipmunk.h"

@class BWChipmunkLayer;
@protocol ChipmunkLayerView <NSObject>
- (BWChipmunkLayer *)chipmunkLayer;
@end
