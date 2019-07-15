//
//  PIColorButton.m
//  Picker
//
//  Created by Dominic Rodemer on 13.07.19.
//

#import "PIColorButton.h"

@implementation PIColorButton

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
        
        NSSize imageSize = NSMakeSize(self.frame.size.width, self.frame.size.height);
        NSImage *image = [[NSImage alloc] initWithSize:imageSize];
        [image lockFocus];
        [color drawSwatchInRect:NSMakeRect(0, 0, imageSize.width, imageSize.height)];
        [image unlockFocus];
        
        self.image = image;
    }
}

@end
