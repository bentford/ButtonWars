//
//  GameDelegate.h
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BWShooter;
@protocol GameDelegate <NSObject>
- (void)shootWithShooter:(BWShooter *)shooter;
@end
