//
//  UIViewQuadBody.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 11/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UIViewQuadBody.h"
#import "BWStaticBoxChipmunkLayer.h"

@implementation UIViewQuadBody

+ (Class)layerClass {
    return [BWStaticBoxChipmunkLayer class];
}

- (id)initWithFrame:(CGRect)frame {
    if( self = [super initWithFrame:frame] ) {
        
		cpShapeSetUserData(self.chipmunkLayer.shape, (__bridge cpDataPointer)(self));
        
        cpShapeSetCollisionType(self.chipmunkLayer.shape, 0);
        cpShapeSetElasticity(self.chipmunkLayer.shape, 1.0);
        cpShapeSetFriction(self.chipmunkLayer.shape, 1.0);
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
//    CGContextSetLineWidth(context, 1.0);
//    CGContextStrokeRect(context, rect);
}

- (BWChipmunkLayer *)chipmunkLayer {
    return (BWChipmunkLayer *)self.layer;
}

- (void)setupWithSpace:(cpSpace *)space position:(CGPoint)position {
    self.center = position;
    cpSpaceAddShape(space, self.chipmunkLayer.shape);
}

- (void)removeFromSpace:(cpSpace *)space {
    cpSpaceRemoveShape(space, self.chipmunkLayer.shape);
    //cpSpaceRemoveBody(space, self.chipmunkLayer.body);
}
@end
