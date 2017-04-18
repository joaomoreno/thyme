//
//  TagWindowController.m
//  Thyme
//
//  Created by Marcus Kempe on 2017-04-18.
//
//

#import "TagWindowController.h"

@interface TagWindowController ()
- (void)onWindowResignKey;
@end

@implementation TagWindowController

@synthesize tagField;

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
    
    //[self.okButton bind:NSValueBinding toObject:defaults withKeyPath:@"values.askForTagOnFinishButton" options:nil];
}

#pragma mark SRRecorderControlDelegate

@end

