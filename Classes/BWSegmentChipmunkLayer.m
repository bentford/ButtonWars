//
//  BWSegmentChipmunkLayer.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BWSegmentChipmunkLayer.h"

@implementation BWSegmentChipmunkLayer
+ (cpShape *)shapeWithBody:(cpBody *)theBody size:(CGSize)shapeSize {
    return cpSegmentShapeNew(theBody, cpvzero, cpv(shapeSize.width, shapeSize.height), 0);
}

+ (CGFloat)momentForBodyWithSize:(CGSize)momentSize mass:(CGFloat)mass {
    return cpMomentForSegment(mass, cpvzero, cpv(momentSize.width, momentSize.height));
}

+ (cpBody *)bodyWithMass:(CGFloat)mass size:(CGSize)size {
    return cpBodyNew(mass, [[self class] momentForBodyWithSize:size mass:mass]);
}
@end
