//
//  UIImageViewCircleBody.h
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 11/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UIImageViewBody.h"
#import "chipmunk.h"

@interface UIImageViewCircleBody : UIImageViewBody {
    
}

- (void)setStaticBody:(cpBody *)staticBody position:(CGPoint)position;
@end
