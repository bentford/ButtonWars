//
//  BWBodyLayer.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BWBodyLayer.h"

@interface BWBodyLayer(PrivateMethods)
- (CATransform3D)transformWithBody:(cpBody *)theBody;
@end

@implementation BWBodyLayer
@synthesize body;
@synthesize shape;

- (id)init {
    if( (self = [super init]) ) {
        NSLog(@"layer init");
        body = cpBodyNew(1.0, cpMomentForCircle(1.0, 0, 1.0, cpvzero));
        shape = cpCircleShapeNew(body, 1.0, cpvzero);

        cpShapeSetCollisionType(shape, 1);
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    NSLog(@"setFrame: %@", NSStringFromCGRect(frame));
    cpBodySetPos(self.body, CGPointMake(frame.origin.x+self.bounds.size.width/2.0, frame.origin.y+self.bounds.size.height/2.0));

    if( frame.size.width != cpCircleShapeGetRadius(self.shape) || frame.size.height != cpCircleShapeGetRadius(self.shape) ) {
        if( self.shape != nil )
            cpShapeFree(self.shape);

        self.shape = cpCircleShapeNew(self.body, frame.size.width/2.0, cpvzero);
        cpBodySetMoment(body, cpMomentForCircle(1.0, 0.0, frame.size.width/2.0, cpvzero));
    }
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    NSLog(@"setBounds: %@", NSStringFromCGRect(bounds));
    
    if( bounds.size.width != cpCircleShapeGetRadius(self.shape) || bounds.size.height != cpCircleShapeGetRadius(self.shape) ) {
        if( self.shape != nil )
            cpShapeFree(self.shape);
        
        shape = cpCircleShapeNew(body, bounds.size.width/2.0, cpvzero);
        cpBodySetMoment(body, cpMomentForCircle(1.0, 0.0, bounds.size.width/2.0, cpvzero));
    }
}

- (void)setPosition:(CGPoint)position {
    [super setPosition:position];
    NSLog(@"setPosition: %@", NSStringFromCGPoint(position));
    CGPoint newPosition = CGPointMake(position.x-self.bounds.size.width/2.0, position.y-self.bounds.size.width/2.0);
    NSLog(@"converted to: %@", NSStringFromCGPoint(newPosition));
    
    cpBodySetPos(body, newPosition);
}

- (void)updatePosition {
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:0.0]
                     forKey:kCATransactionAnimationDuration];

	[self setValue:[NSNumber numberWithFloat:cpBodyGetPos(body).x] forKey:@"transform.translation.x"];
    [self setValue:[NSNumber numberWithFloat:cpBodyGetPos(body).y] forKey:@"transform.translation.y"];
    [self setValue:[NSNumber numberWithFloat:cpBodyGetAngle(body)] forKey:@"transform.rotation"];
    [CATransaction commit];
}

- (void)dealloc {
    cpShapeFree(shape);
    cpBodyFree(body);
    
    [super dealloc];
}
@end

@implementation BWBodyLayer(PrivateMethods)
- (CATransform3D)transformWithBody:(cpBody *)theBody {
    
    //works
    CATransform3D translate = CATransform3DMakeTranslation(theBody->p.x, theBody->p.y, 0);
    
    //CATransform3D transform = CATransform3DRotate(translate, theBody->a, 0, 0, 1);
    
    
    return translate;
}
@end