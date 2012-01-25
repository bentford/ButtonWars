//
//  BWSlidingBox.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BWSlidingBox.h"
#import "BWBoxChipmunkLayer.h"

@implementation BWSlidingBox

+ (Class)layerClass {
    return [BWBoxChipmunkLayer class];
}

- (id)init {
    if( (self = [super initWithFrame:CGRectMake(0, 0, 150, 150)]) ) {
        self.image = [UIImage imageNamed:@"Sliding-BLock.png"];
        
        
        cpBodySetMass(self.chipmunkLayer.body, INFINITY);
        cpBodySetMoment(self.chipmunkLayer.body, cpMomentForBox(INFINITY, 50, 50));
        
        cpShapeFree(self.chipmunkLayer.shape);
        cpBoxShapeNew(self.chipmunkLayer.body, 50, 50);
        cpShapeSetElasticity(self.chipmunkLayer.shape, 0.3f);
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


#pragma mark ChipmunkLayerView
- (BWChipmunkLayer *)chipmunkLayer {
    return (BWChipmunkLayer *)self.layer;
}

- (void)setupWithSpace:(cpSpace *)space position:(CGPoint)position {
    self.center = position;
    
    animationStartPoint = position;
    
    cpSpaceAddBody(space, self.chipmunkLayer.body);
    cpSpaceAddShape(space, self.chipmunkLayer.shape);
}

- (void)removeFromSpace:(cpSpace *)space {
    [self stopAnimation];
    cpSpaceRemoveShape(space, self.chipmunkLayer.shape);
    cpSpaceRemoveBody(space, self.chipmunkLayer.body);
}
#pragma mark -

#pragma mark AnimatedChipmunkLayer
- (void)startAnimation {
    NSUInteger fromPos = animationStartPoint.x - 100;
    NSUInteger toPos = animationStartPoint.x + 100;
    
    BWAnimation *animation = [BWAnimation animation];
    animation.fromPoint = CGPointMake(fromPos, self.center.y);
    animation.toPoint = CGPointMake(toPos, self.center.y);
    animation.duration = 3.0f;
    animation.autoreverses = YES;
    animation.repeatCount = INFINITY;
    animation.timing = BWAnimationTimingEaseInEaseOut;
    
    [self.chipmunkLayer addBWAnimation:animation];
}

- (void)stopAnimation {
    [self.layer removeAllAnimations];
}
#pragma mark -
@end
