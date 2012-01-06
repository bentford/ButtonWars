//
//  UIViewQuadBody.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 11/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UIViewQuadBody.h"
#import "BWBoxChipmunkLayer.h"
#import "BWSegmentChipmunkLayer.h"

@implementation UIViewQuadBody

+ (Class)layerClass {
    return [BWSegmentChipmunkLayer class];
}

- (id)initWithFrame:(CGRect)frame {
    if( self = [super initWithFrame:frame] ) {
		cpShapeSetUserData(self.chipmunkLayer.shape, self);
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(context, 1.0);
    CGContextStrokeRect(context, rect);
}

- (BWChipmunkLayer *)chipmunkLayer {
    return (BWChipmunkLayer *)self.layer;
}

- (void)setupWithSpace:(cpSpace *)space position:(CGPoint)position {
    cpBodySetPos(self.chipmunkLayer.body, position);
    //cpSpaceAddBody(space, self.chipmunkLayer.body);
    cpSpaceAddShape(space, self.chipmunkLayer.shape);
}
@end
