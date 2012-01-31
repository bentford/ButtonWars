//
//  LaunchScreenViewController.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LaunchScreenViewController.h"
#import "AppDelegate.h"

@implementation LaunchScreenViewController
- (IBAction)onePlayerMode:(id)sender {
    [[AppDelegate delegate] startGame];
}

- (IBAction)twoPlayerMode:(id)sender {
    [[AppDelegate delegate] startGame];    
}

@end
