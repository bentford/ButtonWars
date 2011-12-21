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
@end
