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
@interface BWRotatingBumper()
@property (nonatomic, assign) CGPoint trappedButtonPosition;
@property (nonatomic, assign) BWButton *trappedButton;
@end

@interface BWRotatingBumper(PrivateMethods)
- (void)forgetButton:(BWButton *)button;

void postStepTrapButton(cpSpace *space, void *obj, void *data);
void postStepRemoveConstraint(cpSpace *space, void *obj, void *data);

- (void)fireTrappedButton:(BWButton *)button;
@end

@implementation BWRotatingBumper
@synthesize trappedButton;

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
        
        self.chipmunkLayer.chipmunkLayerDelegate = self;
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
    self.center = position;
    cpSpaceAddBody(space, self.chipmunkLayer.body);
    cpSpaceAddShape(space, self.chipmunkLayer.shape);
}

- (void)removeFromSpace:(cpSpace *)space {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    cpSpaceRemoveShape(space, self.chipmunkLayer.shape);
    cpSpaceRemoveBody(space, self.chipmunkLayer.body);
}

- (void)trapButton:(BWButton *)button withSpace:(cpSpace *)space {
    if( [recentlyTrappedButtons count] > 0 )
        return;

    // freeze button
    button.ignoreGuideForce = YES;
    cpBodySetVel(button.chipmunkLayer.body, cpvzero);    
    cpBodySetAngVel(button.chipmunkLayer.body, 0);
    
    // ignore collisions for this button button for a short moment
    [recentlyTrappedButtons addObject:button];
    [self performSelector:@selector(forgetButton:) withObject:button afterDelay:1.0];
    
    cpSpaceAddPostStepCallback(space, (cpPostStepFunc)postStepTrapButton, button, self);
}

#pragma mark BWChipmunkLayerDelegate
- (void)didRotateBodyToRadians:(CGFloat)radians {
    trappedButton.center = [self convertPoint:CGPointMake(self.bounds.size.width/2.0+trappedButtonPosition.x, self.bounds.size.height/2.0+trappedButtonPosition.y) toView:self.superview]; 
}
#pragma mark -

- (void)setTrappedButtonPosition:(CGPoint)newTrappedButtonPosition {
    trappedButtonPosition = newTrappedButtonPosition;
}

- (CGPoint)trappedButtonPosition {
    return trappedButtonPosition;
}

#ifdef kDebugTrappedButtonPoint
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(self.bounds.size.width/2.0+trappedButtonPosition.x-5, self.bounds.size.height/2.0+trappedButtonPosition.y-5, 10, 10));
}
#endif

@end

@implementation BWRotatingBumper(PrivateMethods)
- (void)forgetButton:(BWButton *)button {
    [recentlyTrappedButtons removeObject:button];
}

- (void)fireTrappedButton:(BWButton *)button {
    
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
    bumper.trappedButtonPosition = localButtonPosition;
    bumper.trappedButton = button;
    
    CGFloat degrees = 90;
    if( button.color == ButtonColorGreen )
        degrees = -90;
    
    BWAnimation *rotation = [BWAnimation animation];
    rotation.fromAngle = cpBodyGetAngle(bumper.chipmunkLayer.body);
    rotation.toAngle = cpBodyGetAngle(bumper.chipmunkLayer.body) + RADIANS(degrees);
    rotation.duration = 2.0f;
    rotation.timing = BWAnimationTimingEaseInEaseOut;
    rotation.completionBlock = ^{
        [bumper fireTrappedButton:button];
    };
    [bumper.chipmunkLayer addBWAnimation:rotation];
}
@end