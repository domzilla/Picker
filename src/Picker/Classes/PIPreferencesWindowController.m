//
//  PIPreferencesWindowController.m
//  Picker
//
//  Created by Dominic Rodemer on 16.07.19.
//

#import "PIPreferencesWindowController.h"

#import "PIGeneralPreferencesViewController.h"
#import "PIShortcutsPreferencesViewController.h"

@interface PIPreferencesWindowController ()

@end

@implementation PIPreferencesWindowController

+ (instancetype)preferencesWindowController
{
    /*
    NSArray *preferenceViewController = @[[[PIGeneralPreferencesViewController alloc] init],
                                          [[PIShortcutsPreferencesViewController alloc] init]];
    */
    NSArray *preferenceViewController = @[[[PIShortcutsPreferencesViewController alloc] init]];
    
    PIPreferencesWindowController *controller = [[PIPreferencesWindowController alloc] initWithViewControllers:preferenceViewController];
    
    return controller;
}

@end
