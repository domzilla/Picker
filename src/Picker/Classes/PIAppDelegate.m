//
//  PIAppDelegate.m
//  Picker
//
//  Created by Dominic Rodemer on 06.07.19.
//

#import "PIAppDelegate.h"

#import <MASShortcut/Shortcut.h>

#import "PIColorPicker.h"

@interface PIAppDelegate ()

- (void)registerGlobalCopyColorHotkey;
- (void)unregisterGlobalCopyColorHotkey;

@end

@implementation PIAppDelegate

+ (void)initialize
{
    MASShortcut *defaultCopyShortcut = [MASShortcut shortcutWithKeyCode:kVK_ANSI_P modifierFlags:NSEventModifierFlagCommand | NSEventModifierFlagControl];
    NSData *defaultCopyShortcutData = [NSKeyedArchiver archivedDataWithRootObject:defaultCopyShortcut];
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{PIColorPickerUserDefaultsCopyShortcutKey:defaultCopyShortcutData}];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Hides icon on dock
    [NSApp setActivationPolicy:NSApplicationActivationPolicyProhibited];
    
    pickerWindowController = [[PIPickerWindowController alloc] init];
    
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    statusItem.highlightMode = YES;
    statusItem.image = [NSImage imageNamed:@"menu_icon_dropper"];
    
    pickerMenu = [[NSMenu alloc] initWithTitle:@"Picker"];
    pickerMenu.delegate = self;
    statusItem.menu = pickerMenu;
    
    pickerViewController  = [[PIPickerViewController alloc] initWithMode:PIPickerViewControllerModeMenu];
    pickerViewController.delegate = self;
    pickerMenuItem = [[NSMenuItem alloc] initWithTitle:@"" action:NULL keyEquivalent:@""];
    pickerMenuItem.view = pickerViewController.view;
    [pickerMenu addItem:pickerMenuItem];
    
    //Hidden dummy item for local shortcut
    NSMenuItem *copyColorMenuItem =[[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Copy color", @"Button to copy the current color to clipboard")
                                                              action:@selector(copyColorMenuItemAction:)
                                                       keyEquivalent:@"p"];
    copyColorMenuItem.keyEquivalentModifierMask = NSEventModifierFlagControl | NSEventModifierFlagCommand;
    copyColorMenuItem.allowsKeyEquivalentWhenHidden = YES;
    copyColorMenuItem.hidden = YES;
    [pickerMenu addItem:copyColorMenuItem];
    
    [pickerMenu addItem:[NSMenuItem separatorItem]];
    availableFormatsMenuItem = [[NSMenuItem alloc] init];
    availableFormatsMenuItem.title = NSLocalizedString(@"Color format", @"The headline for the color format which gets copied to clipboard");
    availableFormatsSubmenu = [[NSMenu alloc] init];
    for (PIColorPickerFormat format = 0; format < PIColorPickerFormatsCount; format++)
    {
        [availableFormatsSubmenu addItemWithTitle:PIColorPickerFormatToString(format)
                                           action:@selector(formatSubmenuItemAction:)
                                    keyEquivalent:@""];
    }
    selectedFormatMenuItem = [availableFormatsSubmenu itemAtIndex:[[PIColorPicker defaultPicker] pickerFormat]];
    selectedFormatMenuItem.state = NSOnState;
    [availableFormatsMenuItem setSubmenu:availableFormatsSubmenu];
    [pickerMenu addItem:availableFormatsMenuItem];
    
    [pickerMenu addItem:[NSMenuItem separatorItem]];
    quitMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Quit", @"Button to quit the application")
                                              action:@selector(quitMenuItemAction:)
                                       keyEquivalent:@"q"];
    [pickerMenu addItem:quitMenuItem];
    
    [[PIColorPicker defaultPicker] startTracking];
    
    [self registerGlobalCopyColorHotkey];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    
}



#pragma mark ---
#pragma mark Actions
#pragma mark ---
- (void)copyColorMenuItemAction:(id)sender
{
    NSLog(@"Copy local");
    [[PIColorPicker defaultPicker] copyColorToPasteboard];
}

- (void)formatSubmenuItemAction:(id)sender
{
    NSMenuItem *menuItem = (NSMenuItem *)sender;
    
    selectedFormatMenuItem.state = NSOffState;
    selectedFormatMenuItem = menuItem;
    selectedFormatMenuItem.state = NSOnState;
    
    PIColorPickerFormat pickerFormat = (PIColorPickerFormat)[availableFormatsSubmenu indexOfItem:selectedFormatMenuItem];
    [[PIColorPicker defaultPicker] setPickerFormat:pickerFormat];
}

- (void)quitMenuItemAction:(id)sender
{
    [NSApp terminate:sender];
}



#pragma mark ---
#pragma mark Private
#pragma mark ---
- (void)registerGlobalCopyColorHotkey
{
    MASShortcut *shortcut = [MASShortcut shortcutWithKeyCode:kVK_ANSI_P modifierFlags:NSEventModifierFlagControl | NSEventModifierFlagCommand];
    [[MASShortcutMonitor sharedMonitor] registerShortcut:shortcut withAction:^{
        
        NSLog(@"Copy global");
        [[PIColorPicker defaultPicker] copyColorToPasteboard];
        
        [self->statusItem.button setHighlighted:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self->statusItem.button setHighlighted:NO];
        });
    }];
}

- (void)unregisterGlobalCopyColorHotkey
{
    MASShortcut *shortcut = [MASShortcut shortcutWithKeyCode:kVK_ANSI_P modifierFlags:NSEventModifierFlagControl | NSEventModifierFlagCommand];
    [[MASShortcutMonitor sharedMonitor] unregisterShortcut:shortcut];
}



#pragma mark ---
#pragma mark PIPickerViewControllerDelegate
#pragma mark ---
- (void)pickerViewControllerPinToWindow:(PIPickerViewController *)controller
{
    NSRect menuFrame = [pickerMenuItem.view.window convertRectToScreen:pickerMenuItem.view.frame];
    NSRect windowFrame = NSMakeRect(menuFrame.origin.x,
                                    menuFrame.origin.y,
                                    pickerWindowController.window.frame.size.width,
                                    pickerWindowController.window.frame.size.height);
    [pickerWindowController.window setFrame:windowFrame display:NO];
    
    [pickerMenu cancelTracking];
    [pickerWindowController showWindow:nil];
}



#pragma mark ---
#pragma mark NSMenuDelegate
#pragma mark ---
- (void)menuWillOpen:(NSMenu *)menu
{
    pickerViewController.shouldUpdateView = YES;
    [self unregisterGlobalCopyColorHotkey];
}

- (void)menuDidClose:(NSMenu *)menu
{
    pickerViewController.shouldUpdateView = NO;
    [self registerGlobalCopyColorHotkey];
}

@end
