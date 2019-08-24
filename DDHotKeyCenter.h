/*
 DDHotKey -- DDHotKeyCenter.h
 
 Copyright (c) Dave DeLong <http://www.davedelong.com>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the author(s) or copyright holder(s) be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

//a convenient typedef for the required signature of a hotkey block callback
typedef void (^DDHotKeyTask)(NSEvent*);

@interface DDHotKey : NSObject

// creates a new hotkey but does not register it
+ (instancetype)hotKeyWithKeyCode:(unsigned short)keyCode modifierFlags:(NSUInteger)flags task:(DDHotKeyTask _Nullable)task;

@property (nonatomic, assign, readonly, nullable) id target;
@property (nonatomic, readonly, nullable) SEL action;
@property (nonatomic, strong, readonly, nullable) id object;
@property (nonatomic, copy, readonly, nullable) DDHotKeyTask task;

@property (nonatomic, readonly) unsigned short keyCode;
@property (nonatomic, readonly) NSUInteger modifierFlags;

@end

#pragma mark -

@interface DDHotKeyCenter : NSObject

@property (class, readonly, nonnull) DDHotKeyCenter *sharedHotKeyCenter;

/**
 Register a hotkey.
 */
- (DDHotKey * _Nullable)registerHotKey:(DDHotKey *)hotKey withError:(NSError **)error;

/**
 Register a target/action hotkey.
 The modifierFlags must be a bitwise OR of NSEventModifierFlagCommand, NSEventModifierFlagOption, NSEventModifierFlagControl, or NSEventModifierFlagShift;
 Returns the hotkey registered.  If registration failed, returns nil.
 */
- (DDHotKey * _Nullable)registerHotKeyWithKeyCode:(unsigned short)keyCode modifierFlags:(NSUInteger)flags target:(id)target action:(SEL)action object:(id)object error:(NSError **)error;

/**
 Register a block callback hotkey.
 The modifierFlags must be a bitwise OR of NSEventModifierFlagCommand, NSEventModifierFlagOption, NSEventModifierFlagControl, or NSEventModifierFlagShift;
 Returns the hotkey registered.  If registration failed, returns nil.
 */
- (DDHotKey * _Nullable)registerHotKeyWithKeyCode:(unsigned short)keyCode modifierFlags:(NSUInteger)flags task:(DDHotKeyTask)task error:(NSError **)error;

/**
 See if a hotkey exists with the specified keycode and modifier flags.
 NOTE: this will only check among hotkeys you have explicitly registered with DDHotKeyCenter. This does not check all globally registered hotkeys.
 */
- (BOOL)hasRegisteredHotKeyWithKeyCode:(unsigned short)keyCode modifierFlags:(NSUInteger)flags;

/**
 Unregister a specific hotkey
 */
- (void)unregisterHotKey:(DDHotKey *)hotKey;

/**
 Unregister all hotkeys
 */
- (void)unregisterAllHotKeys;

/**
 Unregister all hotkeys with a specific target
 */
- (void)unregisterHotKeysWithTarget:(id)target;

/**
 Unregister all hotkeys with a specific target and action
 */
- (void)unregisterHotKeysWithTarget:(id)target action:(SEL)action;

/**
 Unregister a hotkey with a specific keycode and modifier flags
 */
- (void)unregisterHotKeyWithKeyCode:(unsigned short)keyCode modifierFlags:(NSUInteger)flags;

/**
 Returns a set of currently registered hotkeys
 **/
- (NSSet<DDHotKey *> *)registeredHotKeys;

@end

NS_ASSUME_NONNULL_END
