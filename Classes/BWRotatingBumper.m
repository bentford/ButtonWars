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
- (void)fireButton:(BWButton *)button;
- (void)fireCurrentlyTrappedButton;
@end

@implementation BWRotatingBumper
@synthesize trappedButton;

+ (Class)layerClass {
    return [BWChipmunkLayer class];
}

- (id)init {
    if( (self = [super initWithFrame:CGRectMake(0, 0, 200, 200)]) ) {
        self.image = [UIImage imageNamed:@"RotatingBumper.png"];

        cpShapeFree(self.chipmunkLayer.shape);
        self.chipmunkLayer.shape = cpCircleShapeNew(self.chipmunkLayer.body, 30, cpvzero);
        
        cpShapeSetElasticity(self.chipmunkLayer.shape, 1.0);
        cpShapeSetCollisionType(self.chipmunkLayer.shape, 5);
        cpBodySetMass(self.chipmunkLayer.body, INFINITY);
        
        cpShapeSetSensor(self.chipmunkLayer.shape, YES);
        
        cpBodySetUserData(self.chipmunkLayer.body, self);
        cpShapeSetUserData(self.chipmunkLayer.shape, self);
        
        self.chipmunkLayer.chipmunkLayerDelegate = self;

        self.trappedButton = nil;
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
    if( self.trappedButton != nil ) 
        [self fireButton:self.trappedButton];
    
    self.trappedButton = button;
    
    // freeze button
    button.ignoreGuideForce = YES;
    cpBodySetVel(button.chipmunkLayer.body, cpvzero);    
    cpBodySetAngVel(button.chipmunkLayer.body, 0);
    
    
    // rotate the button
    cpVect localButtonPosition = cpBodyWorld2Local(self.chipmunkLayer.body, cpBodyGetPos(button.chipmunkLayer.body));
    
    CGFloat angleOffset = targetAngleInDegrees-DEGREES(cpvtoangle(cpvrotate(cpvnormalize(localButtonPosition), cpvforangle(self.chipmunkLayer.angle))));
    
    CGFloat fromAngle = cpBodyGetAngle(self.chipmunkLayer.body);
    CGFloat toAngle = cpBodyGetAngle(self.chipmunkLayer.body) + RADIANS(angleOffset);
    
    CGFloat angleDelta = 0;
    if( (toAngle - fromAngle) > M_PI ) 
        angleDelta = RADIANS(360) - (toAngle - fromAngle);
    else
        angleDelta = toAngle - fromAngle;
    
    
    self.trappedButtonPosition = localButtonPosition;

    [self.chipmunkLayer cancelAllAnimations];
    
    BWAnimation *rotation = [BWAnimation animation];
    rotation.fromAngle = fromAngle;
    rotation.toAngle = toAngle;
    rotation.duration = (angleDelta / RADIANS(90.0f) ) * 1.0f;
    rotation.timing = BWAnimationTimingEaseInEaseOut;
    rotation.completionBlock = ^{

        [self fireCurrentlyTrappedButton];
    };
    
    [self.chipmunkLayer addBWAnimation:rotation];
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

- (void)addRelatedViewsToView:(UIView *)parentView withTopMark:(UIView *)topMark bottomMark:(UIView *)bottomMark angle:(CGFloat)angle {
    
    [baseView release];
    baseView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RotatingBumperBase.png"]];
    [baseView sizeToFit];
    baseView.center = CGPointMake(self.center.x, self.center.y);
    
    baseView.transform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(angle), 45, 0);;
    targetAngleInDegrees = DEGREES(angle);
    
    [parentView insertSubview:baseView belowSubview:bottomMark];
}

- (void)removeFromSuperview {
    if( baseView != nil && baseView.superview != nil )
        [baseView removeFromSuperview];

    [super removeFromSuperview];
}

@end

@implementation BWRotatingBumper(PrivateMethods)
- (void)fireCurrentlyTrappedButton {
    [self fireButton:self.trappedButton];
    self.trappedButton = nil;
}

- (void)fireButton:(BWButton *)button {
    
    button.ignoreGuideForce = NO;
    
    cpVect collisionVector = cpvnormalize(cpvsub(cpBodyGetPos(self.chipmunkLayer.body), cpBodyGetPos(button.chipmunkLayer.body)));
    cpVect invertedCollisionVector = cpvrotate(collisionVector, cpvforangle(M_PI));
    cpVect impulseVector = cpvmult(invertedCollisionVector, 1000);
    
    cpBodyApplyImpulse(button.chipmunkLayer.body, impulseVector, cpvzero);
}
@end