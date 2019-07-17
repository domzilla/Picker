//
//  PIColorHistory.h
//  Picker
//
//  Created by Dominic Rodemer on 15.07.19.
//

#import <Cocoa/Cocoa.h>

extern NSString *const PIColorHistoryDidUpdateHistoryNotification;

@interface PIColorHistory : NSObject
{
    
}

+ (instancetype)defaultHistory;

+ (NSDictionary *)defaults;

- (void)pushColor:(NSColor *)color;
- (NSColor *)colorAtIndex:(NSUInteger)index;

@end
