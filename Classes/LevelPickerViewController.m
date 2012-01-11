//
//  LevelPickerViewController.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LevelPickerViewController.h"

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

#pragma UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [[[NSBundle mainBundle] pathsForResourcesOfType:@"txt" inDirectory:@"Levels"] count];
}
#pragma mark -

#pragma UIPickerViewDelegate
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
@end
