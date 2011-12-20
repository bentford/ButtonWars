//
//  UIViewQuadBody.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 11/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UIViewQuadBody.h"

@implementation UIViewQuadBody

- (id)initWithFrame:(CGRect)frame {
    if( self = [super initWithFrame:frame] ) {
		cpFloat mass = 1;
		cpFloat moment = cpMomentForBox(mass, frame.size.width, frame.size.height);
		
		body = cpBodyNew(mass, moment);
		body->p = cpv(frame.origin.x, frame.origin.y);
        self.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        
        width = frame.size.width;
        height = frame.size.height;
        
		shape = cpBoxShapeNew(body, width, height);
		shape->e = 0.3;
		shape->u = 0.2;
		shape->collision_type = 1;
        shape->data = self;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(context, 1.0);
    CGContextStrokeRect(context, rect);
}

@end
