//
//  PIColorPicker.h
//  Picker
//
//  Created by Dominic Rodemer on 13.07.19.
//

#import <Cocoa/Cocoa.h>

extern NSString *const PIColorPickerDidChangeColorNotification;

@interface PIColorPicker : NSObject
{
    NSPoint mouseLocation;
    
    BOOL tracking;
}

@property (nonatomic, readonly) NSPoint mouseLocation;
@property (nonatomic, readonly) BOOL tracking;

+ (instancetype)defaultPicker;

- (void)startTracking;
- (void)stopTracking;

- (NSColor *)color;
- (NSImage *)previewImage;

@end
