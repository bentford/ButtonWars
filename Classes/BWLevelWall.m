//
//  BWLevelWall.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BWLevelWall.h"
#import "BWStaticBoxChipmunkLayer.h"

#define kInsetAmount 50.0f

@implementation BWLevelWall
+ (Class)layerClass {
    return [BWStaticBoxChipmunkLayer class];
}

- (id)initWithLength:(CGFloat)newLength {
    if( (self = [super initWithFrame:CGRectMake(0, 0, 50, newLength)]) ) {
        baseImage = [[UIImage imageNamed:@"LevelWall.png"] retain];
        
        cpBodySetMass(self.chipmunkLayer.body, INFINITY);
        cpBodySetMoment(self.chipmunkLayer.body, cpMomentForBox(INFINITY, 22, newLength));
        
        cpShapeFree(self.chipmunkLayer.shape);
        self.chipmunkLayer.shape = cpBoxShapeNew(self.chipmunkLayer.body, 22, newLength-35);
        cpShapeSetElasticity(self.chipmunkLayer.shape, 0.6f);
        cpShapeSetFriction(self.chipmunkLayer.shape, 1.0f);
        
        self.backgroundColor = [UIColor clearColor];
        
        cpShapeSetUserData(self.chipmunkLayer.shape, self);
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGImageRef topCap = CGImageCreateWithImageInRect(baseImage.CGImage, CGRectMake(0, baseImage.size.height-kInsetAmount, baseImage.size.width, kInsetAmount));
    
    CGImageRef bottomCap = CGImageCreateWithImageInRect(baseImage.CGImage, CGRectMake(0, 0, baseImage.size.width, kInsetAmount)); 
    CGImageRef middleRepeat = CGImageCreateWithImageInRect(baseImage.CGImage, CGRectMake(0, kInsetAmount, baseImage.size.width, 1));
    
    CGContextDrawImage(context, CGRectMake(1, 0, CGImageGetWidth(topCap), CGImageGetHeight(topCap)), topCap);
    CGContextDrawImage(context, CGRectMake(0, rect.size.height-kInsetAmount, CGImageGetWidth(bottomCap), CGImageGetHeight(bottomCap)), bottomCap);

    for( CGFloat yPosition = kInsetAmount; yPosition < rect.size.height-kInsetAmount; yPosition++)
        CGContextDrawImage(context, CGRectMake(0, yPosition, CGImageGetWidth(middleRepeat), CGImageGetHeight(middleRepeat)), middleRepeat);
    
    
}

#pragma mark ChipmunkLayerView
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
#pragma mark -

- (void)dealloc {
    [baseImage release];
    
    [super dealloc];
}
@end
