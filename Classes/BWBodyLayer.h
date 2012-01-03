//
//  BWBodyLayer.h
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "chipmunk.h"

@interface BWBodyLayer : CALayer {
    cpShape *shape;
    cpBody *body;
    
    CGFloat width;
    CGFloat height;

}

@property (nonatomic, assign) cpBody *body;
@property (nonatomic, assign) cpShape *shape;

- (void)updatePosition;

@end
