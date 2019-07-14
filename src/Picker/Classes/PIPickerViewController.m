//
//  PIPickerViewController.m
//  Picker
//
//  Created by Dominic Rodemer on 13.07.19.
//

#import "PIPickerViewController.h"

#import "PIPickerPreviewView.h"
#import "PIColorView.h"

#import "PIColorPicker.h"
#import "NSColor+Picker.h"

@interface PIPickerViewController ()

- (void)updateView;

@end

@implementation PIPickerViewController

@synthesize delegate;
@synthesize mode;

- (id)initWithMode:(PIPickerViewControllerMode)aMode
{
    if (self = [super initWithNibName:@"PIPickerViewController" bundle:[NSBundle mainBundle]])
    {
        mode = aMode;
        
        updateColorsHistory = YES;
        shouldUpdateView = NO;
    }
    
    return self;
}

- (void)dealloc
{
    [timer invalidate];
    timer = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (mode == PIPickerViewControllerModeMenu)
    {
        self.formatButton.hidden = YES;
        self.pinButton.hidden = NO;
    }
    else
    {
        self.formatButton.hidden = NO;
        self.pinButton.hidden = YES;
        
        for (PIColorPickerFormat format = 0; format < PIColorPickerFormatsCount; format++)
        {
            [self.formatButton addItemWithTitle:PIColorPickerFormatToString(format)];
        }
        
        [self.formatButton selectItemAtIndex:[[PIColorPicker defaultPicker] pickerFormat]];
    }
}



#pragma mark ---
#pragma mark Accessors
#pragma mark ---
- (BOOL)shouldUpdateView
{
    return shouldUpdateView;
}

- (void)setShouldUpdateView:(BOOL)update
{
    if (shouldUpdateView != update)
    {
        shouldUpdateView = update;
        
        if (shouldUpdateView)
        {
            [self updateView];
            
            [timer invalidate];
            timer = [NSTimer timerWithTimeInterval:0.1 repeats:YES block:^(NSTimer *aTimer) {
                [self updateView];
            }];
            [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(colorPickerDidChangeColorNotification:)
                                                         name:PIColorPickerDidChangeColorNotification
                                                       object:nil];
        }
        else
        {
            [timer invalidate];
            timer = nil;
            
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:PIColorPickerDidChangeColorNotification
                                                          object:nil];
        }
    }
}



#pragma mark ---
#pragma mark Actions
#pragma mark ---
- (IBAction)pinButtonAction:(id)sender
{
    if ([delegate respondsToSelector:@selector(pickerViewControllerPinToWindow:)])
    {
        [delegate pickerViewControllerPinToWindow:self];
    }
}

- (IBAction)formatButtonAction:(id)sender
{
    PIColorPickerFormat pickerFormat = (PIColorPickerFormat)[self.formatButton indexOfSelectedItem];
    [[PIColorPicker defaultPicker] setPickerFormat:pickerFormat];
}



#pragma mark ---
#pragma mark Private
#pragma mark ---
- (void)updateView
{
    if (!shouldUpdateView)
        return;
        
    NSImage *previewImage = [[PIColorPicker defaultPicker] previewImage];
    NSColor *color = [[PIColorPicker defaultPicker] color];
    
    self.pickerPreviewView.previewImage = previewImage;
    self.colorPreview.color = color;
    
    self.hexText.stringValue = [color pi_hexRepresentation];
    self.rgbText.stringValue = [color pi_rgbRepresentation];
    
    self.hueText.stringValue = [color pi_hueRepresentation];
    self.saturationText.stringValue = [color pi_saturationRepresentation];
    self.brightnessText.stringValue = [color pi_brightnessRepresentation];
    
    self.x.stringValue = [NSString stringWithFormat:@"%.f", [PIColorPicker defaultPicker].mouseLocation.x];
    self.y.stringValue = [NSString stringWithFormat:@"%.f", [PIColorPicker defaultPicker].mouseLocation.y];
}



#pragma mark ---
#pragma mark PIColorPicker Notifications
#pragma mark ---
- (void)colorPickerDidChangeColorNotification:(NSNotification *)notification
{
    [self updateView];
}

@end
