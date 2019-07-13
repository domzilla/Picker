//
//  NSColor+Picker.h
//  Picker
//
//  Created by Dominic Rodemer on 13.07.19.
//

#import <Cocoa/Cocoa.h>

@interface NSColor (Picker)

- (NSString *)pi_hexRepresentation;
- (NSString *)pi_rgbRepresentation;

- (NSString *)pi_hueRepresentation;
- (NSString *)pi_saturationRepresentation;
- (NSString *)pi_brightnessRepresentation;

@end
