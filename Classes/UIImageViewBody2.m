//
//  UIImageViewBody2.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImageViewBody2.h"
#import "BWChipmunkLayer.h"

@implementation UIImageViewBody2

+ (Class)layerClass {
    return [BWChipmunkLayer class];
}

- (BWChipmunkLayer *)bodyLayer {
    return (BWChipmunkLayer *)self.layer;
}
@end
