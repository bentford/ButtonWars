//
//  BWBumper.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BWBumper.h"
#import "BWChipmunkLayer.h"

@implementation BWBumper
@synthesize isBumping;

+ (Class)layerClass {
    return [BWChipmunkLayer class];
}

- (id)init {
    if( (self = [super initWithFrame:CGRectMake(0, 0, 100, 100)]) ) {
        self.image = [UIImage imageNamed:@"Bumper_v2.png"];
        cpShapeSetElasticity(self.chipmunkLayer.shape, 1.0);
        cpShapeSetCollisionType(self.chipmunkLayer.shape, 3);
        cpBodySetMass(self.chipmunkLayer.body, 100.0);
        
        cpBodySetUserData(self.chipmunkLayer.body, self);
        cpShapeSetUserData(self.chipmunkLayer.shape, self);
        
        isBumping = NO;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    NSAssert(NO, @"use init instead");
    return nil;
}

- (BWChipmunkLayer *)chipmunkLayer {
    return (BWChipmunkLayer *)self.layer;
}

- (void)setupWithSpace:(cpSpace *)space position:(CGPoint)position {
    cpBodySetPos(self.chipmunkLayer.body, position);
    cpSpaceAddShape(space, self.chipmunkLayer.shape);
    [self.chipmunkLayer updatePosition];
}

@end
