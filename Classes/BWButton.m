//
//  BWButton.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BWButton.h"
#import "BWChipmunkLayer.h"

@implementation BWButton
@synthesize color;

+ (Class)layerClass {
    return [BWChipmunkLayer class];
}

- (id)initWithFrame:(CGRect)frame {
    NSAssert(NO, @"use initWithFrame:color:");
    return nil;
}

- (id)initWithColor:(ButtonColor)aColor {
    if( (self = [super initWithFrame:CGRectMake(0, 0, 50, 50)]) ) {

        color = aColor;
        if( color == ButtonColorGreen )
            self.image = [UIImage imageNamed:@"ButtonGreen.png"];
        else if( color == ButtonColorOrange )
            self.image = [UIImage imageNamed:@"ButtonOrange.png"];
        
        self.userInteractionEnabled = NO;
        
        cpShapeSetUserData(self.chipmunkLayer.shape, self);
    }
    return self;
}

- (BWChipmunkLayer *)chipmunkLayer {
    return (BWChipmunkLayer *)self.layer;
}

- (void)setupWithSpace:(cpSpace *)space position:(CGPoint)position {
    cpBodySetPos(self.chipmunkLayer.body, position);
    cpSpaceAddBody(space, self.chipmunkLayer.body);
    cpSpaceAddShape(space, self.chipmunkLayer.shape);
}
@end
