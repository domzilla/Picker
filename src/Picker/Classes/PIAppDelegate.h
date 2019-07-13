//
//  PIAppDelegate.h
//  Picker
//
//  Created by Dominic Rodemer on 06.07.19.
//

#import <Cocoa/Cocoa.h>

@class PIPickerViewController;

@interface PIAppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate>
{
    PIPickerViewController *pickerViewController;
    
    NSStatusItem *statusItem;
    NSMenu *pickerMenu;
    
    NSMenuItem *pickerMenuItem;
    NSMenuItem *quitMenuItem;
}


@end

