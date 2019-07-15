//
//  PPIColorPicker.m
//  Picker
//
//  Created by Dominic Rodemer on 13.07.19.
//

#import "PIColorPicker.h"

#import "PIPreviewImageGrabber.h"
#import "PIColorHistory.h"
#import "NSColor+Picker.h"

NSString *const PIColorPickerDidChangeColorNotification = @"PIColorPickerDidChangeColorNotification";

NSString *const PIColorPickerUserDefaultsFormatKey = @"PIColorPickerUserDefaultsFormatKey";
NSString *const PIColorPickerUserDefaultsCopyShortcutKey = @"PIColorPickerUserDefaultsCopyShortcutKey";

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
        
        [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskMouseMoved handler:^NSEvent * (NSEvent *event) {
            
            [self updateMouseLocation];
            
            return event;
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

- (void)copyColorToPasteboard
{
    [self copyColorToPasteboardSaveToHistory:YES];
}

- (void)copyColorToPasteboardSaveToHistory:(BOOL)save
{
    [self copyColorToPasteboard:[self color] saveToHistory:YES];
}

- (void)copyColorToPasteboard:(NSColor *)color saveToHistory:(BOOL)save
{
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
    
    NSString *colorString = nil;
    
    switch (pickerFormat)
    {
        case PIColorPickerFormatHEX:
            colorString = [color pi_hexRepresentation];
            break;
        case PIColorPickerFormatNoHashHEX:
            colorString = [color pi_noHashHexRepresentation];
            break;
        case PIColorPickerFormatRGB:
            colorString = [color pi_rgbRepresentation];
            break;
        case PIColorPickerFormatHSB:
            colorString = [color pi_hsbRepresentation];;
            break;
        case PIColorPickerFormatCMYK:
            colorString = [color pi_cmykRepresentation];;
            break;
        case PIColorPickerFormatUIColor:
            colorString = [color pi_UIColorRepresentation];;
            break;
        case PIColorPickerFormatUIColorSwift:
            colorString = [color pi_UIColorSwiftRepresentation];;
            break;
        case PIColorPickerFormatNSColor:
            colorString = [color pi_NScolorRepresentation];;
            break;
        case PIColorPickerFormatNSColorSwift:
            colorString = [color pi_NSColorSwiftbRepresentation];;
            break;
        case PIColorPickerFormatsCount:
        default:
            break;
    }
    
    [pasteBoard setString:colorString forType:NSStringPboardType];
    
    if (save)
    {
        [[PIColorHistory defaultHistory] pushColor:color];
    }
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
