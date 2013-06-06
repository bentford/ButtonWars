//
//  BWSlidingBoxWithBounce.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BWSlidingBoxWithBounce.h"
#import "BWChipmunkLayer.h"
#import "BWButton.h"

@implementation BWSlidingBoxWithBounce
- (id)init {
    if( (self = [super init]) ) {
        self.image = [UIImage imageNamed:@"Sliding-Block-with-Bounce.png"];
        
        cpVect verts[4] = {cpv(-23,-25), cpv(23,-25), cpv(23,-30), cpv(-23,-30) };
        bounceSurface = cpPolyShapeNew(self.chipmunkLayer.body, 4, verts, cpvzero);

        cpShapeSetCollisionType(bounceSurface, 7);
        cpShapeSetUserData(bounceSurface, (__bridge cpDataPointer)(self));
    }
    return self;
}

- (void)setupWithSpace:(cpSpace *)space position:(CGPoint)position {
    [super setupWithSpace:space position:position];
    cpSpaceAddShape(space, bounceSurface);
}

- (void)removeFromSpace:(cpSpace *)space {
    [super removeFromSpace:space];
    cpSpaceRemoveShape(space, bounceSurface);
}

- (void)bumpButton:(BWButton *)button withSpace:(cpSpace *)space {
    cpBodySetVel(button.chipmunkLayer.body, cpvzero);
    cpBodyApplyImpulse(button.chipmunkLayer.body, cpv(0,-800), cpvzero);
}
@end
