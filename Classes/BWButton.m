//
//  BWButton.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BWButton.h"
#import "BWChipmunkLayer.h"

#define kDebugGuidePoint NO

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
        self.backgroundColor = [UIColor clearColor];
        
        self.userInteractionEnabled = NO;
        
        cpShapeSetUserData(self.chipmunkLayer.shape, self);
        canDie = NO;
        
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(stopDeathPrevention) userInfo:nil repeats:NO];
    }
    return self;
}

#ifdef kDrawGuidePoint
- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    
    CGFloat oppositeAngle = cpBodyGetAngle(self.chipmunkLayer.body);
    CGPoint rotatedGuideVector = cpvrotate(currentGuideVector, cpvforangle(oppositeAngle*-1));
    CGPoint viewableGuideVector = cpvmult(rotatedGuideVector, 25);
    CGPoint guidePoint = cpvadd(viewableGuideVector, cpv(25,25));
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 25, 25);
    CGContextAddLineToPoint(context, guidePoint.x, guidePoint.y);
    CGContextClosePath(context);
    CGContextStrokePath(context);
}
#endif

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
    currentGuideVector = guideVector;

#ifdef kDebugGuidePoint
    [self setNeedsDisplay];
#endif
    
    cpVect impulseVector = cpvzero;

    if( distanceFromGuidePoint < 400 && self.canDie == YES ) {
        impulseVector = cpvmult(guideVector, 30);
    } else
        impulseVector = cpvmult(guideVector, 16-powf(distanceFromGuidePoint, 2.0)/80000);
    
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