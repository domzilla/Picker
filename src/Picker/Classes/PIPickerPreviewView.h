//
//  PIPickerPreviewView.h
//  Picker
//
//  Created by Dominic Rodemer on 13.07.19.
//

#import <Cocoa/Cocoa.h>

@interface PIPickerPreviewView : NSView
{
    NSImage *previewImage;
}

@property (nonatomic, strong) NSImage *previewImage;

@end
