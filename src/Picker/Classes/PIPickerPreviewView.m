//
//  PIPickerPreviewView.m
//  Picker
//
//  Created by Dominic Rodemer on 13.07.19.
//

#import "PIPickerPreviewView.h"

@implementation PIPickerPreviewView

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    if (!previewImage)
        return;
    
    [previewImage drawInRect:dirtyRect fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    
    [[NSColor blackColor] set];
    
    float centerAdjust = 3.5f;
    float pickerRectX = dirtyRect.origin.x + centerAdjust;
    float pickerRectY = dirtyRect.origin.y - centerAdjust;
    
    [path moveToPoint:NSMakePoint(pickerRectX - centerAdjust, pickerRectY + dirtyRect.size.width / 2)];
    [path lineToPoint:NSMakePoint(pickerRectX + dirtyRect.size.width - centerAdjust, pickerRectY + dirtyRect.size.height / 2)];
    
    [path moveToPoint:NSMakePoint(pickerRectX + dirtyRect.size.width / 2, pickerRectY + dirtyRect.size.height + centerAdjust)];
    [path lineToPoint:NSMakePoint(pickerRectX + dirtyRect.size.width / 2, pickerRectY + centerAdjust)];
    
    [path stroke];
    
    // Draw border
    //NSBezierPath *path = [NSBezierPath bezierPath];
    
    [path moveToPoint:dirtyRect.origin];
    [path lineToPoint:NSMakePoint(dirtyRect.origin.x, NSMaxY(dirtyRect))];
    [path lineToPoint:NSMakePoint(NSMaxX(dirtyRect), NSMaxY(dirtyRect))];
    [path lineToPoint:NSMakePoint(NSMaxX(dirtyRect), dirtyRect.origin.y)];
    [path closePath];
    
    [[NSColor lightGrayColor] set];
    [path stroke];
}



#pragma mark ---
#pragma mark Accessors
#pragma mark ---
- (NSImage *)previewImage
{
    return previewImage;
}

- (void)setPreviewImage:(NSImage *)aPreviewImage
{
    if (previewImage != aPreviewImage)
    {
        previewImage = aPreviewImage;
        [self setNeedsDisplay:YES];
    }
}

@end
