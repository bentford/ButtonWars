#import <UIKit/UIKit.h>

#import <QuartzCore/CADisplayLink.h>

#import "FallingButton.h"
#import "GameDelegate.h"

#define kFloorCollisionType 0
#define kButtonCollisionType 1

void postSolveCollision(cpArbiter *arbiter, cpSpace *space, void *data);

@class BWBumper;
@class BWChipmunkLayer;
@interface ViewController : UIViewController <GameDelegate> {
	CADisplayLink *displayLink;
	cpSpace *space;
    
    BWBumper *bumper;
    
    UILabel *topScore;
    UILabel *bottomScore;
    
    BWChipmunkLayer *buttonTest2;
}

@property (nonatomic, retain) UILabel *topScore;
@property (nonatomic, retain) UILabel *bottomScore;

- (void)createScorePosts;
- (void)removeButtons;
- (void)removeScorePosts;

- (void)resetBumper:(BWBumper *)theBumper;
@end

