//
//  CatmullRomSplineVIew.h
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CatmullRomSplineVIew : UIView

- (CGFloat)catmullRomForTime:(CGFloat)t p0:(CGFloat)P0 p1:(CGFloat)P1 p2:(CGFloat)P2 p3:(CGFloat)P3;
@end
