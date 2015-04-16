//
//  Timer.h
//  Thyme
//
//  Created by João on 3/16/13.
//
//

#import <Foundation/Foundation.h>

// Delegate
@protocol StopwatchDelegate <NSObject>
- (void) didStart:(id)stopwatch;
- (void) didPause:(id)stopwatch;
- (void) didStop:(id)stopwatch withValue:(NSTimeInterval)value;
- (void) didChange:(id)stopwatch;
@end

// Timer
@interface Stopwatch : NSObject {
    id<StopwatchDelegate> delegate;
    
    @private
    NSTimer* timer;
    NSDate* reference;
    NSTimeInterval accum;
    BOOL seperatorIsActive;
}

@property (nonatomic, assign) id<StopwatchDelegate> delegate;

- (id) initWithDelegate:(id<StopwatchDelegate>)delegate;
- (NSString*) description;
- (NSTimeInterval) value;

- (BOOL) isActive;
- (BOOL) isPaused;
- (BOOL) isStopped;

- (void) start;
- (void) pause;
- (void) reset:(NSTimeInterval) value;
- (void) stop;

@end
