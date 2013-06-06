#import <UIKit/UIKit.h>

@class LaunchScreenViewController;
@class ViewController;
@interface AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    LaunchScreenViewController *viewController;
    ViewController *gameViewController;
}

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet LaunchScreenViewController *viewController;

- (void)startGame;

+ (AppDelegate *)delegate;
@end

