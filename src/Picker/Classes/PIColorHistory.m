//
//  PIColorHistory.m
//  Picker
//
//  Created by Dominic Rodemer on 15.07.19.
//

#import "PIColorHistory.h"

NSString *const PIColorHistoryDidUpdateHistoryNotification = @"PIColorHistoryDidUpdateHistoryNotification";

NSString *const PIColorHistoryUserDefaultsHistoryKey = @"PIColorHistoryUserDefaultsHistoryKey";

@interface PIColorHistory ()

+ (NSData *)defaultColors;

@end

@implementation PIColorHistory

- (id)init
{
    if (self = [super init])
    {
        
    }
    
    return self;
}

+ (instancetype)defaultHistory
{
    static PIColorHistory *defaultHistory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultHistory = [[PIColorHistory alloc] init];
    });
    
    return defaultHistory;
}



#pragma mark ---
#pragma mark Public
#pragma mark ---
+ (NSDictionary *)defaults
{
    return @{PIColorHistoryUserDefaultsHistoryKey:[[self class] defaultColors]};
}

- (void)pushColor:(NSColor *)color
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSData *historyData = [defaults objectForKey:PIColorHistoryUserDefaultsHistoryKey];
    NSMutableArray *history = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:historyData]];
    
    [history insertObject:color atIndex:0];
    [history removeLastObject];
    
    NSData *updatedHistoryData = [NSKeyedArchiver archivedDataWithRootObject:history];
    [defaults setObject:updatedHistoryData forKey:PIColorHistoryUserDefaultsHistoryKey];
    [defaults synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PIColorHistoryDidUpdateHistoryNotification
                                                        object:self
                                                      userInfo:nil];
}

- (NSColor *)colorAtIndex:(NSUInteger)index
{
    NSColor *color = nil;
    
    NSData *historyData = [[NSUserDefaults standardUserDefaults] objectForKey:PIColorHistoryUserDefaultsHistoryKey];
    NSArray *history = [NSKeyedUnarchiver unarchiveObjectWithData:historyData];
    
    if (index < [history count])
        color = [history objectAtIndex:index];
    
    return color;
}



#pragma mark ---
#pragma mark Private
#pragma mark ---
+ (NSData *)defaultColors
{
    NSArray *defaultColors = @[[NSColor colorWithCalibratedRed:0.93 green:0.47 blue:0.24 alpha:1.0],
                               [NSColor colorWithCalibratedRed:0.13 green:0.80 blue:0.70 alpha:1.0],
                               [NSColor colorWithCalibratedRed:1.00 green:0.85 blue:0.19 alpha:1.0],
                               [NSColor colorWithCalibratedRed:0.09 green:0.54 blue:0.91 alpha:1.0],
                               [NSColor colorWithCalibratedRed:0.95 green:0.54 blue:0.14 alpha:1.0],
                               [NSColor colorWithCalibratedRed:0.54 green:0.96 blue:0.89 alpha:1.0]];
    
    return [NSKeyedArchiver archivedDataWithRootObject:defaultColors];
}

@end
