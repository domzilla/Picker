//
//  PIAppDelegate.m
//  Picker
//
//  Created by Dominic Rodemer on 06.07.19.
//

#import "PIAppDelegate.h"

#import "PIPickerViewController.h"
#import "PIColorPicker.h"

@interface PIAppDelegate ()

@end

@implementation PIAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Hides icon on dock
    [NSApp setActivationPolicy: NSApplicationActivationPolicyProhibited];
    
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    statusItem.highlightMode = YES;
    statusItem.image = [NSImage imageNamed:@"menu_icon_dropper"];
    
    pickerMenu = [[NSMenu alloc] initWithTitle:@"Picker"];
    pickerMenu.delegate = self;
    statusItem.menu = pickerMenu;
    
    pickerViewController  = [[PIPickerViewController alloc] initWithNibName:@"PIPickerViewController" bundle:[NSBundle mainBundle]];
    pickerMenuItem = [[NSMenuItem alloc] initWithTitle:@"" action:NULL keyEquivalent:@""];
    pickerMenuItem.view = pickerViewController.view;
    [pickerMenu addItem:pickerMenuItem];
    
    [pickerMenu addItem:[NSMenuItem separatorItem]];
    quitMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Quit", @"Button to quit the application")
                                              action:@selector(quitMenuItemAction:)
                                       keyEquivalent:@"q"];
    [pickerMenu addItem:quitMenuItem];
    
    [[PIColorPicker defaultPicker] startTracking];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    
}



#pragma mark ---
#pragma mark Actions
#pragma mark ---
- (void)quitMenuItemAction:(id)sender
{
    [NSApp terminate:sender];
}



#pragma mark ---
#pragma mark NSMenuDelegate
#pragma mark ---
- (void)menuWillOpen:(NSMenu *)menu
{
    pickerViewController.shouldUpdateView = YES;
}

- (void)menuDidClose:(NSMenu *)menu
{
    pickerViewController.shouldUpdateView = NO;
}


@end
