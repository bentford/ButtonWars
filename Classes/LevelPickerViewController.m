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

    if( delegate != nil )
        [delegate didChooseLevel:[[fullPath lastPathComponent] stringByReplacingOccurrencesOfString:@".txt" withString:@""]];
}
#pragma mark -

- (IBAction)close:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
@end
