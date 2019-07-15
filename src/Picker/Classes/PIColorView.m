//
//  PIColorView.m
//  Picker
//
//  Created by Dominic Rodemer on 15.07.19.
//

#import "PIColorView.h"

@implementation PIColorView

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    if (!color)
        color = [NSColor whiteColor];
    
    [color set];
    NSRectFill(dirtyRect);
    
    NSBezierPath *path = [NSBezierPath bezierPath];
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
- (NSColor *)color
{
    return color;
}

- (void)setColor:(NSColor *)aColor
{
    if (color != aColor)
    {
        color = aColor;
        [self setNeedsDisplay:YES];
    }
}

@end
