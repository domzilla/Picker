//
//  PIShortcutsPreferencesViewController.h
//  Picker
//
//  Created by Dominic Rodemer on 16.07.19.
//

#import <MASPreferences/MASPreferences.h>

@class MASShortcutView;

@interface PIShortcutsPreferencesViewController : NSViewController <MASPreferencesViewController>
{
    
}

@property (nonatomic, strong) IBOutlet MASShortcutView *colorCopyShortcutView;
@property (nonatomic, strong) IBOutlet MASShortcutView *pinToScreenShortcutView;

@end
