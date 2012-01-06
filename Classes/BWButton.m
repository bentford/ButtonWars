//
//  BWButton.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BWButton.h"
#import "BWChipmunkLayer.h"

@interface BWButton(PrivateMethods)
- (void)stopDeathPrevention;
@end

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
        canDie = NO;
        
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(stopDeathPrevention) userInfo:nil repeats:NO];
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

- (void)guideTowardPoint:(CGPoint)guidePoint {
    //CGFloat currentVelocity = cpvlength(cpBodyGetVel(self.chipmunkLayer.body));
    CGFloat distanceFromGuidePoint = cpvlength(cpvsub(guidePoint, cpBodyGetPos(self.chipmunkLayer.body)));
    
    cpVect guideVector = cpvnormalize(cpvsub(guidePoint, cpBodyGetPos(self.chipmunkLayer.body)));

    cpVect impulseVector = cpvzero;

    if( distanceFromGuidePoint < 400 && self.canDie == YES ) {
        impulseVector = cpvmult(guideVector, 200);
    } else
        impulseVector = cpvmult(guideVector, 80-powf(distanceFromGuidePoint, 2.0)/15000);
    
    cpBodyApplyImpulse(self.chipmunkLayer.body, impulseVector, cpvzero);
}

- (BOOL)canDie {
    return canDie;
}
@end

@implementation BWButton(PrivateMethods)
- (void)stopDeathPrevention {
    canDie = YES;
}
@end