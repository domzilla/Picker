//
//  PIPreviewImageGrabber.m
//  Picker
//
//  Created by Dominic Rodemer on 13.07.19.
//

#import "PIPreviewImageGrabber.h"

#define kPIScreenGrabberImageWidth 28
#define kPIScreenGrabberImageHeight 28

@implementation PIPreviewImageGrabber

+ (NSImage *)imageForLocation:(NSPoint)mouseLocation;
{
    NSLog(@"%@", NSStringFromPoint(mouseLocation));
    
    CGRect imageRect = CGRectMake(mouseLocation.x - kPIScreenGrabberImageWidth / 2,
                                  mouseLocation.y - kPIScreenGrabberImageHeight / 2,
                                  kPIScreenGrabberImageWidth,
                                  kPIScreenGrabberImageHeight);
    
    CGImageRef imageRef = CGWindowListCreateImage(imageRect,
                                                  kCGWindowListOptionOnScreenOnly,
                                                  kCGNullWindowID,
                                                  kCGWindowImageShouldBeOpaque);
    NSImage *image = [[NSImage alloc] initWithCGImage:imageRef
                                                 size:NSMakeSize(kPIScreenGrabberImageWidth, kPIScreenGrabberImageHeight)];
    CGImageRelease(imageRef);
    
    return image;
    
}

@end
