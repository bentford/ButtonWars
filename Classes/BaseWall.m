//
//  BaseWall.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BaseWall.h"
#import "BWBoxChipmunkLayer.h"
#import <QuartzCore/QuartzCore.h>

@implementation BaseWall

+ (Class)layerClass {
    return [BWChipmunkLayer class];
}

- (id)init {
    return [self initWithDirection:BaseWallDirectionNormal];
}

- (id)initWithDirection:(BaseWallDirection)direction {
    if( (self = [super initWithFrame:CGRectMake(0, 0, 313, 127)]) ) {
        
        UIImage *normalImage = [UIImage imageNamed:@"BaseWall.png"];
        
        if( direction == BaseWallDirectionNormal ) {
            self.image = normalImage;
            cpVect verts[4] = {cpv(-145,25), cpv(-141,56), cpv(150,53), cpv(151,-56) };
            cpShapeFree(self.chipmunkLayer.shape);
            self.chipmunkLayer.shape = cpPolyShapeNew(self.chipmunkLayer.body, 4, verts, cpvzero);
        } else if( direction == BaseWallDirectionFlippedHorizontal ) {
            self.image = [UIImage imageWithCGImage:normalImage.CGImage scale:1.0 orientation:UIImageOrientationUpMirrored];
            cpVect verts[4] = {cpv(-151,-56), cpv(-150,53), cpv(141,56), cpv(145,25) };
            cpShapeFree(self.chipmunkLayer.shape);
            self.chipmunkLayer.shape = cpPolyShapeNew(self.chipmunkLayer.body, 4, verts, cpvzero);
        } else if( direction == BaseWallDirectionFlippedVertical ) {
            self.image = [UIImage imageWithCGImage:normalImage.CGImage scale:1.0 orientation:UIImageOrientationDownMirrored];
            cpVect verts[4] = {cpv(-141,-56), cpv(-145,-25), cpv(151,56), cpv(150,-53) };
            cpShapeFree(self.chipmunkLayer.shape);
            self.chipmunkLayer.shape = cpPolyShapeNew(self.chipmunkLayer.body, 4, verts, cpvzero);
        } else if( direction == BaseWallDirectionFlippedBoth ) {
            self.image = [UIImage imageWithCGImage:normalImage.CGImage scale:1.0 orientation:UIImageOrientationDown];
            cpVect verts[4] = {cpv(-150,-53), cpv(-151,56), cpv(145,-25), cpv(141,-56) };
            cpShapeFree(self.chipmunkLayer.shape);
            self.chipmunkLayer.shape = cpPolyShapeNew(self.chipmunkLayer.body, 4, verts, cpvzero);
        }
        
        cpBodySetMass(self.chipmunkLayer.body, INFINITY);
        cpBodySetMoment(self.chipmunkLayer.body, cpMomentForBox(INFINITY, 313, 127));

        
        
        cpShapeSetElasticity(self.chipmunkLayer.shape, 0.6f);
        cpShapeSetFriction(self.chipmunkLayer.shape, 1.0);
        
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
    
    cpSpaceAddBody(space, self.chipmunkLayer.body);
    cpSpaceAddShape(space, self.chipmunkLayer.shape);
}

- (void)removeFromSpace:(cpSpace *)space {

    cpSpaceRemoveShape(space, self.chipmunkLayer.shape);
    cpSpaceRemoveBody(space, self.chipmunkLayer.body);
}
#pragma mark -
@end
