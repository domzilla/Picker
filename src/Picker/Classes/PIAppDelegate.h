//
//  PIAppDelegate.h
//  Picker
//
//  Created by Dominic Rodemer on 06.07.19.
//

#import <Cocoa/Cocoa.h>

@class PIPickerViewController;
@class PIPickerWindowController;

@interface PIAppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate>
{
    PIPickerViewController *pickerViewController;
    PIPickerWindowController *pickerWindowController;
    
    NSStatusItem *statusItem;
    NSMenu *pickerMenu;
    
    NSMenuItem *pickerMenuItem;
    
    NSMenuItem *availableFormatsMenuItem;
    NSMenu *availableFormatsSubmenu;
    NSMenuItem *selectedFormatMenuItem;
    
    NSMenuItem *pickerWindowItem;
    NSMenuItem *quitMenuItem;
}


@end

