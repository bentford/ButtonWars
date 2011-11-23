#import <UIKit/UIKit.h>
#import "chipmunk.h"

@interface FallingButton : UIView {
	cpShape *shape;
	cpBody *body;
}
@property (nonatomic, assign) cpShape *shape;
- (void)updatePosition;

@end
