#import "AppDelegate.h"
#import "ViewController.h"
#import "LaunchScreenViewController.h"

#import <AudioToolbox/AudioToolbox.h>
#import <OpenAL/alc.h>


@interface AppDelegate(PrivateMethods)
- (void)copyLevelFilesToCacheFolder;
@end

@implementation AppDelegate

@synthesize window;
@synthesize viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {   
  
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    // Some quick sound code for this demonstration.
	ALCdevice *device = alcOpenDevice(NULL);
	ALCcontext *context = alcCreateContext(device, NULL);
	alcMakeContextCurrent(context);
	
	AudioSessionInitialize(NULL, NULL, NULL, NULL);
	UInt32 sessionCategory = kAudioSessionCategory_SoloAmbientSound;
	AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
	AudioSessionSetActive(TRUE);
	
    [self copyLevelFilesToCacheFolder];
    
	[window addSubview:viewController.view];
	[window makeKeyAndVisible];

	return YES;
}

+ (AppDelegate *)delegate {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (void)startGame {
    gameViewController = [[ViewController alloc] init];
    [viewController.view removeFromSuperview];
    
    [window addSubview:gameViewController.view];
}

- (void)dealloc {
	[viewController release];
	[window release];
	[super dealloc];
}

@end

@implementation AppDelegate(PrivateMethods)
- (void)copyLevelFilesToCacheFolder {
    NSString *cacheFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    NSArray *paths = [[NSBundle mainBundle] pathsForResourcesOfType:@"txt" inDirectory:@"Levels"];
    for( NSString *bundlePath in paths ) {
        NSError *error = nil;
        NSString *cacheFolderPath = [cacheFolder stringByAppendingPathComponent:[bundlePath lastPathComponent]];
        
        if( [[NSFileManager defaultManager] fileExistsAtPath:cacheFolderPath] == YES )
            continue;
        
        [[NSFileManager defaultManager] copyItemAtPath:bundlePath toPath:cacheFolderPath error:&error];
        if( error != nil )
            NSLog(@"Error copying file: %@", [error localizedDescription]);
    }
    
    
}
@end