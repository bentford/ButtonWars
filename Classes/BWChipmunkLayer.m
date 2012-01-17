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
@synthesize chipmunkLayerDelegate;

+ (BOOL)needsDisplayForKey:(NSString *)key {
    if( [key isEqualToString:@"bodyPosition"] || 
        [key isEqualToString:@"bodyAngle"] ) 
        return YES;
    
    return [super needsDisplayForKey:key];
}

+ (cpShape *)shapeWithBody:(cpBody *)theBody size:(CGSize)shapeSize {
    return cpCircleShapeNew(theBody, shapeSize.width/2.0, cpvzero);
}

+ (CGFloat)momentForBodyWithSize:(CGSize)momentSize mass:(CGFloat)mass {
    return cpMomentForCircle(mass, 0, momentSize.width/2.0, cpvzero);
}

+ (cpBody *)bodyWithMass:(CGFloat)mass size:(CGSize)size {
    return cpBodyNew(mass, [[self class] momentForBodyWithSize:size mass:mass]);
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
            
            shape = [[self class] shapeWithBody:body size:CGSizeMake(width, height)];
            cpShapeSetFriction(shape, cpShapeGetFriction(bodyLayer.shape));
            cpShapeSetElasticity(shape, cpShapeGetElasticity(bodyLayer.shape));
            cpShapeSetCollisionType(shape, cpShapeGetCollisionType(bodyLayer.shape));            
        }
    }
    return self;
}

- (id)init {
    if( (self = [super init]) ) {

        body = [[self class] bodyWithMass:1.0 size:CGSizeMake(1.0, 1.0)];
        shape = [[self class] shapeWithBody:body size:CGSizeMake(1.0, 1.0)];
        cpShapeSetElasticity(shape, 0.7);
        cpShapeSetFriction(shape, 0.2);
        
        cpShapeSetCollisionType(shape, 1);
        self.chipmunkLayerDelegate = nil;
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
    
    if( newBounds.size.width != width || newBounds.size.height != height ) {
        
        cpShape *newShape = [[self class] shapeWithBody:body size:newBounds.size];
        cpBodySetMoment(body, [[self class] momentForBodyWithSize:newBounds.size mass:cpBodyGetMass(body)]);
        
        cpShapeSetFriction(newShape, cpShapeGetFriction(self.shape));
        cpShapeSetElasticity(newShape, cpShapeGetElasticity(self.shape));
        cpShapeSetCollisionType(newShape, cpShapeGetCollisionType(self.shape));
        
        cpShapeFree(self.shape);
        self.shape = newShape;
    }
    
    width = newBounds.size.width;
    height = newBounds.size.height;
}

- (void)setPosition:(CGPoint)position {
    
    cpBodySetPos(body, position);
    [self updatePosition];
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

- (CGPoint)bodyPosition {
    return self.position;
}

- (CGFloat)angle {
    return cpBodyGetAngle(self.body);
}

- (void)setAngle:(CGFloat)radians {
    cpBodySetAngle(self.body, radians);
}

- (void)setBodyPosition:(CGPoint)bodyPosition {
    [self.modelLayer setPosition:bodyPosition];
}

- (void)setBodyAngle:(CGFloat)radians {
    [(id<BWChipmunkLayerDelegate>)[self.modelLayer delegate] didRotateBodyToRadians:radians];
    [self.modelLayer setAngle:radians];
}

- (CGFloat)bodyAngle {
    return cpBodyGetAngle(self.body);
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