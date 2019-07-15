//
//  PIColorButton.h
//  Picker
//
//  Created by Dominic Rodemer on 13.07.19.
//

#import <Cocoa/Cocoa.h>

@interface PIColorButton : NSButton
{
    NSColor *color;
}

@property (nonatomic, strong) NSColor *color;

@end
