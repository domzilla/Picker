//
//  NSColor+Picker.m
//  Picker
//
//  Created by Dominic Rodemer on 13.07.19.
//

#import "NSColor+Picker.h"

#import <BGFoundation/BGFoundation.h>

@implementation NSColor (Picker)

- (NSString *)pi_hexRepresentation
{
    return [NSString stringWithFormat:@"#%@", [[self bg_hexStringFromColor] substringToIndex:6]]; //Do not show alpha bits
}

- (NSString *)pi_noHashHexRepresentation
{
        return [[self bg_hexStringFromColor] substringToIndex:6]; //Do not show alpha bits
}

- (NSString *)pi_rgbRepresentation
{
    int r = (int)([self redComponent] * 255.0);
    int g = (int)([self greenComponent] * 255.0);
    int b = (int)([self blueComponent] * 255.0);
    
    return [NSString stringWithFormat:@"rgb(%d, %d, %d)", r, g, b];
}

- (NSString *)pi_hsbRepresentation
{
    int h = (int)([self hueComponent] * 360);
    int s = (int)([self saturationComponent] * 100);
    int b = (int)([self saturationComponent] * 100);
    
    return [NSString stringWithFormat:@"hsb(%d, %d, %d)", h, s, b];
}

- (NSString *)pi_cmykRepresentation
{
    int c = (int)([self cyanComponent] * 255.0);
    int m = (int)([self magentaComponent] * 255.0);
    int y = (int)([self yellowComponent] * 255.0);
    int k = (int)([self blackComponent] * 255.0);
    
    return [NSString stringWithFormat:@"cmyk(%d, %d, %d, %d)", c, m, y, k];
}

- (NSString *)pi_UIColorRepresentation
{
    CGFloat r = [self redComponent];
    CGFloat g = [self greenComponent];
    CGFloat b = [self blueComponent];
    
    if (r == g == b)
       return [NSString stringWithFormat:@"[UIColor colorWithWhite:%.2f alpha:1.0]", r];

    return [NSString stringWithFormat:@"[UIColor colorWithRed:%.2f green:%.2f blue:%.2f alpha:1.0]", r, g, b];
}

- (NSString *)pi_UIColorSwiftRepresentation
{
    CGFloat r = [self redComponent];
    CGFloat g = [self greenComponent];
    CGFloat b = [self blueComponent];
    
    if (r == g == b)
        return [NSString stringWithFormat:@"UIColor(white:%.2f alpha:1.0)", r];
    
    return [NSString stringWithFormat:@"UIColor(red:%.2f green:%.2f blue:%.2f alpha:1.0)", r, g, b];
}

- (NSString *)pi_NScolorRepresentation
{
    CGFloat r = [self redComponent];
    CGFloat g = [self greenComponent];
    CGFloat b = [self blueComponent];
    
    if (r == g == b)
        return [NSString stringWithFormat:@"[NSColor colorWithCalibratedWhite:%.2f alpha:1.0]", r];
    
    return [NSString stringWithFormat:@"[NSColor colorWithCalibratedRed:%.2f green:%.2f blue:%.2f alpha:1.0]", r, g, b];
}

- (NSString *)pi_NSColorSwiftbRepresentation
{
    CGFloat r = [self redComponent];
    CGFloat g = [self greenComponent];
    CGFloat b = [self blueComponent];
    
    if (r == g == b)
        return [NSString stringWithFormat:@"NSColor(calibratedWhite:%.2f alpha:1.0)", r];
    
    return [NSString stringWithFormat:@"NSColor(calibratedRed:%.2f green:%.2f blue:%.2f alpha:1.0)", r, g, b];
}

- (NSString *)pi_hueRepresentation
{
    return [NSString stringWithFormat:@"%d°", (int)([self hueComponent] * 360)];
}

- (NSString *)pi_saturationRepresentation
{
    return [NSString stringWithFormat:@"%d%%", (int)([self saturationComponent] * 100)];
}

- (NSString *)pi_brightnessRepresentation
{
    return [NSString stringWithFormat:@"%d%%", (int)([self brightnessComponent] * 100)];
}

@end
