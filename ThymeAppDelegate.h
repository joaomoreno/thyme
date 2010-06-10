//
//  ThymeAppDelegate.h
//  Thyme
//
//  Created by João Moreno on 2/8/10.
//

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>

#if (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_5)
@interface ThymeAppDelegate : NSObject <GrowlApplicationBridgeDelegate>
#else
@interface ThymeAppDelegate : NSObject <NSApplicationDelegate, GrowlApplicationBridgeDelegate>
#endif
{
    // Session
    NSInteger hours;
    NSInteger minutes;
    NSInteger seconds;
    
    // Timer
    Boolean isTicking;
    NSTimer *timer;
    NSThread *timerThread;
    
    // Interface
    NSWindow *window;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    
    NSStatusItem *statusItem;
    NSMenu *menu;
    NSMenuItem *startStopItem;
    NSMenuItem *resetItem;
    
    NSMenuItem *sessionsMenuSeparator;
    NSMenuItem *sessionsMenuClearItem;
    NSMutableArray *sessionsMenuItems;
}

@property(retain) NSTimer *timer;
@property(assign) NSThread *timerThread;

@property(nonatomic, retain) IBOutlet NSWindow *window;
@property(nonatomic, retain, readonly) IBOutlet NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property(nonatomic, retain, readonly) IBOutlet NSManagedObjectModel *managedObjectModel;
@property(nonatomic, retain, readonly) IBOutlet NSManagedObjectContext *managedObjectContext;

@property(retain) NSStatusItem *statusItem;
@property(nonatomic, retain) IBOutlet NSMenu *menu;
@property(nonatomic, retain) IBOutlet NSMenuItem *startStopItem;
@property(nonatomic, retain) IBOutlet NSMenuItem *resetItem;

@property(nonatomic, retain) NSMenuItem *sessionsMenuSeparator;
@property(nonatomic, retain) NSMenuItem *sessionsMenuClearItem;
@property(nonatomic, retain) NSMutableArray *sessionsMenuItems;

- (IBAction)saveAction:sender;
- (IBAction)startStop:(id)sender;
- (IBAction)reset:(id)sender;

@end
