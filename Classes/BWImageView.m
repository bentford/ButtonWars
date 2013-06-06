//
//  BWImageView.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BWImageView.h"

@implementation BWImageView
@synthesize image;

- (id)initWithFrame:(CGRect)frame {
    if( (self = [super initWithFrame:frame]) ) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, rect, self.image.CGImage);
}

@end
