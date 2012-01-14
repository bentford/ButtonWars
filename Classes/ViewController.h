#import <UIKit/UIKit.h>

#import <QuartzCore/CADisplayLink.h>
#import "GameDelegate.h"

#define kFloorCollisionType 0
#define kButtonCollisionType 1

#import "chipmunk.h"
#import "GameData.h"
#import "LevelPickerViewController.h"

@class BWButton;
@class BWBumper;
@class BWChipmunkLayer;
@interface ViewController : UIViewController <GameDelegate, LevelPickerDelegate> {
	CADisplayLink *displayLink;
	cpSpace *space;
    
    UILabel *topScore;
    UILabel *bottomScore;
    UILabel *countdownLabel;
    
    BWChipmunkLayer *buttonTest2;
    
    NSUInteger frameCounter;
    
    NSTimer *gameTimer;
    NSTimer *winnerTimer;
    NSUInteger countdown;
    
    ButtonColor currentWinner;
    
    BWShooter *topShooter;
    BWShooter *bottomShooter;
    
    LevelPickerViewController *levelPickerViewController;
    
    NSUInteger pointsToWin;
}

@property (nonatomic, retain) UILabel *topScore;
@property (nonatomic, retain) UILabel *bottomScore;

- (void)removeButtons;
- (void)removeLevelItems;

- (void)resetBumper:(BWBumper *)theBumper;

- (void)createScorePostsWithQuantity:(NSUInteger)quantity inRect:(CGRect)insideRect;
- (void)reloadMapWithLevelNamed:(NSString *)levelName;

- (void)startCountdownForColor:(ButtonColor)winningColor;
- (void)iterateCountdown:(NSTimer *)countdownTimer;
- (void)checkForWinner;
- (void)stopCountdownForColor:(ButtonColor)theColor;

- (void)fireTrappedButton:(BWButton *)button;
@end

