//
//  BWProgressBar.h
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BWProgressBar : UIView {
    UIImage *baseImage;
    CGImageRef leftCap;
    CGImageRef rightCap;
    
    CGImageRef leftExpansion;
    CGImageRef rightExpansion;
    
    CGImageRef dividerArea;
    
    
    CGFloat value;
}

- (void)setCurrentValue:(CGFloat)newValue;
@end
