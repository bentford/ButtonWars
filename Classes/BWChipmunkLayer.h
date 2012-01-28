//
//  BWBodyLayer.h
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "chipmunk.h"
#import "BWChipmunkLayerDelegate.h"
#import "BWAnimation.h"

@interface BWChipmunkLayer : CALayer {
    cpShape *shape;
    cpBody *body;
    
    CGFloat width;
    CGFloat height;

    NSMutableArray *bwAnimations;
}

@property (nonatomic, assign) id<BWChipmunkLayerDelegate> chipmunkLayerDelegate;

@property (nonatomic, assign) cpBody *body;
@property (nonatomic, assign) cpShape *shape;
@property (nonatomic, assign) CGFloat angle;

- (void)updatePosition;
- (void)step:(CGFloat)timeDelta;

+ (cpShape *)shapeWithBody:(cpBody *)theBody size:(CGSize)shapeSize;
+ (cpBody *)bodyWithMass:(CGFloat)mass size:(CGSize)size;
+ (CGFloat)momentForBodyWithSize:(CGSize)momentSize mass:(CGFloat)mass;

- (void)addBWAnimation:(BWAnimation *)animation;
- (void)cancelAllAnimations;
@end
