//
//  PIAppDelegate.h
//  Picker
//
//  Created by Dominic Rodemer on 06.07.19.
//

#import <Cocoa/Cocoa.h>

@class PIPickerViewController;
@class PIPickerWindowController;
@class PIPreferencesWindowController;

@interface PIAppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate>
{
    PIPickerViewController *pickerViewController;
    PIPickerWindowController *pickerWindowController;
    PIPreferencesWindowController *preferencesWindowController;
    
    NSStatusItem *statusItem;
    NSMenu *pickerMenu;
    
    NSMenuItem *pickerMenuItem;
    NSMenuItem *colorCopyMenuItem;
    NSMenuItem *availableFormatsMenuItem;
    NSMenu *availableFormatsSubmenu;
    NSMenuItem *selectedFormatMenuItem;
    NSMenuItem *pinToScreenItem;
    NSMenuItem *pickerPreferencesItem;
    NSMenuItem *quitMenuItem;
}


@end
