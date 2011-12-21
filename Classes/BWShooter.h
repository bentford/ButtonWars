//
//  BWShooter.h
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImageViewCircleBody.h"
#import "GameDelegate.h"

@interface BWShooter : UIImageViewCircleBody {
    NSUInteger panCounter;
    id<GameDelegate> gameDelegate;
}

@property (nonatomic, assign) id<GameDelegate> gameDelegate;

@end
