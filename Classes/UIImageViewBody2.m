//
//  UIImageViewBody2.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImageViewBody2.h"
#import "BWBodyLayer.h"

@implementation UIImageViewBody2

+ (Class)layerClass {
    return [BWBodyLayer class];
}

- (BWBodyLayer *)bodyLayer {
    return (BWBodyLayer *)self.layer;
}
@end