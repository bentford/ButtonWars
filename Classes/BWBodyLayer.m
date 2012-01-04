//
//  BWBodyLayer.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BWBodyLayer.h"

@interface BWBodyLayer(PrivateMethods)
- (CATransform3D)transformWithBody:(cpBody *)theBody;
@end

@implementation BWBodyLayer
@synthesize body;
@synthesize shape;

- (id)initWithLayer:(id)layer {
    if( (self = [super initWithLayer:layer] ) ) {
        if( [layer isKindOfClass:[BWBodyLayer class]] == YES ) {
            BWBodyLayer *bodyLayer = (BWBodyLayer *)layer;
            
            body = cpBodyNew(cpBodyGetMass(bodyLayer.body), cpBodyGetMoment(bodyLayer.body));
            cpBodySetPos(body, cpBodyGetPos(bodyLayer.body));
            cpBodySetAngle(body, cpBodyGetAngle(bodyLayer.body));
            cpBodySetMass(body, cpBodyGetMass(bodyLayer.body));
            cpBodySetMoment(body, cpBodyGetMoment(bodyLayer.body));
            
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
        NSLog(@"layer init");
        body = cpBodyNew(1.0, cpMomentForCircle(1.0, 0, 1.0, cpvzero));
        shape = cpCircleShapeNew(body, 1.0, cpvzero);
        cpShapeSetElasticity(shape, 0.7);
        cpShapeSetFriction(shape, 0.2);
        
        cpShapeSetCollisionType(shape, 1);
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    NSLog(@"setFrame: %@", NSStringFromCGRect(frame));
    
    width = frame.size.width;
    height = frame.size.height;
    
    cpBodySetPos(self.body, CGPointMake(frame.origin.x+width/2.0, frame.origin.y+height/2.0));

    if( frame.size.width != cpCircleShapeGetRadius(self.shape) || frame.size.height != cpCircleShapeGetRadius(self.shape) ) {

        cpShape *newShape = cpCircleShapeNew(self.body, frame.size.width/2.0, cpvzero);
        cpBodySetMoment(body, cpMomentForCircle(1.0, 0.0, frame.size.width/2.0, cpvzero));
        
        cpShapeSetFriction(newShape, cpShapeGetFriction(self.shape));
        cpShapeSetElasticity(newShape, cpShapeGetElasticity(self.shape));
        cpShapeSetCollisionType(newShape, cpShapeGetCollisionType(self.shape));
        
        cpShapeFree(self.shape);
        self.shape = newShape;
    }
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    NSLog(@"setBounds: %@", NSStringFromCGRect(bounds));
    width = bounds.size.width;
    height = bounds.size.height;
    
    if( bounds.size.width != cpCircleShapeGetRadius(self.shape) || bounds.size.height != cpCircleShapeGetRadius(self.shape) ) {
        
        cpShape *newShape = cpCircleShapeNew(self.body, bounds.size.width/2.0, cpvzero);
        cpBodySetMoment(body, cpMomentForCircle(1.0, 0.0, bounds.size.width/2.0, cpvzero));
        
        cpShapeSetFriction(newShape, cpShapeGetFriction(self.shape));
        cpShapeSetElasticity(newShape, cpShapeGetElasticity(self.shape));
        cpShapeSetCollisionType(newShape, cpShapeGetCollisionType(self.shape));
        
        cpShapeFree(self.shape);
        self.shape = newShape;
    }
}

- (void)setPosition:(CGPoint)position {
    [super setPosition:position];
    
    cpBodySetPos(body, position);
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

@implementation BWBodyLayer(PrivateMethods)
- (CATransform3D)transformWithBody:(cpBody *)theBody {
    //works
    CATransform3D translate = CATransform3DMakeTranslation(theBody->p.x-25, theBody->p.y-25, 0);
    
    //CATransform3D transform = CATransform3DRotate(translate, theBody->a, 0, 0, 1);
    
    
    return translate;
}
@end