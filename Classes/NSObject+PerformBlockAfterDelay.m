//
//  NSObject+PerformBlockAfterDelay.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSObject+PerformBlockAfterDelay.h"

@implementation NSObject(PerformBlockAfterDelay)


- (void)fireBlockAfterDelay:(void (^)(void))block {
    block();
}

- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay {
    block = [block copy];
    [self performSelector:@selector(fireBlockAfterDelay:) 
               withObject:block 
               afterDelay:delay];
}

@end
