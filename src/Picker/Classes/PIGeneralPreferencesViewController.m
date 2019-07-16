//
//  PIGeneralPreferencesViewController.m
//  Picker
//
//  Created by Dominic Rodemer on 16.07.19.
//

#import "PIGeneralPreferencesViewController.h"

@interface PIGeneralPreferencesViewController ()

@end

@implementation PIGeneralPreferencesViewController

- (id)init
{
    if (self = [super initWithNibName:@"PIGeneralPreferencesViewController" bundle:nil])
    {
        
    }
    
    return self;
}



#pragma mark ---
#pragma mark MASPreferencesViewController
#pragma mark ---
- (NSString *)viewIdentifier
{
    return @"PIGeneralPreferencesViewController";
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"General", @"Title for general preferences");
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

@end
