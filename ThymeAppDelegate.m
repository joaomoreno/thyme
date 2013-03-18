//
//  ThymeAppDelegate.m
//  Thyme
//
//  Created by João Moreno on 2/8/10.
//

#import "ThymeAppDelegate.h"
#import "Session.h"
#import "ShortcutRecorder/PTHotKey/PTHotKey+ShortcutRecorder.h"

#define KEYCODE_T 17
#define KEYCODE_R 15
#define ZERO_TIME (hours == 0 && minutes == 0 && seconds == 0)

@interface ThymeAppDelegate(hidden)
- (void)startTimer;
- (void)resetTimer;

- (void)notifyStart;
- (void)notifyPauseWithDescription:(NSString*)description;
- (void)notifyStopWithDescription:(NSString*)description;

- (void)save:(NSTimeInterval)value;

- (void)updateStatusBar;
- (void)clearSessionsFromMenu;
- (void)addSessionToMenu:(Session*)session;

- (IBAction)clear:(id)sender;
- (IBAction)saveAction:(id)sender;
@end


@implementation ThymeAppDelegate

@synthesize stopwatch;
@synthesize hotKeyCenter;
@synthesize statusItem;
@synthesize window;
@synthesize menu;
@synthesize startPauseItem;
@synthesize finishItem;
@synthesize preferencesWindowController;
@synthesize sessionsMenuSeparator;
@synthesize sessionsMenuClearItem;
@synthesize sessionsMenuItems;

#pragma mark Controller

- (void)startWithNotification:(Boolean)notification
{
    if (![self.stopwatch isActive]) {
        [self.stopwatch start];
        
        [startPauseItem setTitle:@"Pause"];
        [finishItem setEnabled:YES];
        
        if (notification) {
            [self notifyStart];
        }
    }
}

- (void)pauseWithNotification:(Boolean)notification
{
    if ([self.stopwatch isActive]) {
        [self.stopwatch pause];
        
        [startPauseItem setTitle:@"Continue"];
        
        if (notification) {
            [self notifyPauseWithDescription:[self.stopwatch description]];
        }
    }
}

- (void)toggleWithNotification:(Boolean)notification
{
    if ([self.stopwatch isActive]) {
        [self pauseWithNotification:notification];
    } else {
        [self startWithNotification:notification];
    }
}

- (void)stopWithNotification:(Boolean)notification
{
    if (![self.stopwatch isStopped]) {
        NSString* description = [self.stopwatch description];
        [self resetWithNotification:NO];
        
        if (notification) {
            [self notifyStopWithDescription:description];
        }
    }
}

- (void)resetWithNotification:(Boolean)notification
{
    if (![self.stopwatch isStopped]) {
        NSString* description = [self.stopwatch description];
        [self.stopwatch stop];
        
        [startPauseItem setTitle:@"Start"];
        [finishItem setEnabled:NO];
        
        if (notification) {
            [self notifyPauseWithDescription:description];
        }
    }
}

