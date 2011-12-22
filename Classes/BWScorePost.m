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
		cpShapeSetCollisionType(self.shape, 2);
        
    }
    return self;
}
@end
