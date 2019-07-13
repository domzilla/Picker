//
//  PIColorView.h
//  Picker
//
//  Created by Dominic Rodemer on 13.07.19.
//

#import <Cocoa/Cocoa.h>

@interface PIColorView : NSView
{
    NSColor *color;
}

@property (nonatomic, strong) NSColor *color;

@end
