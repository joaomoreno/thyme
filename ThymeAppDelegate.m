//
//  ThymeAppDelegate.m
//  Thyme
//
//  Created by João Moreno on 2/8/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "ThymeAppDelegate.h"

@implementation ThymeAppDelegate

@synthesize seconds;
@synthesize isTicking;
@synthesize timer;
@synthesize timerThread;
@synthesize statusItem;
@synthesize window;
@synthesize menu;
@synthesize startStopItem;
@synthesize resetItem;

- (void)setTime
{
    if (seconds >= 3600)
    {
        if ([statusItem length] != 72.0)
            [statusItem setLength:72.0];
        
        [statusItem setTitle:[NSString stringWithFormat:@"%02d:%02d:%02d", seconds / 3600, (seconds % 3600) / 60, seconds % 60]];
    }
    else
    {
        if ([statusItem length] != 46.0)
            [statusItem setLength:46.0];
        
        [statusItem setTitle:[NSString stringWithFormat:@"%02d:%02d", seconds / 60, seconds % 60]];
    }
}

- (void)tick
{
    self.seconds++;
    [self setTime];
}

- (void)startTimer
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    [runLoop addTimer:self.timer forMode:NSDefaultRunLoopMode];
    [runLoop run];
    [pool release];
}

- (IBAction)startStop:(id)sender
{
    if (!isTicking)
    {
        timerThread = [[NSThread alloc] initWithTarget:self selector:@selector(startTimer) object:nil];
        [timerThread start];
        [self setTime];
        [startStopItem setTitle:@"Stop"];
        [resetItem setEnabled:YES];
    }
    else
    {
        [timer invalidate];
        [timer release];
        [timerThread release];
        [self setTime];
        [startStopItem setTitle:@"Start"];
    }
    
    isTicking = !isTicking;
}

- (IBAction)reset:(id)sender
{
    if (!isTicking)
    {
        seconds = 0;
        [statusItem setTitle:@"Thyme"];
        [statusItem setLength:52.0];
        [resetItem setEnabled:NO];
    }
    else
    {
        seconds = 0;
        [self setTime];
    }
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [window close];

    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    self.statusItem = [statusBar statusItemWithLength:52.0];
    [statusItem setTitle:@"Thyme"];
    [statusItem setHighlightMode:YES];
    [statusItem setMenu:menu];
    
    [resetItem setEnabled:NO];
    
    self.seconds = 0;
    self.isTicking = NO;
}

@end
