//
//  CatmullRomSplineVIew.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CatmullRomSplineVIew.h"

#define kPointSize 10

@implementation CatmullRomSplineVIew

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
    CGContextMoveToPoint(context, -10, self.bounds.size.height/2.0f);
    for( CGFloat t = 0.0f; t < 1.01f; t += 0.05f ) {
        CGFloat y = [self catmullRomForTime:t p0:self.bounds.size.height/2.0+50 p1:self.bounds.size.height/2.0-50 p2:self.bounds.size.height/2.0 p3:self.bounds.size.height/2.0];
        CGFloat x = t * 500;
        CGContextAddLineToPoint(context, x, y);
    }
    CGContextStrokePath(context);
}

- (CGFloat)catmullRomForTime:(CGFloat)t p0:(CGFloat)P0 p1:(CGFloat)P1 p2:(CGFloat)P2 p3:(CGFloat)P3 {
    return 0.5 * ((2 * P1) +
          (-P0 + P2) * t +
          (2*P0 - 5*P1 + 4*P2 - P3) * powf(t,2.0f) +
          (-P0 + 3*P1- 3*P2 + P3) * powf(t, 3.0f));
}
@end
