//
//  BWBumper.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BWBumper.h"
#import <QuartzCore/QuartzCore.h>

@interface BWBumperLayer : CALayer
@property (nonatomic, assign) CGPoint bodyPosition;
@property (nonatomic, assign) CGFloat testValue;
@end

@implementation BWBumperLayer

+ (BOOL)needsDisplayForKey:(NSString *)key {
    if( [key isEqualToString:@"bodyPosition"] || 
        [key isEqualToString:@"testValue"] ) 
        return YES;
    
    return [super needsDisplayForKey:key];
}

- (void)setBodyPosition:(CGPoint)bodyPosition {
    NSLog(@"newPosition: %@", NSStringFromCGPoint(bodyPosition));
}

- (CGPoint)bodyPosition {
    return CGPointZero;
}

- (void)setTestValue:(CGFloat)testValue {
    NSLog(@"new test value: %f", testValue);
}

- (CGFloat)testValue {
    return 0;
}
@end

@implementation BWBumper

+ (Class)layerClass {
    return [BWBumperLayer class];
}

- (id)init {
    if( (self = [super initWithFrame:CGRectMake(0, 0, 100, 100)]) ) {
        self.image = [UIImage imageNamed:@"Bumper.png"];
        cpShapeSetElasticity(self.shape, 1.0);
        cpShapeSetCollisionType(self.shape, 3);
        cpBodySetMass(self.body, 10000.0);
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
