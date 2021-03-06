//
//  BWStaticBoxChipmunkLayer.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BWStaticBoxChipmunkLayer.h"

@implementation BWStaticBoxChipmunkLayer
+ (cpShape *)shapeWithBody:(cpBody *)theBody size:(CGSize)shapeSize {
    return cpBoxShapeNew(theBody, shapeSize.width, shapeSize.height);
}

+ (CGFloat)momentForBodyWithSize:(CGSize)momentSize mass:(CGFloat)mass {
    return cpMomentForBox(mass, momentSize.width, momentSize.height);
}

+ (cpBody *)bodyWithMass:(CGFloat)mass size:(CGSize)size {
    return cpBodyNewStatic();
}
@end
