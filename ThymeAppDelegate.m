//
//  ThymeAppDelegate.m
//  Thyme
//
//  Created by João Moreno on 2/8/10.
//

#import "ThymeAppDelegate.h"
#import <Growl/Growl.h>
#import "Session.h"

#define KEYCODE_T 17
#define KEYCODE_R 15
#define ZERO_TIME (hours == 0 && minutes == 0 && seconds == 0)

@interface ThymeAppDelegate(hidden)
- (NSString*)currentTimerValue;
- (void)setTime;
- (void)tick;
- (void)startTimer;

- (void)startWithNotification:(Boolean)notification;
- (void)stopWithNotification:(Boolean)notification;
- (void)reset;

- (void)keyPressed;
- (void)resetTimer;

- (void)notifyStart;
- (void)notifyStop;

- (void)saveCurrentSession;

- (IBAction)clear:(id)sender;
- (void)clearSessionsFromMenu;
- (void)addSessionToMenu:(Session*)session;
@end


@implementation ThymeAppDelegate

@synthesize timer;
@synthesize timerThread;
@synthesize hotKeyCenter;
@synthesize statusItem;
@synthesize window;
@synthesize menu;
@synthesize startStopItem;
@synthesize resetItem;
@synthesize sessionsMenuSeparator;
@synthesize sessionsMenuClearItem;
@synthesize sessionsMenuItems;

#pragma mark Timer

- (NSString*)currentTimerValue
{
    if (hours > 0)
        return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
    else
        return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

- (void)setTime
{
    
    if (ZERO_TIME && !isTicking)
    {
        [statusItem setLength:26.0];
        [statusItem setTitle:@""];
        [statusItem setImage:[NSImage imageNamed:@"logo_small.png"]];
    }
    else
    {
        if (hours > 0)
            [statusItem setLength:72.0];
        else
            [statusItem setLength:46.0];
        
        [statusItem setTitle:[self currentTimerValue]];
        [statusItem setImage:nil];
    }

}

- (void)tick
{
    seconds++;
    
    if (seconds >= 60)
    {
        minutes++;
        seconds = 0;
    }
    
    if (minutes >= 60)
    {
        hours++;
        minutes = 0;
    }
    
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
    
    [startStopItem setTitle:@"Pause"];
    [resetItem setEnabled:YES];
    isTicking = YES;
    
    if (notification)
        [self notifyStart];
    
    [self setTime];
}

- (void)stopWithNotification:(Boolean)notification
{
    [timer invalidate];
    [timer release];
    [timerThread release];
    
    [startStopItem setTitle:@"Continue"];
    isTicking = NO;
    
    if (notification)
        [self notifyStop];
    
    [self setTime];
}

- (void)reset
{
    hours = minutes = seconds = 0;
    
    [self stopWithNotification:NO];
    [resetItem setEnabled:NO];
    [startStopItem setTitle:@"Start"];
}

- (void)clearSessionsFromMenu
{
    [menu removeItem:self.sessionsMenuSeparator];
    [menu removeItem:self.sessionsMenuClearItem];
    
    for (NSMenuItem *item in self.sessionsMenuItems)
        [menu removeItem:item];
    
    [self.sessionsMenuItems removeAllObjects];
}

- (void)addSessionToMenu:(Session*)session
{
    if ([self.sessionsMenuItems count] == 0)
    {
        [menu insertItem:self.sessionsMenuSeparator atIndex:2];
        [menu insertItem:self.sessionsMenuClearItem atIndex:3];
    }
    
    NSInteger index = 3 + [self.sessionsMenuItems count];
    
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[session stringRepresentation] action:@selector(lol) keyEquivalent:@""];
    [item setEnabled:NO];
    [menu insertItem:item atIndex:index];
    [self.sessionsMenuItems addObject:item];
    [item release];
}

#pragma mark Model

- (void)saveCurrentSession
{
    if (seconds > 0 || minutes > 0 || hours > 0)
    {
        Session *session = [Session sessionWithSeconds:seconds minutes:minutes hours:hours];
        [self saveAction:self];
        [self addSessionToMenu:session];
    }
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
    [self saveCurrentSession];
    [self reset];
}

- (IBAction)clear:(id)sender
{
    for (Session *session in [Session allSessions])
        [self.managedObjectContext deleteObject:session];
    
    [self saveAction:self];
    
    [self clearSessionsFromMenu];
}

#pragma mark Keyboard Events

- (void)keyPressed
{
    if (!isTicking)
        [self startWithNotification:YES];
    else 
        [self stopWithNotification:YES];
}

