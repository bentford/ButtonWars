#import <UIKit/UIKit.h>

@class LaunchScreenViewController;
@class ViewController;
@interface AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    LaunchScreenViewController *viewController;
    ViewController *gameViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet LaunchScreenViewController *viewController;

- (void)startGame;

+ (AppDelegate *)delegate;
@end

