//
//  StartCommand.m
//  Thyme
//
//  Created by João Moreno on 28/10/12.
//
//

#import "StartCommand.h"
#import "ThymeAppDelegate.h"

@implementation StartCommand

- (id) performDefaultImplementation {
    ThymeAppDelegate *appDelegate = (ThymeAppDelegate *) [[NSApplication sharedApplication] delegate];
    [appDelegate startWithNotification:false];
    return nil;
}

@end
