//
//  UIImageViewCircleBody.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 11/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UIImageViewCircleBody.h"

@implementation UIImageViewCircleBody

- (id)initWithFrame:(CGRect)frame {
    if( (self = [super initWithFrame:frame]) ) {
        cpFloat mass = 1;
		cpFloat moment = cpMomentForCircle(mass, 0, frame.size.width, cpvzero);
		
		body = cpBodyNew(mass, moment);
		body->p = cpv(frame.origin.x, frame.origin.y);
        self.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        
        width = frame.size.width;
        height = frame.size.height;
        
		shape = cpCircleShapeNew(body, frame.size.width/2.0, cpvzero);
		shape->e = 0.3;
		shape->u = 0.2;
		shape->collision_type = 1;
        shape->data = (__bridge cpDataPointer)(self);

    }
    return self;
}

- (void)makeStaticBodyWithPosition:(CGPoint)position {
    
    cpBodyFree(body);
    body = cpBodyNewStatic();
    body->p = position;
    
    cpShape *oldShape = shape;
    
    shape = cpCircleShapeNew(body, cpCircleShapeGetRadius(oldShape), cpvzero);
    shape->e = cpShapeGetElasticity(oldShape);
    shape->u = cpShapeGetFriction(oldShape);
    shape->collision_type = cpShapeGetCollisionType(oldShape);
    shape->data = cpShapeGetUserData(oldShape);
    
    cpShapeFree(oldShape);
}

- (void)makeStaticBody:(cpBody *)staticBody {
    cpShapeFree(shape);
    cpBodyFree(body);

    body = staticBody;
    
    shape = cpCircleShapeNew(body, width/2.0, cpvzero);
    shape->e = 0.3;
    shape->u = 0.2;
    shape->collision_type = 1;
    shape->data = (__bridge cpDataPointer)(self);
}
@end
