//
//  BWSlidingBox.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BWSlidingBox.h"
#import "BWBoxChipmunkLayer.h"

@interface BWSlidingBox(PrivateMethods)
- (NSArray *)generateAnimationPoints;
@end

@implementation BWSlidingBox
@synthesize slideDirection;
@synthesize slideAmount;
@synthesize slideStartPosition;
@synthesize startDelay;

+ (Class)layerClass {
    return [BWBoxChipmunkLayer class];
}

- (id)init {
    if( (self = [super initWithFrame:CGRectMake(0, 0, 150, 150)]) ) {
        self.image = [UIImage imageNamed:@"Sliding-Block.png"];
        
        
        cpBodySetMass(self.chipmunkLayer.body, INFINITY);
        cpBodySetMoment(self.chipmunkLayer.body, cpMomentForBox(INFINITY, 50, 50));
        
        cpShapeFree(self.chipmunkLayer.shape);
        self.chipmunkLayer.shape = cpBoxShapeNew(self.chipmunkLayer.body, 50, 50);
        cpShapeSetElasticity(self.chipmunkLayer.shape, 1.0f);
        cpShapeSetFriction(self.chipmunkLayer.shape, 1.0f);
        
        self.backgroundColor = [UIColor clearColor];
        
        slideAmount = 100.0f;
        slideDirection = BWSlidingBoxDirectionHorizontal;
        slideStartPosition = BWSlidingBoxStartPositionNear;
        startDelay = 0.0f;
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
    CGPoint fromPoint;
    CGPoint toPoint;
    NSArray *points = [self generateAnimationPoints];
    
    // if nil, don't animate
    if( points == nil )
        return;
    
    fromPoint = [(NSValue *)[points objectAtIndex:0] CGPointValue];
    toPoint = [(NSValue *)[points objectAtIndex:1] CGPointValue];
    
    BWAnimation *animation = [BWAnimation animation];
    animation.fromPoint = fromPoint;
    animation.toPoint = toPoint;
    
    //distance of 100 gives 3 seconds, which is good speed
    animation.duration = slideAmount / 33.0f; 
    animation.delay = startDelay;
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

@implementation BWSlidingBox(PrivateMethods)
- (NSArray *)generateAnimationPoints {
    CGPoint fromPoint;
    CGPoint toPoint;
    
    if( slideDirection == BWSlidingBoxDirectionHorizontal ) {
        NSUInteger fromPos, toPos;
        if( slideStartPosition ==  BWSlidingBoxStartPositionCenter ) {
            fromPos = animationStartPoint.x - slideAmount;
            toPos = animationStartPoint.x + slideAmount;
            fromPoint = CGPointMake(fromPos, self.center.y);
            toPoint = CGPointMake(toPos, self.center.y);
        } else if( slideStartPosition ==  BWSlidingBoxStartPositionNear ) {
            fromPos = animationStartPoint.x;
            toPos = animationStartPoint.x + slideAmount*2.0f;
            fromPoint = CGPointMake(fromPos, self.center.y);
            toPoint = CGPointMake(toPos, self.center.y);
        } else if( slideStartPosition ==  BWSlidingBoxStartPositionFar ) {
            fromPos = animationStartPoint.x + slideAmount*2.0f;
            toPos = animationStartPoint.x;
        }
        fromPoint = CGPointMake(fromPos, self.center.y);
        toPoint = CGPointMake(toPos, self.center.y);

        
    } else if( slideDirection == BWSlidingBoxDirectionVertical ) {
        NSUInteger fromPos = animationStartPoint.y - slideAmount;
        NSUInteger toPos = animationStartPoint.y + slideAmount;
        fromPoint = CGPointMake(self.center.x, fromPos);
        toPoint = CGPointMake(self.center.x, toPos);        
    } else 
        return nil;
    
    return [NSArray arrayWithObjects:[NSValue valueWithCGPoint:fromPoint], [NSValue valueWithCGPoint:toPoint], nil];
}
@end