#import <UIKit/UIKit.h>

#import <QuartzCore/CADisplayLink.h>
#import "GameDelegate.h"

#define kFloorCollisionType 0
#define kButtonCollisionType 1

#import "chipmunk.h"
#import "GameData.h"
#import "LevelPickerViewController.h"
#import "BWProgressBarAnimator.h"

@class BWProgressBarAnimator;
@class BWButton;
@class BWBumper;
@class BWChipmunkLayer;
@interface ViewController : UIViewController <GameDelegate, LevelPickerDelegate, BWProgressAnimatorDelegate> {
	CADisplayLink *displayLink;
	cpSpace *space;
    
    NSUInteger greenScore;
    NSUInteger orangeScore;
    
    UIView *topMark;
    UIView *bottomMark;
    
    
    BWShooter *topShooter;
    BWShooter *bottomShooter;
    
    LevelPickerViewController *levelPickerViewController;
    
    BWProgressBarAnimator *progressAnimator;
    
    NSUInteger totalScorePosts;
    
    UIImageView *playerWonPrompt;
    
    NSString *currentLevelName;
    
    BOOL gameSuspended;
}
@property (nonatomic, assign) BOOL gameSuspended;
@property (nonatomic, assign) NSUInteger greenScore;
@property (nonatomic, assign) NSUInteger orangeScore;

- (void)removeButtons;
- (void)removeLevelItems;

- (void)resetBumper:(BWBumper *)theBumper;

- (void)reloadMapWithLevelNamed:(NSString *)levelName;

- (void)checkForWinner;


- (void)fireTrappedButton:(BWButton *)button;

@end

