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

- (void)pushColor:(NSColor *)color;
- (NSColor *)colorAtIndex:(NSUInteger)index;

@end
