//
//  PIShortcutsPreferencesViewController.m
//  Picker
//
//  Created by Dominic Rodemer on 16.07.19.
//

#import "PIShortcutsPreferencesViewController.h"

#import <MASShortcut/Shortcut.h>

#import "PIPreferences.h"

@interface PIShortcutsPreferencesViewController ()

@end

@implementation PIShortcutsPreferencesViewController

- (id)init
{
    if (self = [super initWithNibName:@"PIShortcutsPreferencesViewController" bundle:nil])
    {
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.colorCopyShortcutView.shortcutValue = [[PIPreferences shadredPreferences] colorCopyShortcut];
    self.colorCopyShortcutView.shortcutValueChange = ^void(MASShortcutView *shortcutView) {
        [[PIPreferences shadredPreferences] setColorCopyShortcut:shortcutView.shortcutValue];
    };
    
    self.pinToScreenShortcutView.shortcutValue = [[PIPreferences shadredPreferences] pinToScreenShortcut];
    self.pinToScreenShortcutView.shortcutValueChange = ^void(MASShortcutView *shortcutView) {
        [[PIPreferences shadredPreferences] setPinToScreenShortcut:shortcutView.shortcutValue];
    };
}



#pragma mark ---
#pragma mark MASPreferencesViewController
#pragma mark ---
- (NSString *)viewIdentifier
{
    return @"PIShortcutsPreferencesViewController";
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"Shortcuts", @"Title for shortcut preferences");
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:@"preferences_shortcuts"];
}

@end
