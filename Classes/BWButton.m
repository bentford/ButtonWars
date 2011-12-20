//
//  BWButton.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BWButton.h"
static cpFloat frand_unit(){return 2.0f*((cpFloat)rand()/(cpFloat)RAND_MAX) - 1.0f;}

@implementation BWButton

- (id)initWithFrame:(CGRect)frame {
    if( (self = [super initWithFrame:frame]) ) {
        self.image = [UIImage imageNamed:@"ButtonGreen.png"];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)buttonClicked {
    
	// Apply a random velcity change to the body when the button is clicked.
    cpVect v = cpvmult(cpv(frand_unit(), frand_unit()), 300.0f);
    
	cpBodyApplyImpulse(body, v, cpvzero);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self buttonClicked];
}
@end