- (void)clearSessionsFromMenu
{
    [menu removeItem:self.sessionsMenuSeparator];
    [menu removeItem:self.sessionsMenuClearItem];
    
    for (NSMenuItem *item in self.sessionsMenuItems) {
        [menu removeItem:item];
    }
    
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

- (void)save:(NSTimeInterval)value {
    long totalSeconds = (long) floor(value);
    long hours = totalSeconds / 3600;
    long minutes = (totalSeconds / 60) % 60;
    long seconds = totalSeconds % 60;

    if (totalSeconds > 0) {
        Session *session = [Session sessionWithSeconds:seconds minutes:minutes hours:hours];
        [self saveAction:self];
        [self addSessionToMenu:session];
    }
}

#pragma mark Status Bar

- (IBAction)onStartPauseClick:(id)sender
{
    [self toggleWithNotification:NO];
}

- (IBAction)onFinishClick:(id)sender
{
    [self resetWithNotification:NO];
}

- (IBAction)clear:(id)sender
{
    for (Session *session in [Session allSessions]) {
        [self.managedObjectContext deleteObject:session];
    }
    
    [self saveAction:self];
    
    [self clearSessionsFromMenu];
}

- (IBAction)onPreferencesClick:(id)sender {
    if (self.preferencesWindowController == nil) {
        PreferencesWindowController* pwc = [[PreferencesWindowController alloc] initWithWindowNibName:@"PreferencesWindowController"];
        self.preferencesWindowController = pwc;
        [pwc release];
    }
    
    [self.preferencesWindowController showWindow:nil];
    [NSApp activateIgnoringOtherApps:YES];
}

- (IBAction)onAboutClick:(id)sender {
    [[NSApplication sharedApplication] orderFrontStandardAboutPanel:nil];
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)updateStatusBar {
    if ([self.stopwatch isStopped]) {
        [statusItem setLength:26.0];
        [statusItem setTitle:@""];
        [statusItem setImage:[NSImage imageNamed:@"logo_small"]];
    } else {
        [statusItem setLength:[self.stopwatch value] > 3600 ? 72.0 : 46.0];
        [statusItem setTitle:[self.stopwatch description]];
        [statusItem setImage:nil];
    }
}

#pragma mark Hot Key Handlers

- (void)startTimer
{
    if (self.preferencesWindowController != nil && [[self.preferencesWindowController window] isVisible]) {
        return;
    }
    
    [self toggleWithNotification:YES];
}

- (void)resetTimer
{
    if (self.preferencesWindowController != nil && [[self.preferencesWindowController window] isVisible]) {
        return;
    }
    
    [self stopWithNotification:YES];
}

#pragma mark Stopwatch Delegate

- (void) didStart:(id)stopwatch {
    [self updateStatusBar];
}

- (void) didPause:(id)_stopwatch {
    [self updateStatusBar];
}

- (void) didStop:(id)stopwatch withValue:(NSTimeInterval)value {
    [self save:value];
    [self updateStatusBar];
}

- (void) didChange:(id)stopwatch {
    [self updateStatusBar];
}

#pragma mark Notifications

- (void)notifyStart
{
    NSUserNotification* notification = [[NSUserNotification alloc] init];
    
    notification.title = @"Thyme";
    notification.informativeText = @"Started";
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

- (void)notifyPauseWithDescription:(NSString*)description
{
    NSUserNotification* notification = [[NSUserNotification alloc] init];
    
    notification.title = @"Thyme";
    notification.informativeText = [@"Paused at " stringByAppendingString:description];
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

- (void)notifyStopWithDescription:(NSString*)description
{
    NSUserNotification* notification = [[NSUserNotification alloc] init];
    
    notification.title = @"Thyme";
    notification.informativeText = [@"Stopped at " stringByAppendingString:description];
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

#pragma mark NSUserNotificationCenterDelegate

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    return YES;
}

#pragma mark NSUserDefaultsDidChangeNotification

- (void)onUserDefaultsChange:(NSNotification*)notification {
    [self resetHotKeys];
}

#pragma mark Hot Keys

- (void)clearHotKeys {
    [self.hotKeyCenter unregisterHotKeysWithTarget:self];
}

- (void)resetHotKeys {
    [self clearHotKeys];
    
    NSString *key = @"startPause";
    NSDictionary* playPauseCombo = [[NSUserDefaults standardUserDefaults] valueForKey:key];
    
    NSInteger keyCode = [[playPauseCombo valueForKey:@"keyCode"] integerValue];
    NSUInteger modifierKeys = [[playPauseCombo valueForKey:@"modifierFlags"] unsignedIntegerValue];
    
    [self.hotKeyCenter registerHotKeyWithKeyCode:keyCode modifierFlags:modifierKeys target:self action:@selector(startTimer) object:nil];
    
    NSDictionary* finishCombo = [[NSUserDefaults standardUserDefaults] valueForKey:@"finish"];
    keyCode = [[finishCombo valueForKey:@"keyCode"] integerValue];
    modifierKeys = [[finishCombo valueForKey:@"modifierFlags"] unsignedIntegerValue];
    
    [self.hotKeyCenter registerHotKeyWithKeyCode:keyCode modifierFlags:modifierKeys target:self action:@selector(resetTimer) object:nil];
}

#pragma mark NSApplication

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [window close];

    // Setup the hotkey center
    DDHotKeyCenter *center = [[DDHotKeyCenter alloc] init];
    self.hotKeyCenter = center;
    [center release];

    // Setup user defaults notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserDefaultsChange:) name:NSUserDefaultsDidChangeNotification object:nil];

    // Setup default key bindings
    NSDictionary *defaults = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"defaults" ofType:@"plist"]];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:defaults];                                  
    
    // Configure notifications
    [NSUserNotificationCenter defaultUserNotificationCenter].delegate = self;
    
    // Create class attributes
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:20];
    self.sessionsMenuItems = array;
    [array release];
    
    self.sessionsMenuSeparator = [NSMenuItem separatorItem];
    
    NSMenuItem *clearMenuItem = [[NSMenuItem alloc] initWithTitle:@"Clear" action:@selector(clear:) keyEquivalent:@""];
    self.sessionsMenuClearItem = clearMenuItem;
    [clearMenuItem release];
    
    self.stopwatch = [[Stopwatch alloc] initWithDelegate:self];
    
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    self.statusItem = [statusBar statusItemWithLength:46.0];
    [statusItem setHighlightMode:YES];
    [statusItem setMenu:menu];
    [self updateStatusBar];
    
    // Populate data
    for (Session *session in [Session allSessions]) {
        [self addSessionToMenu:session];
    }
    
    // Start controller
    [self resetWithNotification:NO];
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
        NSLog(@"%@: No model to generate a store from", [self class]);
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
        NSLog(@"%@: unable to commit editing before saving", [self class]);
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
    
    [self.stopwatch stop];
    
    if (![managedObjectContext commitEditing])
    {
        NSLog(@"%@: unable to commit editing to terminate", [self class]);
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
    
    self.stopwatch = nil;
    [statusItem release];
    [hotKeyCenter release];
    
    [sessionsMenuSeparator release];
    [sessionsMenuClearItem release];
    [sessionsMenuItems release];
	
    [super dealloc];
}

@end
