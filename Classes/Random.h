//
//  Random.h
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Random : NSObject

+ (void)seed;
+ (NSUInteger)randomWithMin:(NSUInteger)min max:(NSUInteger)max;
@end
