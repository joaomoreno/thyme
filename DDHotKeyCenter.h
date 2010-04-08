/*
 DDHotKey -- DDHotKeyCenter.h
 
 Copyright (c) 2010, Dave DeLong <http://www.davedelong.com>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the author(s) or copyright holder(s) be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <Cocoa/Cocoa.h>

#define BUILD_FOR_SNOWLEOPARD (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_6)

#if BUILD_FOR_SNOWLEOPARD
//a convenient typedef for the required signature of a hotkey block callback
typedef void (^DDHotKeyTask)(NSEvent*);
#endif

@interface DDHotKeyCenter : NSObject {

}

/**
 Register a target/action hotkey.
 The modifierFlags must be a bitwise OR of NSCommandKeyMask, NSAlternateKeyMask, NSControlKeyMask, or NSShiftKeyMask;
 Returns YES if the hotkey was registered; NO otherwise.
 */
- (BOOL) registerHotKeyWithKeyCode:(unsigned short)keyCode modifierFlags:(NSUInteger)flags target:(id)target action:(SEL)action object:(id)object;

#if BUILD_FOR_SNOWLEOPARD
/**
 Register a block callback hotkey.
 The modifierFlags must be a bitwise OR of NSCommandKeyMask, NSAlternateKeyMask, NSControlKeyMask, or NSShiftKeyMask;
 Returns YES if the hotkey was registered; NO otherwise.
 */
- (BOOL) registerHotKeyWithKeyCode:(unsigned short)keyCode modifierFlags:(NSUInteger)flags task:(DDHotKeyTask)task;
#endif

/**
 See if a hotkey exists with the specified keycode and modifier flags.
 NOTE: this will only check among hotkeys you have explicitly registered. This does not check all globally registered hotkeys.
 */
- (BOOL) hasRegisteredHotKeyWithKeyCode:(unsigned short)keyCode modifierFlags:(NSUInteger)flags;

/**
 Unregister all hotkeys with a specific target
 */
- (void) unregisterHotKeysWithTarget:(id)target;

/**
 Unregister all hotkeys with a specific target and action
 */
- (void) unregisterHotKeysWithTarget:(id)target action:(SEL)action;

/**
 Unregister a hotkey with a specific keycode and modifier flags
 */
- (void) unregisterHotKeyWithKeyCode:(unsigned short)keyCode modifierFlags:(NSUInteger)flags;

@end
