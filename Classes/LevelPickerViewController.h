//
//  LevelPickerViewController.h
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LevelPickerDelegate <NSObject>
- (void)didChooseLevel:(NSString *)levelName;
@end

@interface LevelPickerViewController : UIViewController {
    IBOutlet UITextView *textView;
    NSString *currentLevelPath;
    
    NSUInteger fullTextHeight;
}

@property (nonatomic, assign) id<LevelPickerDelegate> delegate;

- (IBAction)close:(id)sender;
- (IBAction)saveChanges:(id)sender;
@end