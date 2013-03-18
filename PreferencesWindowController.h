//
//  PreferencesWindowController.h
//  Thyme
//
//  Created by João on 3/18/13.
//
//

#import <Cocoa/Cocoa.h>
#import "ShortcutRecorder/ShortcutRecorder.h"

@interface PreferencesWindowController : NSWindowController <SRRecorderControlDelegate> {
    SRRecorderControl *startPauseShortcutRecorder;
    SRRecorderControl *finishShortcutRecorder;
}

@property (nonatomic, retain) IBOutlet SRRecorderControl *startPauseShortcutRecorder;
@property (nonatomic, retain) IBOutlet SRRecorderControl *finishShortcutRecorder;

- (IBAction)onResetToDefaultsClick:(id)sender;

@end
