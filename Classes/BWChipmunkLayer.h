//
//  BWBodyLayer.h
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "chipmunk.h"

@interface BWChipmunkLayer : CALayer {
    cpShape *shape;
    cpBody *body;
    
    CGFloat width;
    CGFloat height;

}

@property (nonatomic, assign) cpBody *body;
@property (nonatomic, assign) cpShape *shape;
@property (nonatomic, assign) CGFloat angle;

// these are proxies for positon and angle and targets for CABasicAnimation
@property (nonatomic, assign) CGPoint bodyPosition;
@property (nonatomic, assign) CGFloat bodyAngle;

- (void)updatePosition;

+ (cpShape *)shapeWithBody:(cpBody *)theBody size:(CGSize)shapeSize;
+ (cpBody *)bodyWithMass:(CGFloat)mass size:(CGSize)size;
+ (CGFloat)momentForBodyWithSize:(CGSize)momentSize mass:(CGFloat)mass;
@end
