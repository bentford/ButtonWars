//
//  BWLevelWall.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BWLevelWall.h"
#import "BWStaticBoxChipmunkLayer.h"

@implementation BWLevelWall
+ (Class)layerClass {
    return [BWStaticBoxChipmunkLayer class];
}

- (id)initWithLength:(CGFloat)newLength {
    if( (self = [super initWithFrame:CGRectMake(0, 0, 50, newLength)]) ) {
        self.image = [UIImage imageNamed:@"LevelWall.png"];
        self.contentMode = UIViewContentModeScaleToFill;
        
        cpBodySetMass(self.chipmunkLayer.body, INFINITY);
        cpBodySetMoment(self.chipmunkLayer.body, cpMomentForBox(INFINITY, 22, newLength));
        
        cpShapeFree(self.chipmunkLayer.shape);
        cpBoxShapeNew(self.chipmunkLayer.body, 22, newLength);
        cpShapeSetElasticity(self.chipmunkLayer.shape, 0.6f);
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
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
@end
