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
#import "GameData.h"

@interface BWShooter : UIImageViewCircleBody {
    NSUInteger panCounter;
    id<GameDelegate> gameDelegate;
    ButtonColor theButtonColor;
}

@property (nonatomic, assign) id<GameDelegate> gameDelegate;
@property (nonatomic, readonly) ButtonColor buttonColor;

- (id)initWithFrame:(CGRect)frame color:(ButtonColor)aButtonColor;
@end
