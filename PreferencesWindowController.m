//
//  PreferencesWindowController.m
//  Thyme
//
//  Created by João on 3/18/13.
//
//

#import "PreferencesWindowController.h"

@interface PreferencesWindowController ()
- (void)onWindowResignKey;
@end

@implementation PreferencesWindowController

@synthesize startPauseShortcutRecorder;
@synthesize finishShortcutRecorder;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;

}
- (void)windowDidLoad
{
    [super windowDidLoad];
    
    NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
    [self.startPauseShortcutRecorder bind:NSValueBinding toObject:defaults withKeyPath:@"values.startPause" options:nil];
    [self.finishShortcutRecorder bind:NSValueBinding toObject:defaults withKeyPath:@"values.finish" options:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWindowResignKey) name:NSWindowDidResignKeyNotification object:nil];
}

- (void)onWindowResignKey {
    [self.window close];
}

- (IBAction)onResetToDefaultsClick:(id)sender {
    [[NSUserDefaultsController sharedUserDefaultsController] revertToInitialValues:nil];
}

#pragma mark SRRecorderControlDelegate

- (BOOL)shortcutRecorder:(SRRecorderControl *)aRecorder canRecordShortcut:(NSDictionary *)aShortcut {
    return !SRShortcutEqualToShortcut([self.startPauseShortcutRecorder objectValue], aShortcut) &&
           !SRShortcutEqualToShortcut([self.finishShortcutRecorder objectValue], aShortcut);
}

@end