- (void)resetTimer
{
    [self saveCurrentSession];
    [self reset];   
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
                                description:[@"Paused at " stringByAppendingString:[self currentTimerValue]]
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
    
    // Configure the Global hotkey
    DDHotKeyCenter *center = [[DDHotKeyCenter alloc] init];
    self.hotKeyCenter = center;
    [center release];
    
    [hotKeyCenter registerHotKeyWithKeyCode:KEYCODE_T
                              modifierFlags:NSControlKeyMask
                                     target:self
                                     action:@selector(keyPressed)
                                     object:nil];
                                     
    [hotKeyCenter registerHotKeyWithKeyCode:KEYCODE_R
                              modifierFlags:NSControlKeyMask
                                     target:self
                                     action:@selector(resetTimer)
                                     object:nil];                                     
    
    // Configure Growl
    [GrowlApplicationBridge setGrowlDelegate:self];
    
    // Create class attributes
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:20];
    self.sessionsMenuItems = array;
    [array release];
    
    self.sessionsMenuSeparator = [NSMenuItem separatorItem];
    
    NSMenuItem *clearMenuItem = [[NSMenuItem alloc] initWithTitle:@"Clear" action:@selector(clear:) keyEquivalent:@""];
    self.sessionsMenuClearItem = clearMenuItem;
    [clearMenuItem release];

    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    self.statusItem = [statusBar statusItemWithLength:46.0];
    [statusItem setHighlightMode:YES];
    [statusItem setMenu:menu];
    
    isTicking = NO;
    
    // Populate data
    
    for (Session *session in [Session allSessions])
        [self addSessionToMenu:session];
    
    // Start controller
    
    [self reset];
}

/**
    Returns the support directory for the application, used to store the Core Data
    store file.  This code uses a directory named "Lol" for
    the content, either in the NSApplicationSupportDirectory location or (if the
    former cannot be found), the system's temporary directory.
 */

- (NSString *)applicationSupportDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"Thyme"];
}


/**
    Creates, retains, and returns the managed object model for the application 
    by merging all of the models found in the application bundle.
 */
 
- (NSManagedObjectModel *)managedObjectModel
{
    if (managedObjectModel) 
        return managedObjectModel;
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
    Returns the persistent store coordinator for the application.  This 
    implementation will create and return a coordinator, having added the 
    store for the application to it.  (The directory for the store is created, 
    if necessary.)
 */

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator
{
    if (persistentStoreCoordinator)
        return persistentStoreCoordinator;

    NSManagedObjectModel *mom = [self managedObjectModel];
    
    if (!mom)
    {
        NSAssert(NO, @"Managed object model is nil");
        NSLog(@"%@:%s No model to generate a store from", [self class], _cmd);
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *applicationSupportDirectory = [self applicationSupportDirectory];
    NSError *error = nil;
    
    if ( ![fileManager fileExistsAtPath:applicationSupportDirectory isDirectory:NULL] )
    {
		if (![fileManager createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:NO attributes:nil error:&error])
        {
            NSAssert(NO, ([NSString stringWithFormat:@"Failed to create App Support directory %@ : %@", applicationSupportDirectory,error]));
            NSLog(@"Error creating application support directory at %@ : %@",applicationSupportDirectory,error);
            return nil;
		}
    }
    
    NSURL *url = [NSURL fileURLWithPath: [applicationSupportDirectory stringByAppendingPathComponent: @"storedata"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: mom];
    
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType 
                                                configuration:nil 
                                                URL:url 
                                                options:nil 
                                                error:&error])
    {
        [[NSApplication sharedApplication] presentError:error];
        [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
        return nil;
    }    

    return persistentStoreCoordinator;
}

/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
 
- (NSManagedObjectContext *) managedObjectContext
{
    if (managedObjectContext)
        return managedObjectContext;

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (!coordinator)
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator: coordinator];

    return managedObjectContext;
}

/**
    Returns the NSUndoManager for the application.  In this case, the manager
    returned is that of the managed object context for the application.
 */
 
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}


/**
    Performs the save action for the application, which is to send the save:
    message to the application's managed object context.  Any encountered errors
    are presented to the user.
 */
 
- (IBAction) saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing])
    {
        NSLog(@"%@:%s unable to commit editing before saving", [self class], _cmd);
    }

    if (![[self managedObjectContext] save:&error])
    {
        [[NSApplication sharedApplication] presentError:error];
    }
}


/**
    Implementation of the applicationShouldTerminate: method, used here to
    handle the saving of changes in the application managed object context
    before the application terminates.
 */
 
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    if (!managedObjectContext)
        return NSTerminateNow;
    
    [self saveCurrentSession];
    
    if (![managedObjectContext commitEditing])
    {
        NSLog(@"%@:%s unable to commit editing to terminate", [self class], _cmd);
        return NSTerminateCancel;
    }

    if (![managedObjectContext hasChanges])
        return NSTerminateNow;

    NSError *error = nil;
    if (![managedObjectContext save:&error])
    {
        // This error handling simply presents error information in a panel with an 
        // "Ok" button, which does not include any attempt at error recovery (meaning, 
        // attempting to fix the error.)  As a result, this implementation will 
        // present the information to the user and then follow up with a panel asking 
        // if the user wishes to "Quit Anyway", without saving the changes.

        // Typically, this process should be altered to include application-specific 
        // recovery steps.  
                
        BOOL result = [sender presentError:error];
        
        if (result)
            return NSTerminateCancel;

        NSString *question = NSLocalizedString(@"Could not save changes while quitting.  Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        [alert release];
        alert = nil;
        
        if (answer == NSAlertAlternateReturn)
            return NSTerminateCancel;
    }

    return NSTerminateNow;
}


/**
    Implementation of dealloc, to release the retained variables.
 */
- (void)dealloc
{
    [window release];
    [managedObjectContext release];
    [persistentStoreCoordinator release];
    [managedObjectModel release];
    
    [timer release];
    [timerThread release];
    [statusItem release];
    [hotKeyCenter release];
    
    [sessionsMenuSeparator release];
    [sessionsMenuClearItem release];
    [sessionsMenuItems release];
	
    [super dealloc];
}

@end
