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

@interface LevelPickerViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource> {
    IBOutlet UITextView *textView;
    NSString *currentLevelPath;
    
    NSUInteger fullTextHeight;
    
    IBOutlet UIPickerView *filePicker;
}

@property (nonatomic, weak) id<LevelPickerDelegate> delegate;

- (IBAction)close:(id)sender;
- (IBAction)saveChanges:(id)sender;

- (IBAction)reloadFromBundle:(id)sender;

- (IBAction)clearMap:(id)sender;
@end
