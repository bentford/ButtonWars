//
//  JelloPopupAnimation.m
//  iPrintMeOrderSubmissionLibrary
//
//  Created by Ben Ford on 12/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "JelloPopupAnimation.h"

@implementation JelloPopupAnimation
+ (void)animateView:(UIView *)view {
    view.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:0.2 animations:^{
        view.transform = CGAffineTransformMakeScale(1.1, 1.1);        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
           view.transform = CGAffineTransformMakeScale(0.9, 0.9); 
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                view.transform = CGAffineTransformMakeScale(1.1, 1.1); 
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.1 animations:^{
                    view.transform = CGAffineTransformMakeScale(1.0, 1.0); 
                } completion:^(BOOL finished) {
                    
                }];                
            }];
        }];
    }];
}
@end
