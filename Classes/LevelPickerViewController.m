//
//  LevelPickerViewController.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LevelPickerViewController.h"

@interface LevelPickerViewController(PrivateMethods)
- (void)registerForKeyboardNotifications;
- (void)unregisterForKeyboardNotifications;

- (void)keyboardWillShow:(NSNotification*)aNotification;
- (void)keyboardWillHide:(NSNotification*)aNotification;
@end

@implementation LevelPickerViewController
@synthesize delegate;

- (id)init {
    if( (self = [super initWithNibName:@"LevelPicker" bundle:nil]) ) {
        currentLevelPath = nil;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self pickerView:filePicker didSelectRow:[filePicker selectedRowInComponent:0] inComponent:0];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self registerForKeyboardNotifications];
    
    fullTextHeight = textView.frame.size.height;

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self unregisterForKeyboardNotifications];
}

#pragma mark UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [[[NSBundle mainBundle] pathsForResourcesOfType:@"txt" inDirectory:@"Levels"] count];
}
#pragma mark -

#pragma mark UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *fullPath = [[[NSBundle mainBundle] pathsForResourcesOfType:@"txt" inDirectory:@"Levels"] objectAtIndex:row];
    return [fullPath lastPathComponent];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString *fullPath = [[[NSBundle mainBundle] pathsForResourcesOfType:@"txt" inDirectory:@"Levels"] objectAtIndex:row];

    NSString *mapName = [[fullPath lastPathComponent] stringByReplacingOccurrencesOfString:@".txt" withString:@""];
    if( delegate != nil )
        [delegate didChooseLevel:mapName];
    
    NSString *cacheFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *mapPath = [cacheFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", mapName]];

    [currentLevelPath release];
    currentLevelPath = [mapPath retain];
    
    NSError *fileLoadError = nil;
    NSString *mapText = [NSString stringWithContentsOfFile:mapPath encoding:NSUTF8StringEncoding error:&fileLoadError];
    if( fileLoadError != nil ) {
        NSLog(@"Error reading file: %@ with reason: %@", mapPath, [fileLoadError localizedDescription]);
        return;
    }
    textView.text = mapText;
}
#pragma mark -

- (IBAction)close:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveChanges:(id)sender {
    NSError *error = nil;
    [textView.text writeToFile:currentLevelPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if( error != nil ) 
        NSLog(@"Error saving level to file path: %@, reason: %@", currentLevelPath, [error localizedDescription]);
    
    NSString *mapName = [[currentLevelPath lastPathComponent] stringByReplacingOccurrencesOfString:@".txt" withString:@""];
    if( delegate != nil )
        [delegate didChooseLevel:mapName];
}

- (IBAction)reloadFromBundle:(id)sender {
    NSString *cacheFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *currentFileName = [[currentLevelPath lastPathComponent] stringByReplacingOccurrencesOfString:@".txt" withString:@""];
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:currentFileName ofType:@"txt"];
    NSString *cacheFolderPath = [cacheFolder stringByAppendingPathComponent:[bundlePath lastPathComponent]];

    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:cacheFolderPath error:&error];
    if( error != nil ) {
        NSLog(@"Error deleting existing file: %@", [error localizedDescription]);
        error = nil;
    }
    
    if( [[NSFileManager defaultManager] fileExistsAtPath:cacheFolderPath] == YES )
        NSLog(@"couldn't delete file at path: %@", cacheFolderPath);

    [[NSFileManager defaultManager] copyItemAtPath:bundlePath toPath:cacheFolderPath error:&error];
    if( error != nil )
        NSLog(@"Error copying file: %@", [error localizedDescription]);
    
    [self pickerView:filePicker didSelectRow:[filePicker selectedRowInComponent:0] inComponent:0];
}
@end

@implementation LevelPickerViewController(PrivateMethods)
- (void)registerForKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification object:nil];
	
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification object:nil];
}

- (void)unregisterForKeyboardNotifications {
    
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark KeyboardNotifications
- (void)keyboardWillShow:(NSNotification *)notification {
    NSTimeInterval animationDuration;
    UIViewAnimationCurve curve;
    [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&curve];
    
    NSValue *aValue = [[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [aValue CGRectValue].size;
    
    CGFloat keyboardHeight = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? keyboardSize.height : keyboardSize.width;
    
    [UIView animateWithDuration:animationDuration delay:0.05 options:curve animations:^{
        textView.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width, fullTextHeight-keyboardHeight);
    } completion:^(BOOL completion) {
        
        
    }];
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSTimeInterval animationDuration;
	UIViewAnimationCurve curve;
    [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&curve];
    
    [UIView animateWithDuration:animationDuration delay:0 options:curve animations:^(void) {
        textView.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width, fullTextHeight);
    } completion:^(BOOL finished) {
        
    }];
}
#pragma mark -
@end