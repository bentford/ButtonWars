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
    if( (self = [super initWithFrame:CGRectMake(0, 0, 50, 50)]) ) {
        cpBodySetMass(self.chipmunkLayer.body, INFINITY);
        cpBodySetMoment(self.chipmunkLayer.body, cpMomentForBox(INFINITY, 50, 50));
        
        self.backgroundColor = [UIColor blackColor];
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
    CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:@"bodyPosition.x"];
    moveAnimation.fromValue = [NSNumber numberWithInt:fromPos];
    moveAnimation.toValue = [NSNumber numberWithInt:toPos];
    moveAnimation.duration = 3.0;
    moveAnimation.autoreverses = YES;
    moveAnimation.repeatCount = INFINITY;
    moveAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.chipmunkLayer addAnimation:moveAnimation forKey:@"bodyPosition.x"];
}

- (void)stopAnimation {
    [self.layer removeAllAnimations];
}
#pragma mark -
@end
