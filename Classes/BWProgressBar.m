//
//  BWProgressBar.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BWProgressBar.h"

#define kInsetAmount 10.0f
#define kMidSection 4.0f

@interface BWProgressBar()
@end

@interface BWProgressBar(PrivateMethods)

@end

@implementation BWProgressBar

- (id)init {    
    if( (self = [super initWithFrame:CGRectMake(0, 0, 168, 26)]) ) {
        baseImage = [UIImage imageNamed:@"ProgressBar.png"];
        leftCap = CGImageCreateWithImageInRect(baseImage.CGImage, CGRectMake(0, 0, kInsetAmount, baseImage.size.height));  
        rightCap = CGImageCreateWithImageInRect(baseImage.CGImage, CGRectMake(baseImage.size.width-kInsetAmount, 0, kInsetAmount, baseImage.size.height));
        
        dividerArea = CGImageCreateWithImageInRect(baseImage.CGImage, CGRectMake(baseImage.size.width/2.0f-kMidSection/2.0f, 0, kMidSection, baseImage.size.height));
        
        leftExpansion = CGImageCreateWithImageInRect(baseImage.CGImage, CGRectMake(kInsetAmount, 0, 1, baseImage.size.height));
        rightExpansion = CGImageCreateWithImageInRect(baseImage.CGImage, CGRectMake(baseImage.size.width-kInsetAmount-1, 0, 1, baseImage.size.height));
        
        self.backgroundColor = [UIColor clearColor];
        
        value = 0.5f;

    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(leftCap), CGImageGetHeight(leftCap)), leftCap);
    CGContextDrawImage(context, CGRectMake(rect.size.width-kInsetAmount, 0, CGImageGetWidth(rightCap), CGImageGetHeight(rightCap)), rightCap);
    
    CGContextDrawImage(context, CGRectMake(rect.size.width*value-kMidSection/2.0f, 0, CGImageGetWidth(dividerArea), CGImageGetHeight(dividerArea)), dividerArea);
    
    CGContextDrawImage(context, CGRectMake(kInsetAmount, 0, rect.size.width*value-10, CGImageGetHeight(leftExpansion)), leftExpansion);
    CGContextDrawImage(context, CGRectMake(rect.size.width*value+kMidSection/2.0f, 0, rect.size.width-rect.size.width*value-kInsetAmount-kMidSection/2.0f, CGImageGetHeight(rightExpansion)), rightExpansion);        
}

- (void)setCurrentValue:(CGFloat)newValue {
    if( newValue < 0.1 || newValue > 0.9)
        return;
    
    value = newValue;
    [self setNeedsDisplay];
}

@end

@implementation BWProgressBar(PrivateMethods)
@end