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

- (NSString *)pi_rgbRepresentation
{
    int r = (int)([self redComponent] * 255.0);
    int g = (int)([self greenComponent] * 255.0);
    int b = (int)([self blueComponent] * 255.0);
    
    return [NSString stringWithFormat:@"rgb(%d, %d, %d)", r, g, b];
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
