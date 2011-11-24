//
//  UIViewCircleBody.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 11/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UIViewCircleBody.h"

@interface UIViewCircleBody(PrivateMethods)
- (CGAffineTransform)transformWithBody:(cpBody *)theBody;
@end

@implementation UIViewCircleBody
@synthesize body;
@synthesize shape;

- (id)initWithFrame:(CGRect)frame {
    if( (self = [super initWithFrame:frame]) ) {
    
        
		cpFloat mass = 1;
		cpFloat moment = cpMomentForCircle(mass, 0, frame.size.width, cpvzero);
		
		body = cpBodyNew(mass, moment);
		body->p = cpv(frame.origin.x, frame.origin.y);
        self.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        
        width = frame.size.width;
        
		shape = cpCircleShapeNew(body, frame.size.width/2.0, cpvzero);
		shape->e = 1;
		shape->u = 1;
		shape->collision_type = 1;
        shape->data = self;
    }
    return self;
}

- (void)updatePosition {
	self.transform = [self transformWithBody:body];
    
}

@end

@implementation UIViewCircleBody(PrivateMethods)
- (CGAffineTransform)transformWithBody:(cpBody *)theBody {
    
    //works
    CGAffineTransform translate = CGAffineTransformMakeTranslation(theBody->p.x - width/2.0, theBody->p.y - width/2.0);    
    CGAffineTransform transform = CGAffineTransformRotate(translate, theBody->a);
    
    
    return transform;
}
@end