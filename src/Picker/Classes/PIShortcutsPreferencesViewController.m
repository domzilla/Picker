//
//  PIShortcutsPreferencesViewController.m
//  Picker
//
//  Created by Dominic Rodemer on 16.07.19.
//

#import "PIShortcutsPreferencesViewController.h"

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
