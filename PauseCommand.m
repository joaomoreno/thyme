//
//  PauseCommand.m
//  Thyme
//
//  Created by João Moreno on 28/10/12.
//
//

#import "PauseCommand.h"
#import "ThymeAppDelegate.h"

@implementation PauseCommand

- (id) performDefaultImplementation {
    ThymeAppDelegate *appDelegate = (ThymeAppDelegate *) [[NSApplication sharedApplication] delegate];
    [appDelegate pauseWithNotification:false];
    return nil;
}

@end
