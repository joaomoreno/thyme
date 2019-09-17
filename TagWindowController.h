//
//  TagWindowController.h
//  Thyme
//
//  Created by Marcus Kempe on 2017-04-18.
//
//

//#ifndef TagWindowController_h
//#define TagWindowController_h



//#endif /* TagWindowController_h */

#import <Cocoa/Cocoa.h>
#import "ShortcutRecorder/ShortcutRecorder.h"

@interface TagWindowController : NSWindowController {
    NSButton *okButton;
    NSButton *cancelButton;
    NSTextField *tagField;
}

@property (nonatomic, retain) IBOutlet NSTextField *tagField;

@end
