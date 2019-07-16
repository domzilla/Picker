//
//  PIPickerWindowController.h
//  Picker
//
//  Created by Dominic Rodemer on 13.07.19.
//

#import <Cocoa/Cocoa.h>

#import "PIPickerViewController.h"

@interface PIPickerWindowController : NSWindowController
{
    PIPickerViewController *pickerViewController;
}

@property (nonatomic, strong) IBOutlet NSView *view;

- (id)init;

@end
