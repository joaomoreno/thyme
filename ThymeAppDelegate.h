//
//  ThymeAppDelegate.h
//  Thyme
//
//  Created by João Moreno on 2/8/10.
//

#import <Growl/Growl.h>
#import <Cocoa/Cocoa.h>
#import "DDHotKeyCenter.h"
#import "Stopwatch.h"
#import "PreferencesWindowController.h"

@interface ThymeAppDelegate : NSObject <NSApplicationDelegate, GrowlApplicationBridgeDelegate, StopwatchDelegate>
{
    Stopwatch* stopwatch;
    DDHotKeyCenter *hotKeyCenter;
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    
    NSWindow *window;
    
    NSStatusItem *statusItem;
    NSMenu *menu;
    NSMenuItem *startPauseItem;
    NSMenuItem *finishItem;
    
    PreferencesWindowController *preferencesWindowController;
    
    NSMenuItem *sessionsMenuSeparator;
    NSMenuItem *sessionsMenuClearItem;
    NSMutableArray *sessionsMenuItems;
}

@property(nonatomic, retain) Stopwatch *stopwatch;
@property(nonatomic, retain) DDHotKeyCenter *hotKeyCenter;

@property(nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property(nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property(nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

@property(nonatomic, retain) IBOutlet NSWindow *window;

@property(nonatomic, retain) NSStatusItem *statusItem;
@property(nonatomic, retain) IBOutlet NSMenu *menu;
@property(nonatomic, retain) IBOutlet NSMenuItem *startPauseItem;
@property(nonatomic, retain) IBOutlet NSMenuItem *finishItem;

@property(nonatomic, retain) PreferencesWindowController *preferencesWindowController;

@property(nonatomic, retain) NSMenuItem *sessionsMenuSeparator;
@property(nonatomic, retain) NSMenuItem *sessionsMenuClearItem;
@property(nonatomic, retain) NSMutableArray *sessionsMenuItems;

- (void)startWithNotification:(Boolean)notification;
- (void)pauseWithNotification:(Boolean)notification;
- (void)toggleWithNotification:(Boolean)notification;
- (void)stopWithNotification:(Boolean)notification;

- (void)clearHotKeys;
- (void)resetHotKeys;

- (IBAction)onStartPauseClick:(id)sender;
- (IBAction)onFinishClick:(id)sender;
- (IBAction)onPreferencesClick:(id)sender;
- (IBAction)onAboutClick:(id)sender;

@end
