//
//  BWRotatingBumper.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BWRotatingBumper.h"
#import "BWChipmunkLayer.h"
#import "BWButton.h"

@interface BWRotatingBumper(PrivateMethods)
- (void)forgetButton:(BWButton *)button;
@end

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
        cpBodySetMass(self.chipmunkLayer.body, INFINITY);
        
        cpShapeSetSensor(self.chipmunkLayer.shape, YES);
        
        cpBodySetUserData(self.chipmunkLayer.body, self);
        cpShapeSetUserData(self.chipmunkLayer.shape, self);
        
        recentlyTrappedButtons = [[NSMutableSet alloc] initWithCapacity:2];
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

- (BOOL)trapButton:(BWButton *)button {
    if( [recentlyTrappedButtons containsObject:button] )
        return NO;
    
    cpVect buttonPoint = cpBodyWorld2Local(self.chipmunkLayer.body, cpBodyGetPos(button.chipmunkLayer.body));
    NSLog(@"button point: %@", NSStringFromCGPoint(buttonPoint));
    cpBodySetAngVel(self.chipmunkLayer.body, 1);
    
    [recentlyTrappedButtons addObject:button];
    [self performSelector:@selector(forgetButton:) withObject:button afterDelay:2.0];
    return YES;
}
@end

@implementation BWRotatingBumper(PrivateMethods)
- (void)forgetButton:(BWButton *)button {
    [recentlyTrappedButtons removeObject:button];
}
@end