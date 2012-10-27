//
//  ToggleCommand.m
//  Thyme
//
//  Created by João Moreno on 28/10/12.
//
//

#import "ToggleCommand.h"
#import "ThymeAppDelegate.h"

@implementation ToggleCommand

- (id) performDefaultImplementation {
    ThymeAppDelegate *appDelegate = (ThymeAppDelegate *) [[NSApplication sharedApplication] delegate];
    [appDelegate toggleWithNotification:false];
    return nil;
}

@end
