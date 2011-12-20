//
//  UIViewBody.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 11/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UIViewBody.h"

@interface UIViewBody(PrivateMethods)
- (CGAffineTransform)transformWithBody:(cpBody *)theBody;
@end

@implementation UIViewBody
@synthesize body;
@synthesize shape;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)updatePosition {
	self.transform = [self transformWithBody:body];
    
}
@end

@implementation UIViewBody(PrivateMethods)
- (CGAffineTransform)transformWithBody:(cpBody *)theBody {
    
    //works
    CGAffineTransform translate = CGAffineTransformMakeTranslation(theBody->p.x - width/2.0, theBody->p.y - width/2.0);    
    CGAffineTransform transform = CGAffineTransformRotate(translate, theBody->a);
    
    
    return transform;
}
@end