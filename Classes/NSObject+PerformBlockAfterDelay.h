//
//  NSObject+PerformBlockAfterDelay.h
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject(PerformBlockAfterDelay)
- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;
@end
