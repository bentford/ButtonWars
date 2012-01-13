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

void postStepTrapButton(cpSpace *space, void *obj, void *data);
void postStepRemoveConstraint(cpSpace *space, void *obj, void *data);
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

- (void)trapButton:(BWButton *)button withSpace:(cpSpace *)space {
    if( [recentlyTrappedButtons containsObject:button] )
        return;

    // freeze button
    button.ignoreGuideForce = YES;
    cpBodySetVel(button.chipmunkLayer.body, cpvzero);    
    cpBodySetAngVel(button.chipmunkLayer.body, 0);
    
    // ignore collisions for this button button for a short moment
    [recentlyTrappedButtons addObject:button];
    [self performSelector:@selector(forgetButton:) withObject:button afterDelay:3.2];
    
    cpSpaceAddPostStepCallback(space, (cpPostStepFunc)postStepTrapButton, button, self);
}
@end

@implementation BWRotatingBumper(PrivateMethods)
- (void)forgetButton:(BWButton *)button {
    [recentlyTrappedButtons removeObject:button];
}

- (void)fireTrappedButton:(NSArray *)parameters {
    BWButton *button = [parameters objectAtIndex:0];
    cpConstraint *groove = (cpConstraint *)[((NSValue *)[parameters objectAtIndex:1]) pointerValue];
    cpConstraint *pin = (cpConstraint *)[((NSValue *)[parameters objectAtIndex:2]) pointerValue];
    cpSpace *space = (cpSpace *)[((NSValue *)[parameters objectAtIndex:3]) pointerValue];
    

    cpBodySetAngVel(self.chipmunkLayer.body, 0);
    cpBodySetTorque(self.chipmunkLayer.body, 0);
    
    cpSpaceRemoveConstraint(space, pin);
    cpSpaceRemoveConstraint(space, groove);
    
    button.ignoreGuideForce = NO;
    
    cpVect collisionVector = cpvnormalize(cpvsub(cpBodyGetPos(self.chipmunkLayer.body), cpBodyGetPos(button.chipmunkLayer.body)));
    cpVect invertedCollisionVector = cpvrotate(collisionVector, cpvforangle(M_PI));
    cpVect impulseVector = cpvmult(invertedCollisionVector, 1000);
    
    cpBodyApplyImpulse(button.chipmunkLayer.body, impulseVector, cpvzero);
}

void postStepTrapButton(cpSpace *space, void *obj, void *data) {
    BWButton *button = obj;
    BWRotatingBumper *bumper = data;
    
    cpVect localButtonPosition = cpBodyWorld2Local(bumper.chipmunkLayer.body, cpBodyGetPos(button.chipmunkLayer.body));
    
    cpConstraint *groove = cpGrooveJointNew(bumper.chipmunkLayer.body, button.chipmunkLayer.body, cpv(0,0), localButtonPosition, cpvzero);
    cpConstraint *pin = cpPinJointNew(bumper.chipmunkLayer.body, button.chipmunkLayer.body, cpvzero, cpvzero);
    cpSpaceAddConstraint(space, groove);
    cpSpaceAddConstraint(space, pin);
    
    cpBodySetAngVel(bumper.chipmunkLayer.body, 4);
    
    // fire button after delay
    NSArray *parameters = [NSArray arrayWithObjects:button,[NSValue valueWithPointer:groove], [NSValue valueWithPointer:pin], [NSValue valueWithPointer:space], nil];
    [bumper performSelector:@selector(fireTrappedButton:) withObject:parameters afterDelay:1.0];
}


@end