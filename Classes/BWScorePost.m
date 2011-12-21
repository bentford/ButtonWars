//
//  BWScorePost.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BWScorePost.h"

@implementation BWScorePost
- (id)initWithFrame:(CGRect)frame {
    if( (self = [super initWithFrame:frame]) ) {
        self.image = [UIImage imageNamed:@"WoodScorePost.png"];
        self.userInteractionEnabled = NO;    
        
        shape = cpCircleShapeNew(body, frame.size.width/2.0, cpvzero);
		shape->e = 1.0;
		shape->u = 0.2;
		shape->collision_type = 2;
        shape->data = self;
    }
    return self;
}

- (void)makeStaticBodyWithPosition:(CGPoint)position {
    
    cpShapeFree(shape);
    cpBodyFree(body);
    body = cpBodyNewStatic();
    body->p = position;
    
    shape = cpCircleShapeNew(body, width/2.0, cpvzero);
    shape->e = 0.3;
    shape->u = 0.2;
    shape->collision_type = 2;
    shape->data = self;
}
@end
