//
//  PIColorPicker.h
//  Picker
//
//  Created by Dominic Rodemer on 13.07.19.
//

#import <Cocoa/Cocoa.h>

extern NSString *const PIColorPickerDidChangeColorNotification;

typedef NS_ENUM(NSUInteger, PIColorPickerFormat) {
    PIColorPickerFormatHEX,
    PIColorPickerFormatNoHashHEX,
    PIColorPickerFormatRGB,
    PIColorPickerFormatHSB,
    PIColorPickerFormatCMYK,
    PIColorPickerFormatUIColor,
    PIColorPickerFormatUIColorSwift,
    PIColorPickerFormatNSColor,
    PIColorPickerFormatNSColorSwift,
    
    PIColorPickerFormatsCount
};

NSString *PIColorPickerFormatToString(PIColorPickerFormat format);

@interface PIColorPicker : NSObject
{
    PIColorPickerFormat pickerFormat;
    
    NSPoint mouseLocation;
    
    BOOL tracking;
}

@property (nonatomic, readonly) NSPoint mouseLocation;
@property (nonatomic, readonly) BOOL tracking;

@property (nonatomic) PIColorPickerFormat pickerFormat;

+ (instancetype)defaultPicker;

- (void)startTracking;
- (void)stopTracking;

- (NSColor *)color;
- (NSImage *)previewImage;

@end
