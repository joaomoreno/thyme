//
//  Timer.m
//  Thyme
//
//  Created by João on 3/16/13.
//
//

#import "Stopwatch.h"

@interface Stopwatch ()
@property (nonatomic, retain) NSTimer* timer;
@property (nonatomic, retain) NSDate* reference;
@property (nonatomic) NSTimeInterval accum;
@property (nonatomic) BOOL separatorIsActive;
- (void) tick;
@end

@implementation Stopwatch

@synthesize delegate;
@synthesize timer;
@synthesize reference;
@synthesize accum;
@synthesize separatorIsActive;

- (id)init {
    if (self = [super init]) {
        self.timer = nil;
        self.reference = [NSDate date];
        self.accum = 0;
        self.separatorIsActive = TRUE;
    }
    
    return self;
}

- (id)initWithDelegate:(id<StopwatchDelegate>)aDelegate {
    if (self = [self init]) {
        self.delegate = aDelegate;
    }
    
    return self;
}

- (NSString*) description {
    NSString *seperator = @":";
    
    long seconds = (long) floor([self value]);
    long hours = seconds / 3600;
    long minutes = (seconds / 60) % 60;
    seconds = seconds % 60;
    
    // Toggling seperator
    if(self.separatorIsActive || ![[NSUserDefaults standardUserDefaults] boolForKey:@"flashTimeSeparator"]) {
        seperator = @":";
        self.separatorIsActive = FALSE;
    }
    else {
        seperator = @" ";
        self.separatorIsActive = TRUE;
    }
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"hideSeconds"]) {
        return [NSString stringWithFormat:@"%02ld%@%02ld", hours, seperator, minutes];
    }
    else if (hours > 0) {
        return [NSString stringWithFormat:@"%02ld%@%02ld%@%02ld", hours, seperator, minutes, seperator, seconds];
    }
    else {
        return [NSString stringWithFormat:@"%02ld%@%02ld", minutes, seperator, seconds];
    }
}

- (NSTimeInterval) value {
    if (!self.timer) {
        return self.accum;
    }
    
    return [[NSDate date] timeIntervalSinceDate:reference] + self.accum;
}

- (BOOL) isActive {
    return self.timer != nil;
}

- (BOOL) isPaused {
    return self.timer == nil && self.accum > 0;
}

- (BOOL) isStopped {
    return self.timer == nil && self.accum == 0;
}

- (void) start {
    if ([self isActive]) {
        return;
    }
    
    self.reference = [NSDate date];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    
    if (self.delegate) {
        [self.delegate didStart:self];
        [self.delegate didChange:self];
    }
}

- (void) pause {
    if ([self isPaused]) {
        return;
    }
    
    self.accum = [self value];
    
    [self.timer invalidate];
    self.timer = nil;
    
    // Force the separator to show
    self.separatorIsActive = TRUE;
    
    if (self.delegate) {
        [self.delegate didPause:self];
    }
}

- (void) reset:(NSTimeInterval) value {
    self.accum = value;
    self.reference = [NSDate date];

    if (self.delegate) {
        [self.delegate didChange:self];
    }
}

- (void) stop {
    if ([self isStopped]) {
        return;
    }
    
    NSTimeInterval value = [self value];
    
    self.accum = 0;
    
    [self.timer invalidate];
    self.timer = nil;
    
    if (self.delegate) {
        [self.delegate didStop:self withValue:value];
    }
}

#pragma mark Private

- (void) tick {
    if (self.delegate) {
        [self.delegate didChange:self];
    }
}

@end
