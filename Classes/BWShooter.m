//
//  BWShooter.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BWShooter.h"
#import "BWButton.h"

@interface BWShooter(PrivateMethods)
- (void)tap:(UITapGestureRecognizer *)tapGesture;
- (void)touch:(UITouch *)touch;
- (void)pan:(UIPanGestureRecognizer *)panGesture;
- (void)shootButton;
@end

@implementation BWShooter
@synthesize gameDelegate;

- (id)initWithFrame:(CGRect)frame {
    NSAssert(NO, @"use initWithFrame:color:");
    return nil;
}

- (id)initWithFrame:(CGRect)frame color:(ButtonColor)aButtonColor {    
    if( (self = [super initWithFrame:frame]) ) {
        theButtonColor = aButtonColor;
        self.image = [UIImage imageNamed:@"GreenShooter.png"];
        self.userInteractionEnabled = YES;
        self.contentMode = UIViewContentModeScaleToFill;
        
        UIPanGestureRecognizer *pan = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)] autorelease];
        [self addGestureRecognizer:pan];
        
        cpShapeSetCollisionType(self.shape, 4);
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    [self touch:touch];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self shootButton];
}

- (ButtonColor)buttonColor {
    return theButtonColor;
}

@end

@implementation BWShooter(PrivateMethods)
- (void)touch:(UITouch *)touch {
    CGPoint touchPoint = [touch locationInView:self];
    CGPoint touchPointFromCenter = CGPointMake(touchPoint.x - width/2.0, touchPoint.y - height/2.0);
    
    CGFloat touchedDegrees = DEGREES(cpvtoangle(touchPointFromCenter));
    if( touchedDegrees < 0 )
        touchedDegrees = 180 + (180+touchedDegrees);
    
    CGFloat bodyDegrees = DEGREES(self.body->a);
    if( bodyDegrees < 0 )
        bodyDegrees = 180 + (180+bodyDegrees);
    
    CGFloat final = touchedDegrees + bodyDegrees;
    cpBodySetAngle(self.body, RADIANS(final) );
}

- (void)tap:(UITapGestureRecognizer *)tapGesture {
    CGPoint touchPoint = [tapGesture locationInView:self];
    CGPoint touchPointFromCenter = CGPointMake(touchPoint.x - width/2.0, touchPoint.y - height/2.0);

    CGFloat touchedDegrees = DEGREES(cpvtoangle(touchPointFromCenter));
    if( touchedDegrees < 0 )
        touchedDegrees = 180 + (180+touchedDegrees);
    
    CGFloat bodyDegrees = DEGREES(self.body->a);
    if( bodyDegrees < 0 )
        bodyDegrees = 180 + (180+bodyDegrees);
    
    CGFloat final = touchedDegrees + bodyDegrees;
    cpBodySetAngle(self.body, RADIANS(final) );
}

- (void)pan:(UIPanGestureRecognizer *)panGesture {
    if( panGesture.state == UIGestureRecognizerStateEnded )
        [self shootButton];
    
    panCounter++;
    
    if( panCounter % 3 != 0 )
        return;
    
    panCounter = 0;
    
    CGPoint touchPoint = [panGesture locationInView:self];
    
    CGPoint touchPointFromCenter = CGPointMake(touchPoint.x - width/2.0, touchPoint.y - height/2.0);
    
    CGFloat touchedDegrees = DEGREES(cpvtoangle(touchPointFromCenter));
    if( touchedDegrees < 0 )
        touchedDegrees = 180 + (180+touchedDegrees);
    
    if( touchedDegrees > 360 )
        touchedDegrees -= 360;
    
    CGFloat bodyDegrees = DEGREES(self.body->a);
    if( bodyDegrees < 0 )
        bodyDegrees = 180 + (180+bodyDegrees);

    if( bodyDegrees > 360 )
        bodyDegrees -= 360;
    
    CGFloat final = touchedDegrees + bodyDegrees;
    cpBodySetAngle(self.body, RADIANS(final) );
}

- (void)shootButton {
    [gameDelegate shootWithShooter:self];
}
@end
