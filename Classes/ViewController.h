#import <UIKit/UIKit.h>

#import <QuartzCore/CADisplayLink.h>

#import "FallingButton.h"
#import "GameDelegate.h"

#define kFloorCollisionType 0
#define kButtonCollisionType 1

void postSolveCollision(cpArbiter *arbiter, cpSpace *space, void *data);

@interface ViewController : UIViewController <GameDelegate> {
	CADisplayLink *displayLink;
	cpSpace *space;
	FallingButton *fallingButton;
}

@end

