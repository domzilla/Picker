//
//  PIPreferences.m
//  Picker
//
//  Created by Dominic Rodemer on 17.07.19.
//

#import "PIPreferences.h"

#import <MASShortcut/Shortcut.h>

NSString *const PIPreferencesDefaultsColorCopyShortcutKey = @"PIPreferencesDefaultsColorCopyShortcutKey";
NSString *const PIPreferencesDefaultsPinToScreenShortcutKey = @"PIPreferencesDefaultsPinToScreenShortcutKey";

@implementation PIPreferences

- (id)init
{
    if (self = [super init])
    {
        NSData *colorCopyShortcutData = [[NSUserDefaults standardUserDefaults] objectForKey:PIPreferencesDefaultsColorCopyShortcutKey];
        colorCopyShortcut = [NSKeyedUnarchiver unarchiveObjectWithData:colorCopyShortcutData];
        
        NSData *pinToScreenShortcutData = [[NSUserDefaults standardUserDefaults] objectForKey:PIPreferencesDefaultsPinToScreenShortcutKey];
        pinToScreenShortcut = [NSKeyedUnarchiver unarchiveObjectWithData:pinToScreenShortcutData];
    }
    
    return self;
}

+ (instancetype)shadredPreferences
{
    static PIPreferences *shadredPreferences = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shadredPreferences = [[PIPreferences alloc] init];
    });
    
    return shadredPreferences;
}



#pragma mark ---
#pragma mark Public
#pragma mark ---
+ (NSDictionary *)defaults
{
    MASShortcutValidator *shortcutValidator = [MASShortcutValidator sharedValidator];
    MASShortcut *defaultColorCopyShortcut = nil;
    MASShortcut *defaultPinToScreenShortcut = nil;
    NSInteger keycodes[5] = {(NSInteger)kVK_ANSI_P,
                             (NSInteger)kVK_ANSI_O,
                             (NSInteger)kVK_ANSI_X,
                             (NSInteger)kVK_ANSI_Period,
                             (NSInteger)kVK_ANSI_Comma};
    for (int i = 0; i < 5; i++)
    {
        NSInteger keycode = keycodes[i];
        defaultColorCopyShortcut = [MASShortcut shortcutWithKeyCode:keycode modifierFlags:NSEventModifierFlagCommand | NSEventModifierFlagShift];
        defaultPinToScreenShortcut = [MASShortcut shortcutWithKeyCode:keycode modifierFlags:NSEventModifierFlagCommand | NSEventModifierFlagShift | NSEventModifierFlagOption];
        
        if (![shortcutValidator isShortcutAlreadyTakenBySystem:defaultColorCopyShortcut explanation:nil]
            && ![shortcutValidator isShortcutAlreadyTakenBySystem:defaultPinToScreenShortcut explanation:nil]) {
            break;
        }
    }
    NSData *defaultColorCopyShortcutData = [NSKeyedArchiver archivedDataWithRootObject:defaultColorCopyShortcut];
    NSData *defaultPinToScreenShortcutData = [NSKeyedArchiver archivedDataWithRootObject:defaultPinToScreenShortcut];
    
    return @{PIPreferencesDefaultsColorCopyShortcutKey:defaultColorCopyShortcutData,
            PIPreferencesDefaultsPinToScreenShortcutKey:defaultPinToScreenShortcutData};
}



#pragma mark ---
#pragma mark Accessors
#pragma mark ---
- (MASShortcut *)colorCopyShortcut
{
    return colorCopyShortcut;
}

- (void)setColorCopyShortcut:(MASShortcut *)aColorCopyShortcut
{
    [self willChangeValueForKey:@"colorCopyShortcut"];
    colorCopyShortcut = aColorCopyShortcut;
    NSData *colorCopyShortcutData = [NSKeyedArchiver archivedDataWithRootObject:colorCopyShortcut];
    [[NSUserDefaults standardUserDefaults] setObject:colorCopyShortcutData forKey:PIPreferencesDefaultsColorCopyShortcutKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self didChangeValueForKey:@"colorCopyShortcut"];
}

- (MASShortcut *)pinToScreenShortcut
{
    return pinToScreenShortcut;
}

- (void)setPinToScreenShortcut:(MASShortcut *)aPinToScreenShortcut
{
    [self willChangeValueForKey:@"pinTpScreenShortcut"];
    pinToScreenShortcut = aPinToScreenShortcut;
    NSData *pinToScreenShortcutData = [NSKeyedArchiver archivedDataWithRootObject:pinToScreenShortcut];
    [[NSUserDefaults standardUserDefaults] setObject:pinToScreenShortcutData forKey:PIPreferencesDefaultsPinToScreenShortcutKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self didChangeValueForKey:@"pinTpScreenShortcut"];
}

@end
