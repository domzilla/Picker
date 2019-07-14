//
//  PPIColorPicker.m
//  Picker
//
//  Created by Dominic Rodemer on 13.07.19.
//

#import "PIColorPicker.h"

#import "PIPreviewImageGrabber.h"


NSString *const PIColorPickerDidChangeColorNotification = @"PIColorPickerDidChangeColorNotification";


NSString *const PIColorPickerUserDefaultsFormatKey = @"PIColorPickerUserDefaultsFormatKey";

NSString *PIColorPickerFormatToString(PIColorPickerFormat format)
{
    switch (format)
    {
        case PIColorPickerFormatHEX:
            return @"#ff00ff";
        case PIColorPickerFormatNoHashHEX:
            return @"ff00ff";
        case PIColorPickerFormatRGB:
            return @"rbg(255, 0, 255)";
        case PIColorPickerFormatHSB:
            return @"hsb(300, 100, 100)";
        case PIColorPickerFormatCMYK:
            return @"cmyk(184, 224, 0, 0)";
        case PIColorPickerFormatUIColor:
            return @"UIColor Objective-C";
        case PIColorPickerFormatUIColorSwift:
            return @"UIColor Swift";
        case PIColorPickerFormatNSColor:
            return @"NSColor Objective-C";
        case PIColorPickerFormatNSColorSwift:
            return @"NSColor Swift";
        case PIColorPickerFormatsCount:
        default:
            return nil;
    }
}


@interface PIColorPicker ()

- (void)updateMouseLocation;

@end


@implementation PIColorPicker

@synthesize mouseLocation;
@synthesize tracking;

- (id)init
{
    if (self = [super init])
    {
        pickerFormat = (PIColorPickerFormat)[[NSUserDefaults standardUserDefaults] integerForKey:PIColorPickerUserDefaultsFormatKey];
        
        [NSEvent addGlobalMonitorForEventsMatchingMask:NSEventMaskMouseMoved handler:^ (NSEvent *event){
            [self updateMouseLocation];
        }];
    }
    
    return self;
}

+ (instancetype)defaultPicker
{
    static PIColorPicker *defaultPicker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultPicker = [[PIColorPicker alloc] init];
    });
    
    return defaultPicker;
}



#pragma mark ---
#pragma mark Accessors
#pragma mark ---
- (PIColorPickerFormat)pickerFormat
{
    return pickerFormat;
}

- (void)setPickerFormat:(PIColorPickerFormat)aPickerFormat
{
    [self willChangeValueForKey:@"pickerFormat"];
    pickerFormat = aPickerFormat;
    [[NSUserDefaults standardUserDefaults] setInteger:(NSInteger)pickerFormat forKey:PIColorPickerUserDefaultsFormatKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self didChangeValueForKey:@"pickerFormat"];
}



#pragma mark ---
#pragma mark Public
#pragma mark ---
- (void)startTracking
{
    if (tracking)
        return;
    
    tracking = YES;
}

- (void)stopTracking
{
    tracking = NO;
}

- (NSColor *)color
{
    CGRect imageRect = CGRectMake(mouseLocation.x, mouseLocation.y, 1, 1);
    CGImageRef imageRef = CGWindowListCreateImage(imageRect, kCGWindowListOptionOnScreenOnly, kCGNullWindowID, kCGWindowImageDefault);
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return [bitmap colorAtX:0 y:0];
}

- (NSImage *)previewImage
{
    return [PIPreviewImageGrabber imageForLocation:mouseLocation];
}



#pragma mark ---
#pragma mark Private
#pragma mark ---
- (void)updateMouseLocation
{
    if (!self->tracking)
        return;
    
    NSPoint rawMouseLocation = [NSEvent mouseLocation];
    NSScreen *principalScreen = [[NSScreen screens] objectAtIndex:0];
    self->mouseLocation = NSMakePoint(rawMouseLocation.x, principalScreen.frame.size.height - rawMouseLocation.y);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PIColorPickerDidChangeColorNotification
                                                        object:self
                                                      userInfo:nil];
}

@end
