//
//  UIImageViewCircleBody.h
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 11/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "chipmunk.h"

@interface UIImageViewBody : UIImageView {
    cpShape *shape;
    cpBody *body;
    
    CGFloat width;
    CGFloat height;
}

@property (nonatomic, assign) cpBody *body;
@property (nonatomic, assign) cpShape *shape;

- (void)updatePosition;

@end
