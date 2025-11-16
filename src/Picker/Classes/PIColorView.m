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
    NSRectFill(self.bounds);
    
    NSBezierPath *path = [NSBezierPath bezierPath];
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
