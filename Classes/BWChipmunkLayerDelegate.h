//
//  BWChipmunkLayerDelegate.h
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BWChipmunkLayerDelegate <NSObject>
- (void)didRotateBodyToRadians:(CGFloat)radians;
@end
