//
//  BWRotatingBumper.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BWRotatingBumper.h"
#import "BWChipmunkLayer.h"

@implementation BWRotatingBumper

+ (Class)layerClass {
    return [BWChipmunkLayer class];
}

- (id)init {
    if( (self = [super initWithFrame:CGRectMake(0, 0, 100, 100)]) ) {
        self.image = [UIImage imageNamed:@"RotatingBumper.png"];
        
        cpShapeFree(self.chipmunkLayer.shape);
        self.chipmunkLayer.shape = cpCircleShapeNew(self.chipmunkLayer.body, self.bounds.size.width/2.0-25, cpvzero);
        
        cpShapeSetElasticity(self.chipmunkLayer.shape, 1.0);
        cpShapeSetCollisionType(self.chipmunkLayer.shape, 5);
        cpBodySetMass(self.chipmunkLayer.body, 1000.0);
        
        cpBodySetUserData(self.chipmunkLayer.body, self);
        cpShapeSetUserData(self.chipmunkLayer.shape, self);
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
    cpSpaceAddBody(space, self.chipmunkLayer.body);
    cpSpaceAddShape(space, self.chipmunkLayer.shape);
    [self.chipmunkLayer updatePosition];
}

- (void)rotateTrappedButton:(BWButton *)button {
    cpBodySetAngVel(self.chipmunkLayer.body, 1);
    
}
@end
