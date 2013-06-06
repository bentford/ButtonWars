//
//  BWBodyLayer.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BWChipmunkLayer.h"
#import "BWAnimation.h"
#import "NSObject+PerformBlockAfterDelay.h"

@interface BWChipmunkLayer(PrivateMethods)
- (CATransform3D)transformWithBody:(cpBody *)theBody;
- (void)processAnimationsWithTimeDelta:(CGFloat)timeDelta;
@end

@implementation BWChipmunkLayer
@synthesize body;
@synthesize shape;
@synthesize chipmunkLayerDelegate;

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
        
        bwAnimations = [[NSMutableArray alloc] init];
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

- (CGFloat)angle {
    return cpBodyGetAngle(self.body);
}

- (void)setAngle:(CGFloat)angle {
    cpBodySetAngle(self.body, angle);
}

- (void)updatePosition {
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue
                     forKey:kCATransactionDisableActions];
    
	self.transform = [self transformWithBody:body];
    
    [CATransaction commit];
}

- (void)step:(CGFloat)timeDelta {
    [self processAnimationsWithTimeDelta:timeDelta];
    
    [self updatePosition];
    
}

- (void)addBWAnimation:(BWAnimation *)animation {
    [bwAnimations addObject:animation];
}

- (void)cancelAllAnimations {
    [bwAnimations removeAllObjects];
}

- (void)dealloc {
    cpShapeFree(shape);
    cpBodyFree(body);
    
}
@end

@implementation BWChipmunkLayer(PrivateMethods)
- (CATransform3D)transformWithBody:(cpBody *)theBody {
    
    CATransform3D translate = CATransform3DMakeTranslation(theBody->p.x, theBody->p.y, 0);
    CATransform3D transform = CATransform3DRotate(translate, theBody->a, 0, 0, 1);
    
    return transform;
}

- (void)processAnimationsWithTimeDelta:(CGFloat)timeDelta {
    if( [bwAnimations count] == 0 )
        return;
    
    NSMutableSet *toRemove = [NSMutableSet setWithCapacity:0];
    for( BWAnimation *animation in bwAnimations ) {
        
        [animation step:timeDelta];
        
        if( [animation isFinished] == YES ) {
            [toRemove addObject:animation];
            continue;
        }

        [animation updateBody:self];
        
        if( [animation isRotating] == YES )
            [chipmunkLayerDelegate didRotateBodyToRadians:cpBodyGetAngle(self.body)];
    }
    
    for( BWAnimation *completedAnimation in toRemove )
        // performs in main runloop, the delay isn't the intention
        [self performBlock:completedAnimation.completionBlock afterDelay:0.0]; 
    
    [bwAnimations removeObjectsInArray:[toRemove allObjects]];

}
@end