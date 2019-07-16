//
//  PIAppDelegate.m
//  Picker
//
//  Created by Dominic Rodemer on 06.07.19.
//

#import "PIAppDelegate.h"

#import <MASShortcut/Shortcut.h>

#import "PIPickerViewController.h"
#import "PIPickerWindowController.h"
#import "PIColorPicker.h"

@interface PIAppDelegate ()

- (void)registerGlobalHotkeys;
- (void)unregisterGlobalHotkeys;

- (void)showPickerWindow;

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
    [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
    
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    statusItem.highlightMode = YES;
    statusItem.image = [NSImage imageNamed:@"menu_icon_dropper"];
    
    pickerMenu = [[NSMenu alloc] initWithTitle:@"Picker"];
    pickerMenu.delegate = self;
    statusItem.menu = pickerMenu;
    
    pickerViewController  = [[PIPickerViewController alloc] initWithMode:PIPickerViewControllerModeMenu];
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
    
    pickerWindowItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Pin on screen", @"Button to pin the window on screen")
                                                  action:@selector(pickerWindowItemAction:)
                                           keyEquivalent:@"p"];
    pickerWindowItem.keyEquivalentModifierMask = NSEventModifierFlagControl | NSEventModifierFlagCommand | NSEventModifierFlagOption;
    [pickerMenu addItem:pickerWindowItem];
    
    [pickerMenu addItem:[NSMenuItem separatorItem]];
    quitMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Quit", @"Button to quit the application")
                                              action:@selector(quitMenuItemAction:)
                                       keyEquivalent:@"q"];
    [pickerMenu addItem:quitMenuItem];
    
    [[PIColorPicker defaultPicker] startTracking];
    
    [self registerGlobalHotkeys];
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

- (void)pickerWindowItemAction:(id)sender
{
    [self showPickerWindow];
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
- (void)registerGlobalHotkeys
{
    MASShortcut *copyColorShortcut = [MASShortcut shortcutWithKeyCode:kVK_ANSI_P modifierFlags:NSEventModifierFlagControl | NSEventModifierFlagCommand];
    [[MASShortcutMonitor sharedMonitor] registerShortcut:copyColorShortcut withAction:^{
        
        NSLog(@"Copy global");
        [[PIColorPicker defaultPicker] copyColorToPasteboard];
        
        [self->statusItem.button setHighlighted:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self->statusItem.button setHighlighted:NO];
        });
    }];
    
    MASShortcut *showWindowShortcut = [MASShortcut shortcutWithKeyCode:kVK_ANSI_P modifierFlags:NSEventModifierFlagControl | NSEventModifierFlagCommand | NSEventModifierFlagOption];
    [[MASShortcutMonitor sharedMonitor] registerShortcut:showWindowShortcut withAction:^{
        
        [self showPickerWindow];
    }];
}

- (void)unregisterGlobalHotkeys
{
    MASShortcut *copyColorShortcut = [MASShortcut shortcutWithKeyCode:kVK_ANSI_P modifierFlags:NSEventModifierFlagControl | NSEventModifierFlagCommand];
    [[MASShortcutMonitor sharedMonitor] unregisterShortcut:copyColorShortcut];
    
    MASShortcut *showWindowShortcut = [MASShortcut shortcutWithKeyCode:kVK_ANSI_P modifierFlags:NSEventModifierFlagControl | NSEventModifierFlagCommand | NSEventModifierFlagOption];
    [[MASShortcutMonitor sharedMonitor] unregisterShortcut:showWindowShortcut];
}

- (void)showPickerWindow
{
    if (pickerWindowController == nil)
    {
        pickerWindowController = [[PIPickerWindowController alloc] init];
        
        NSRect statusItemWindowRect = [statusItem.button convertRect:statusItem.button.bounds toView:nil];
        NSRect statusItemScreenRect = [statusItem.button.window convertRectToScreen:statusItemWindowRect];
        
        CGFloat originX = statusItemScreenRect.origin.x;
        NSRect screenRect = [[NSScreen mainScreen] frame];
        if (originX + pickerWindowController.window.frame.size.width + 20.0 > screenRect.size.width)
            originX = statusItemScreenRect.origin.x - pickerWindowController.window.frame.size.width + statusItemScreenRect.size.width;
        
        NSRect windowFrame = NSMakeRect(originX,
                                        statusItemScreenRect.origin.y - pickerWindowController.window.frame.size.height,
                                        pickerWindowController.window.frame.size.width,
                                        pickerWindowController.window.frame.size.height);
        [pickerWindowController.window setFrame:windowFrame display:NO];
        
    }
    
    [pickerMenu cancelTracking];
    [pickerWindowController showWindow:nil];
}



#pragma mark ---
#pragma mark NSMenuDelegate
#pragma mark ---
- (void)menuWillOpen:(NSMenu *)menu
{
    pickerViewController.shouldUpdateView = YES;
    [self unregisterGlobalHotkeys];
}

- (void)menuDidClose:(NSMenu *)menu
{
    pickerViewController.shouldUpdateView = NO;
    [self registerGlobalHotkeys];
}

@end
