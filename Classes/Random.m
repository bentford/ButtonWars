//
//  Random.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Random.h"

@implementation Random

+ (void)seed {
    srandom(time(NULL));
}

+ (NSUInteger)randomWithMin:(NSUInteger)min max:(NSUInteger)max {
    return (min + random() % ((max + 1) - min));
}

+ (CGPoint)randomPointInRect:(CGRect)insideRect {
    NSUInteger x = [Random randomWithMin:insideRect.origin.x max:insideRect.origin.x + insideRect.size.width];
    NSUInteger y = [Random randomWithMin:insideRect.origin.y max:insideRect.origin.y + insideRect.size.height];

    return CGPointMake(x, y);
}
@end
