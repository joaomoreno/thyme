//
//  StopCommand.m
//  Thyme
//
//  Created by João Moreno on 28/10/12.
//
//

#import "StopCommand.h"
#import "ThymeAppDelegate.h"

@implementation StopCommand

- (id) performDefaultImplementation {
    ThymeAppDelegate *appDelegate = (ThymeAppDelegate *) [[NSApplication sharedApplication] delegate];
    [appDelegate stopWithNotification:false];
    return nil;
}

@end
