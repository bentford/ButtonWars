//
//  BWSlidingHalfBox.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BWSlidingHalfBox.h"
#import "BWBoxChipmunkLayer.h"

@implementation BWSlidingHalfBox
- (id)init {
    if( (self = [super init]) ) {
        self.image = [UIImage imageNamed:@"Sliding-Half-Block.png"];
        
        cpShapeFree(self.chipmunkLayer.shape);
        cpVect verts[4] = {cpv(-23,-28), cpv(-23,25), cpv(26,25)};
        self.chipmunkLayer.shape = cpPolyShapeNew(self.chipmunkLayer.body, 3, verts, cpvzero);
        
        cpShapeSetElasticity(self.chipmunkLayer.shape, 1.0f);
        cpShapeSetFriction(self.chipmunkLayer.shape, 1.0f);
        
        self.backgroundColor = [UIColor clearColor];
        
        slideAmount = 100.0f;
        slideDirection = BWSlidingBoxDirectionHorizontal;
        self.slideStartPosition = BWSlidingBoxStartPositionNear;
        self.startDelay = 0.0f;
    }
    return self;
}

@end
