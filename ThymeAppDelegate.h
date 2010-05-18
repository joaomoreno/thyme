//
//  ThymeAppDelegate.h
//  Thyme
//
//  Created by João Moreno on 2/8/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DDHotKeyCenter.h"
#import <Growl/Growl.h>

@interface ThymeAppDelegate : NSObject <NSApplicationDelegate, GrowlApplicationBridgeDelegate>
{
    NSInteger seconds;
    Boolean isTicking;
    NSTimer *timer;
    
    NSThread *timerThread;
    NSStatusItem *statusItem;
    
    DDHotKeyCenter *hotKeyCenter;
    
    IBOutlet NSWindow *window;
    IBOutlet NSMenu *menu;
    IBOutlet NSMenuItem *startStopItem;
    IBOutlet NSMenuItem *resetItem;
}

@property NSInteger seconds;
@property Boolean isTicking;
@property(retain) NSTimer *timer;

@property(assign) NSThread *timerThread;
@property(retain) NSStatusItem *statusItem;
@property(retain) DDHotKeyCenter *hotKeyCenter;

@property(retain) IBOutlet NSWindow *window;
@property(retain) IBOutlet NSMenu *menu;
@property(retain) IBOutlet NSMenuItem *startStopItem;
@property(retain) IBOutlet NSMenuItem *resetItem;

- (IBAction)startStop:(id)sender;
- (IBAction)reset:(id)sender;

@end
