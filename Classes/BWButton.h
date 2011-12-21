//
//  BWButton.h
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImageViewCircleBody.h"
#import "GameData.h"

@interface BWButton : UIImageViewCircleBody {
    ButtonColor color;
}

- (id)initWithColor:(ButtonColor)aColor;
- (id)initWithFrame:(CGRect)frame color:(ButtonColor)buttonColor;
@end
