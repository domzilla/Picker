//
//  PIPreviewImageGrabber.h
//  Picker
//
//  Created by Dominic Rodemer on 13.07.19.
//

#import <Cocoa/Cocoa.h>

@interface PIPreviewImageGrabber : NSObject

+ (NSImage *)imageForLocation:(NSPoint)mouseLocation;

@end
