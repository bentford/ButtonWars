//
//  UIImageViewCircleBody.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 11/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UIImageViewBody.h"

@interface UIImageViewBody(PrivateMethods)
- (CGAffineTransform)transformWithBody:(cpBody *)theBody;
@end


@implementation UIImageViewBody
@synthesize body;
@synthesize shape;

- (void)updatePosition {
	self.transform = [self transformWithBody:body];
    
}

@end

@implementation UIImageViewBody(PrivateMethods)
- (CGAffineTransform)transformWithBody:(cpBody *)theBody {
    
    //works
    CGAffineTransform translate = CGAffineTransformMakeTranslation(theBody->p.x - width/2.0, theBody->p.y - width/2.0);    
    CGAffineTransform transform = CGAffineTransformRotate(translate, theBody->a);
    
    
    return transform;
}
@end