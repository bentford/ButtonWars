//
//  BWBodyLayer.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BWChipmunkLayer.h"

@interface BWChipmunkLayer(PrivateMethods)
- (CATransform3D)transformWithBody:(cpBody *)theBody;
@end

@implementation BWChipmunkLayer
@synthesize body;
@synthesize shape;

+ (BOOL)needsDisplayForKey:(NSString *)key {
    if( [key isEqualToString:@"bodyPosition"] ) 
        return YES;
    
    return [super needsDisplayForKey:key];
}

- (id)initWithLayer:(id)layer {
    if( (self = [super initWithLayer:layer] ) ) {
        if( [layer isKindOfClass:[BWChipmunkLayer class]] == YES ) {
            BWChipmunkLayer *bodyLayer = (BWChipmunkLayer *)layer;
            
            body = cpBodyNew(cpBodyGetMass(bodyLayer.body), cpBodyGetMoment(bodyLayer.body));
            cpBodySetPos(body, cpBodyGetPos(bodyLayer.body));
            cpBodySetAngle(body, cpBodyGetAngle(bodyLayer.body));
            cpBodySetMass(body, cpBodyGetMass(bodyLayer.body));
            cpBodySetMoment(body, cpBodyGetMoment(bodyLayer.body));
            cpBodySetUserData(body, cpBodyGetUserData(bodyLayer.body));
            
            shape = cpCircleShapeNew(body, cpCircleShapeGetRadius(bodyLayer.shape), cpvzero);
            cpShapeSetFriction(shape, cpShapeGetFriction(bodyLayer.shape));
            cpShapeSetElasticity(shape, cpShapeGetElasticity(bodyLayer.shape));
            cpShapeSetCollisionType(shape, cpShapeGetCollisionType(bodyLayer.shape));
        }
    }
    return self;
}

- (id)init {
    if( (self = [super init]) ) {

        body = cpBodyNew(1.0, cpMomentForCircle(1.0, 0, 1.0, cpvzero));
        shape = cpCircleShapeNew(body, 1.0, cpvzero);
        cpShapeSetElasticity(shape, 0.7);
        cpShapeSetFriction(shape, 0.2);
        
        cpShapeSetCollisionType(shape, 1);
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    
    width = frame.size.width;
    height = frame.size.height;
    
    self.bounds = CGRectMake(0, 0, frame.size.width, frame.size.height);
    self.position = frame.origin;
}

- (CGRect)frame {
    return CGRectMake(self.position.x, self.position.y, self.bounds.size.width, self.bounds.size.height);
}

- (void)setBounds:(CGRect)newBounds {
    [super setBounds:newBounds];
    width = newBounds.size.width;
    height = newBounds.size.height;
    
    if( newBounds.size.width != cpCircleShapeGetRadius(self.shape) || newBounds.size.height != cpCircleShapeGetRadius(self.shape) ) {
        
        cpShape *newShape = cpCircleShapeNew(self.body, newBounds.size.width/2.0, cpvzero);
        cpBodySetMoment(body, cpMomentForCircle(1.0, 0.0, newBounds.size.width/2.0, cpvzero));
        
        cpShapeSetFriction(newShape, cpShapeGetFriction(self.shape));
        cpShapeSetElasticity(newShape, cpShapeGetElasticity(self.shape));
        cpShapeSetCollisionType(newShape, cpShapeGetCollisionType(self.shape));
        
        cpShapeFree(self.shape);
        self.shape = newShape;
    }
}

- (void)setPosition:(CGPoint)position {
    
    cpBodySetPos(body, position);
}

- (CGPoint)position {
    return cpBodyGetPos(body);
}

- (void)updatePosition {
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:0.0]
                     forKey:kCATransactionAnimationDuration];

	self.transform = [self transformWithBody:body];
    
    [CATransaction commit];
}

- (void)dealloc {
    cpShapeFree(shape);
    cpBodyFree(body);
    
    [super dealloc];
}
@end

@implementation BWChipmunkLayer(PrivateMethods)
- (CATransform3D)transformWithBody:(cpBody *)theBody {
    
    CATransform3D translate = CATransform3DMakeTranslation(theBody->p.x, theBody->p.y, 0);
    CATransform3D transform = CATransform3DRotate(translate, theBody->a, 0, 0, 1);
    
    return transform;
}
@end