//
//  BWStaticCircleChipmunkLayer.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BWStaticCircleChipmunkLayer.h"

@implementation BWStaticCircleChipmunkLayer
+ (cpShape *)shapeWithBody:(cpBody *)theBody size:(CGSize)shapeSize {
    return cpCircleShapeNew(theBody, shapeSize.width/2.0, cpvzero);
}

+ (CGFloat)momentForBodyWithSize:(CGSize)momentSize mass:(CGFloat)mass {
    return cpMomentForCircle(mass, 0, momentSize.width, cpvzero);
}

+ (cpBody *)bodyWithMass:(CGFloat)mass size:(CGSize)size {
    return cpBodyNewStatic();
}
@end
