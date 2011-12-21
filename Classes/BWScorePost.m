//
//  BWScorePost.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BWScorePost.h"

@implementation BWScorePost
- (id)initWithFrame:(CGRect)frame {
    if( (self = [super initWithFrame:frame]) ) {
        self.image = [UIImage imageNamed:@"WoodScorePost.png"];
        self.userInteractionEnabled = NO;    
        self.shape->e = 1.0;
    }
    return self;
}

@end
