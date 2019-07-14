//
//  NSColor+Picker.h
//  Picker
//
//  Created by Dominic Rodemer on 13.07.19.
//

#import <Cocoa/Cocoa.h>

@interface NSColor (Picker)

- (NSString *)pi_hexRepresentation;
- (NSString *)pi_noHashHexRepresentation;
- (NSString *)pi_rgbRepresentation;
- (NSString *)pi_hsbRepresentation;
- (NSString *)pi_cmykRepresentation;
- (NSString *)pi_UIColorRepresentation;
- (NSString *)pi_UIColorSwiftRepresentation;
- (NSString *)pi_NScolorRepresentation;
- (NSString *)pi_NSColorSwiftbRepresentation;

- (NSString *)pi_hueRepresentation;
- (NSString *)pi_saturationRepresentation;
- (NSString *)pi_brightnessRepresentation;

@end
