// 
//  Session.m
//  Thyme
//
//  Created by João Moreno on 6/4/10.
//

#import "Session.h"
#import "ThymeAppDelegate.h"

#define AppDelegate ((ThymeAppDelegate*) [[NSApplication sharedApplication] delegate])

@interface Session(hidden)
- (NSString*)formattedDate;
@end


@implementation Session 

@dynamic tag;
@dynamic hours;
@dynamic minutes;
@dynamic seconds;
@dynamic date;

- (NSString*)formatDate
{
    static NSDateFormatter *dateFormatter = nil;
    
    if (dateFormatter == nil)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    }
    
    return [dateFormatter stringFromDate:self.date];
}

+ (NSArray*)allSessions
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[[AppDelegate.managedObjectModel entitiesByName] valueForKey:@"Session"]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date"
                                                                   ascending:YES
                                                                  comparator:^NSComparisonResult(NSDate* a, NSDate* b) {
                                                                      return [b compare:a];
                                                                  }];
    
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSArray *result = [AppDelegate.managedObjectContext executeFetchRequest:request error:nil];
    [request release];
    
    return result;
}

+ (NSArray*)allSessionsAsDictionaries
{
    NSArray *sessions = [Session allSessions];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:sessions.count];
    
    [sessions enumerateObjectsUsingBlock:^(Session *session, NSUInteger index, BOOL *stop) {
        [result addObject:[session asDictionary]];
    }];
    
    return result;
}

+ (Session*)sessionWithSeconds:(NSInteger)_seconds minutes:(NSInteger)_minutes hours:(NSInteger)_hours tag:(NSString*)_tag
{
    Session* session = (Session*) [NSEntityDescription insertNewObjectForEntityForName:@"Session" 
                                                     inManagedObjectContext:AppDelegate.managedObjectContext];

    session.tag = _tag;
    session.hours = [NSNumber numberWithInt:_hours];
    session.minutes = [NSNumber numberWithInt:_minutes];
    session.seconds = [NSNumber numberWithInt:_seconds];
    session.date = [NSDate date];
    
    return session;
}

- (NSString*)timeStringRepresentation
{
    if ([self.hours intValue] > 0)
        return [NSString stringWithFormat:@"%02d:%02d:%02d", [self.hours intValue], [self.minutes intValue], [self.seconds intValue]];
    else
        return [NSString stringWithFormat:@"%02d:%02d", [self.minutes intValue], [self.seconds intValue]];
}

- (NSString*)stringRepresentation
{
    NSString* formatString = @"%@ - %@ - %@";
    if([self.tag isEqual: @""]){
       formatString = @"%@ - %@";
    }
    return [NSString stringWithFormat:formatString, [self timeStringRepresentation], [self formatDate], [self tag]];
}

- (NSDictionary*)asDictionary
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    
    NSNumber *duration = [NSNumber numberWithUnsignedInteger:[self.seconds unsignedIntegerValue]
        + (([self.minutes unsignedIntegerValue] + ([self.hours unsignedIntegerValue] * 60)) * 60)];
    
    NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:
                            [dateFormatter stringFromDate:self.date], @"date",
                            duration, @"duration",
                            self.tag, @"tag",
                            nil];
    
    [dateFormatter release];
    
    return result;
}

@end
