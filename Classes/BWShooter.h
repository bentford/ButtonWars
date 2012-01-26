//
//  BWShooter.h
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChipmunkLayerView.h"
#import "GameDelegate.h"
#import "GameData.h"

@interface BWShooter : UIImageView <ChipmunkLayerView> {
    NSUInteger panCounter;
    id<GameDelegate> gameDelegate;
    ButtonColor theButtonColor;
    cpShape *innerShape;
}

@property (nonatomic, assign) id<GameDelegate> gameDelegate;
@property (nonatomic, readonly) ButtonColor buttonColor;
@property (nonatomic, assign) NSUInteger activeButtonCount;

- (id)initWithButtonColor:(ButtonColor)aButtonColor;
@end
