//
//  PIAppDelegate.m
//  Picker
//
//  Created by Dominic Rodemer on 06.07.19.
//

#import "PIAppDelegate.h"

#import <BGDataBinding/BGDataBinding.h>
#import <MASShortcut/Shortcut.h>

#import "PIPickerViewController.h"
#import "PIPickerWindowController.h"
#import "PIPreferencesWindowController.h"
#import "PIColorPicker.h"
#import "PIColorHistory.h"
#import "PIPreferences.h"

@interface PIAppDelegate ()

- (void)registerGlobalHotkeys;
- (void)unregisterGlobalHotkeys;

- (void)registerColorCopyShortcut;
- (void)registerPinToScreenShortcut;

- (void)showPickerWindow;
- (void)showPreferencesWindow;

@end

@implementation PIAppDelegate

+ (void)initialize
{
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    [defaults addEntriesFromDictionary:[PIPreferences defaults]];
    [defaults addEntriesFromDictionary:[PIColorPicker defaults]];
    [defaults addEntriesFromDictionary:[PIColorHistory defaults]];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
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
    
    //Hidden dummy item for local copy shortcut
    colorCopyMenuItem =[[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Copy color", @"Button to copy the current color to clipboard")
                                                  action:@selector(copyColorMenuItemAction:)
                                           keyEquivalent:@""];
    colorCopyMenuItem.allowsKeyEquivalentWhenHidden = YES;
    colorCopyMenuItem.hidden = YES;
    [pickerMenu addItem:colorCopyMenuItem];
    
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
    
    pinToScreenItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Pin on screen...", @"Button to pin the window on screen")
                                                 action:@selector(pickerWindowItemAction:)
                                          keyEquivalent:@""];
    [pickerMenu addItem:pinToScreenItem];
    
    [pickerMenu addItem:[NSMenuItem separatorItem]];
    pickerPreferencesItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Preferences...", @"Button to show app preferences")
                                                       action:@selector(preferencesMenuItemAction:)
                                                keyEquivalent:@","];
    pickerPreferencesItem.keyEquivalentModifierMask = NSEventModifierFlagCommand;
    [pickerMenu addItem:pickerPreferencesItem];
    
    [pickerMenu addItem:[NSMenuItem separatorItem]];
    quitMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Quit", @"Button to quit the application")
                                              action:@selector(quitMenuItemAction:)
                                       keyEquivalent:@"q"];
    [pickerMenu addItem:quitMenuItem];
    
    [[PIColorPicker defaultPicker] startTracking];
    
    [[PIPreferences shadredPreferences] bg_addTarget:self
                                              action:@selector(bindPreferencesColorCopySortcutChanged:)
                                    forKeyPathChange:BGKeyPath(PIPreferences, colorCopyShortcut)
                                     callImmediately:YES];
    [[PIPreferences shadredPreferences] bg_addTarget:self
                                              action:@selector(bindPreferencesPinToScreenSortcutChanged:)
                                    forKeyPathChange:BGKeyPath(PIPreferences, pinToScreenShortcut)
                                     callImmediately:YES];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    
}



#pragma mark ---
#pragma mark Bindings
#pragma mark ---
- (void)bindPreferencesColorCopySortcutChanged:(NSDictionary *)change
{
    MASShortcut *oldColorCopyShortcut = [change objectForKey:kBGDataBindingChangeOldKey];
    [[MASShortcutMonitor sharedMonitor] unregisterShortcut:oldColorCopyShortcut];
    [self registerColorCopyShortcut];
}

- (void)bindPreferencesPinToScreenSortcutChanged:(NSDictionary *)change
{
    MASShortcut *oldPinToScreenShortcut = [change objectForKey:kBGDataBindingChangeOldKey];
    [[MASShortcutMonitor sharedMonitor] unregisterShortcut:oldPinToScreenShortcut];
    [self registerPinToScreenShortcut];
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

- (void)preferencesMenuItemAction:(id)sender
{
    [self showPreferencesWindow];
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
    [self registerColorCopyShortcut];
    [self registerPinToScreenShortcut];
}

- (void)unregisterGlobalHotkeys
{
    MASShortcut *copyColorShortcut = [[PIPreferences shadredPreferences] colorCopyShortcut];
    [[MASShortcutMonitor sharedMonitor] unregisterShortcut:copyColorShortcut];
    
    MASShortcut *pinToScreenShortcut = [[PIPreferences shadredPreferences] pinToScreenShortcut];
    [[MASShortcutMonitor sharedMonitor] unregisterShortcut:pinToScreenShortcut];
}

- (void)registerColorCopyShortcut
{
    MASShortcut *copyColorShortcut = [[PIPreferences shadredPreferences] colorCopyShortcut];
    
    colorCopyMenuItem.keyEquivalent = copyColorShortcut.keyCodeString;
    colorCopyMenuItem.keyEquivalentModifierMask = copyColorShortcut.modifierFlags;
    
    [[MASShortcutMonitor sharedMonitor] registerShortcut:copyColorShortcut withAction:^{
        
        NSLog(@"Copy global");
        [[PIColorPicker defaultPicker] copyColorToPasteboard];
        
        [self->statusItem.button setHighlighted:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self->statusItem.button setHighlighted:NO];
        });
    }];
}

- (void)registerPinToScreenShortcut
{
    MASShortcut *pinToScreenShortcut = [[PIPreferences shadredPreferences] pinToScreenShortcut];

    pinToScreenItem.keyEquivalent = pinToScreenShortcut.keyCodeString;
    pinToScreenItem.keyEquivalentModifierMask = pinToScreenShortcut.modifierFlags;
    
    [[MASShortcutMonitor sharedMonitor] registerShortcut:pinToScreenShortcut withAction:^{
        
        [self showPickerWindow];
    }];
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

- (void)showPreferencesWindow
{
    if (preferencesWindowController == nil)
    {
        preferencesWindowController = [PIPreferencesWindowController preferencesWindowController];
    }
    
    [preferencesWindowController showWindow:nil];
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
