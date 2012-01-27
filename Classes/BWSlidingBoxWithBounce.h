//
//  BWSlidingBoxWithBounce.h
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BWSlidingBox.h"

@class BWButton;
@interface BWSlidingBoxWithBounce : BWSlidingBox {
    cpShape *bounceSurface;
}

- (void)bumpButton:(BWButton *)button withSpace:(cpSpace *)space;
@end
