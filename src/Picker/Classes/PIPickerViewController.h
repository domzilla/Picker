//
//  PIPickerViewController.h
//  Picker
//
//  Created by Dominic Rodemer on 13.07.19.
//

#import <Cocoa/Cocoa.h>

@class PIPickerPreviewView;
@class PIColorView;

typedef NS_ENUM(NSUInteger, PIPickerViewControllerMode) {
    PIPickerViewControllerModeDefault,
    PIPickerViewControllerModeMenu
};

@interface PIPickerViewController : NSViewController
{
    PIPickerViewControllerMode mode;
    
    NSTimer *timer;
    
    BOOL updateColorsHistory;
    BOOL shouldUpdateView;
}

@property (nonatomic, readonly) PIPickerViewControllerMode mode;

@property (nonatomic) BOOL shouldUpdateView;

@property (nonatomic, strong) IBOutlet PIPickerPreviewView *pickerPreviewView;
@property (nonatomic, strong) IBOutlet PIColorView *colorPreview;
@property (nonatomic, strong) IBOutlet NSTextField *rgbText;
@property (nonatomic, strong) IBOutlet NSTextField *hexText;
@property (nonatomic, strong) IBOutlet NSTextField *hueText;
@property (nonatomic, strong) IBOutlet NSTextField *saturationText;
@property (nonatomic, strong) IBOutlet NSTextField *brightnessText;
@property (nonatomic, strong) IBOutlet NSTextField *x;
@property (nonatomic, strong) IBOutlet NSTextField *y;

@property (nonatomic, strong) IBOutlet PIColorView *colorHistoryView1;
@property (nonatomic, strong) IBOutlet PIColorView *colorHistoryView2;
@property (nonatomic, strong) IBOutlet PIColorView *colorHistoryView3;
@property (nonatomic, strong) IBOutlet PIColorView *colorHistoryView4;
@property (nonatomic, strong) IBOutlet PIColorView *colorHistoryView5;
@property (nonatomic, strong) IBOutlet PIColorView *colorHistoryView6;

@property (nonatomic, strong) IBOutlet NSTextField *shortcutLabel;
@property (nonatomic, strong) IBOutlet NSPopUpButton *formatButton;

@property (nonatomic, strong) IBOutlet NSButton *pinButton;

- (id)initWithMode:(PIPickerViewControllerMode)aMode;

@end
