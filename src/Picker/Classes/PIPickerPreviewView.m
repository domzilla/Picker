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
    
    [previewImage drawInRect:self.bounds fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    
    [[NSColor blackColor] set];
    
    float centerAdjust = 3.5f;
    float pickerRectX = self.bounds.origin.x + centerAdjust;
    float pickerRectY = self.bounds.origin.y - centerAdjust;
    
    [path moveToPoint:NSMakePoint(pickerRectX - centerAdjust, pickerRectY + self.bounds.size.width / 2)];
    [path lineToPoint:NSMakePoint(pickerRectX + self.bounds.size.width - centerAdjust, pickerRectY + self.bounds.size.height / 2)];
    
    [path moveToPoint:NSMakePoint(pickerRectX + self.bounds.size.width / 2, pickerRectY + self.bounds.size.height + centerAdjust)];
    [path lineToPoint:NSMakePoint(pickerRectX + self.bounds.size.width / 2, pickerRectY + centerAdjust)];
    
    [path stroke];
        
    [path moveToPoint:self.bounds.origin];
    [path lineToPoint:NSMakePoint(self.bounds.origin.x, NSMaxY(self.bounds))];
    [path lineToPoint:NSMakePoint(NSMaxX(self.bounds), NSMaxY(self.bounds))];
    [path lineToPoint:NSMakePoint(NSMaxX(self.bounds), self.bounds.origin.y)];
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
