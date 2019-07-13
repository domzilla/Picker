//
//  PPIColorPicker.m
//  Picker
//
//  Created by Dominic Rodemer on 13.07.19.
//

#import "PIColorPicker.h"

#import "PIPreviewImageGrabber.h"


NSString *const PIColorPickerDidChangeColorNotification = @"PIColorPickerDidChangeColorNotification";


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
