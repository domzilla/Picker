//
//  PIAppDelegate.h
//  Picker
//
//  Created by Dominic Rodemer on 06.07.19.
//

#import <Cocoa/Cocoa.h>

#import "PIPickerViewController.h"
#import "PIPickerWindowController.h"

@interface PIAppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate, PIPickerViewControllerDelegate>
{
    PIPickerViewController *pickerViewController;
    PIPickerWindowController *pickerWindowController;
    
    NSStatusItem *statusItem;
    NSMenu *pickerMenu;
    
    NSMenuItem *pickerMenuItem;
    
    NSMenuItem *availableFormatsMenuItem;
    NSMenu *availableFormatsSubmenu;
    NSMenuItem *selectedFormatMenuItem;
    
    NSMenuItem *quitMenuItem;
}


@end

