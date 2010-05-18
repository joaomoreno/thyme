//
//  ThymeAppDelegate.m
//  Thyme
//
//  Created by João Moreno on 2/8/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "ThymeAppDelegate.h"
#import <Growl/Growl.h>

#define KEYCODE_T 17

@interface ThymeAppDelegate(hidden)
- (NSString*)now;
- (void)setTime;
- (void)tick;
- (void)startTimer;

- (void)startWithNotification:(Boolean)notification;
- (void)stopWithNotification:(Boolean)notification;
- (void)reset;

- (void)keyPressed;

- (void)notifyStart;
- (void)notifyStop;
@end


@implementation ThymeAppDelegate

@synthesize seconds;
@synthesize isTicking;
@synthesize timer;
@synthesize timerThread;
@synthesize hotKeyCenter;
@synthesize statusItem;
@synthesize window;
@synthesize menu;
@synthesize startStopItem;
@synthesize resetItem;

#pragma mark Timer

- (NSString*)now
{
    if (seconds >= 3600)
        return [NSString stringWithFormat:@"%02d:%02d:%02d", seconds / 3600, (seconds % 3600) / 60, seconds % 60];
    else
        return [NSString stringWithFormat:@"%02d:%02d", seconds / 60, seconds % 60];
}

- (void)setTime
{
    if (seconds >= 3600)
        [statusItem setLength:72.0];
    else
        [statusItem setLength:46.0];
    
    [statusItem setTitle:[self now]];
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

#pragma mark Controller

- (void)startWithNotification:(Boolean)notification
{
    timerThread = [[NSThread alloc] initWithTarget:self selector:@selector(startTimer) object:nil];
    [timerThread start];
    [self setTime];
    [startStopItem setTitle:@"Stop"];
    [resetItem setEnabled:YES];
    isTicking = YES;
    
    if (notification)
        [self notifyStart];
}

- (void)stopWithNotification:(Boolean)notification
{
    [timer invalidate];
    [timer release];
    [timerThread release];
    [self setTime];
    [startStopItem setTitle:@"Continue"];
    isTicking = NO;
    
    if (notification)
        [self notifyStop];
}

- (void)reset
{
    seconds = 0;
    [self stopWithNotification:NO];
    [resetItem setEnabled:NO];
    [startStopItem setTitle:@"Start"];
}

#pragma mark Status Bar

- (IBAction)startStop:(id)sender
{
    if (!isTicking)
        [self startWithNotification:NO];
    else 
        [self stopWithNotification:NO];
}

- (IBAction)reset:(id)sender
{
    [self reset];
}

#pragma mark Keyboard Events

- (void)keyPressed
{
    if (!isTicking)
        [self startWithNotification:YES];
    else 
        [self stopWithNotification:YES];
}

#pragma mark Growl Notifications

- (void)notifyStart
{
    [GrowlApplicationBridge notifyWithTitle:@"Thyme"
                                description:@"Started counting"
                           notificationName:@"start"
                                   iconData:nil
                                   priority:0
                                   isSticky:NO
                               clickContext:nil];
}

- (void)notifyStop
{
    [GrowlApplicationBridge notifyWithTitle:@"Thyme"
                                description:[@"Paused at " stringByAppendingString:[self now]]
                           notificationName:@"start"
                                   iconData:nil
                                   priority:0
                                   isSticky:NO
                               clickContext:nil];
}

#pragma mark NSApplication

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [window close];
    DDHotKeyCenter *center = [[DDHotKeyCenter alloc] init];
    self.hotKeyCenter = center;
    [center release];
    
    [hotKeyCenter registerHotKeyWithKeyCode:KEYCODE_T
                              modifierFlags:NSControlKeyMask
                                     target:self
                                     action:@selector(keyPressed)
                                     object:nil];
    
    [GrowlApplicationBridge setGrowlDelegate:self];

    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    self.statusItem = [statusBar statusItemWithLength:46.0];
    [statusItem setHighlightMode:YES];
    [statusItem setMenu:menu];
    
    self.isTicking = NO;
    
    [self reset:nil];
    [self startWithNotification:YES];
}

@end
