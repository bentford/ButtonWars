#import <UIKit/UIKit.h>
#import "chipmunk.h"

@interface FallingButton : UIView {
	cpShape *shape;
	cpBody *body;
    CGFloat width;
}
@property (nonatomic, assign) cpBody *body;
@property (nonatomic, assign) cpShape *shape;
- (void)updatePosition;

@end
