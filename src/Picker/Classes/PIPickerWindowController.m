//
//  PIPickerWindowController.m
//  Picker
//
//  Created by Dominic Rodemer on 13.07.19.
//

#import "PIPickerWindowController.h"

@interface PIPickerWindowController ()

@end

@implementation PIPickerWindowController

- (id)init
{
    if (self = [super initWithWindow:[NSWindow windowWithContentViewController:[[PIPickerViewController alloc] initWithMode:PIPickerViewControllerModeDefault]]])
    {
        pickerViewController = (PIPickerViewController *)self.contentViewController;
        pickerViewController.shouldUpdateView = YES;
        
        self.window.styleMask = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable;
        [[self.window standardWindowButton:NSWindowZoomButton] setHidden:YES];
        [[self.window standardWindowButton:NSWindowMiniaturizeButton] setHidden:YES];
        self.window.title = NSLocalizedString(@"Picker", @"");
        self.window.titleVisibility = NSWindowTitleHidden;
        self.window.collectionBehavior = NSWindowCollectionBehaviorFullScreenNone;
        //self.window.titlebarAppearsTransparent = YES;
        self.window.canHide = NO;
        self.window.excludedFromWindowsMenu = YES;
        self.window.level = NSFloatingWindowLevel;
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    
}

@end
