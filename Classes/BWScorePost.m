//
//  BWScorePost.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BWScorePost.h"
#import "BWChipmunkLayer.h"

@implementation BWScorePost

+ (Class)layerClass {
    return [BWChipmunkLayer class];
}

- (id)init {
    if( (self = [super initWithFrame:CGRectMake(0, 0, 25, 25)]) ) {
        
        self.image = [UIImage imageNamed:@"Peg.png"];
		cpShapeSetCollisionType(self.chipmunkLayer.shape, 2);
        cpShapeSetUserData(self.chipmunkLayer.shape, (__bridge cpDataPointer)(self));
        buttonColor = 0;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    NSAssert(NO, @"use init instead");
    return nil;
}

- (void)setButtonColor:(ButtonColor)newButtonColor {
    buttonColor = newButtonColor;
    
    if( buttonColor == ButtonColorGreen )
        self.image = [UIImage imageNamed:@"PegGreen.png"];
    else if( buttonColor == ButtonColorOrange ) 
        self.image = [UIImage imageNamed:@"PegOrange.png"];
    else
        self.image = [UIImage imageNamed:@"Peg.png"];
}

- (ButtonColor)buttonColor {
    return buttonColor;
}

- (BWChipmunkLayer *)chipmunkLayer {
    return (BWChipmunkLayer *)self.layer;
}

- (void)setupWithSpace:(cpSpace *)space position:(CGPoint)position {
    self.center = position;
    cpSpaceAddShape(space, self.chipmunkLayer.shape);
}

- (void)removeFromSpace:(cpSpace *)space {
    cpSpaceRemoveShape(space, self.chipmunkLayer.shape);
}
@end
