//
//  BWBumper.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BWBumper.h"

@implementation BWBumper

- (id)init {
    if( (self = [super initWithFrame:CGRectMake(0, 0, 100, 100)]) ) {
        self.image = [UIImage imageNamed:@"Bumper.png"];
        cpShapeSetElasticity(self.shape, 1.0);
        cpShapeSetCollisionType(self.shape, 3);
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if( (self = [super initWithFrame:frame]) ) {
        self.image = [UIImage imageNamed:@"Bumper.png"];
    }
    return self;
}

@end
