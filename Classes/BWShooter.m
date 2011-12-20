//
//  BWShooter.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BWShooter.h"

@implementation BWShooter
- (id)initWithFrame:(CGRect)frame {
    if( (self = [super initWithFrame:frame]) ) {
        self.image = [UIImage imageNamed:@"GreenShooter.png"];
        self.userInteractionEnabled = YES;
    }
    return self;
}
@end
