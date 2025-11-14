//
//  PIPickerViewController.m
//  Picker
//
//  Created by Dominic Rodemer on 13.07.19.
//

#import "PIPickerViewController.h"

#import <BGFoundation/BGFoundation.h>
#import <MASShortcut/MASShortcut.h>

#import "PIPickerPreviewView.h"
#import "PIColorView.h"
#import "PIColorButton.h"

#import "PIPreferences.h"
#import "PIColorPicker.h"
#import "PIColorHistory.h"
#import "NSColor+Picker.h"

@interface PIPickerViewController ()

- (void)updateView;
- (void)updateHistory;

@end

@implementation PIPickerViewController

static void *PIPickerViewControllerKVOContext = &PIPickerViewControllerKVOContext;

@synthesize mode;

- (id)initWithMode:(PIPickerViewControllerMode)aMode
{
    if (self = [super initWithNibName:@"PIPickerViewController" bundle:[NSBundle mainBundle]])
    {
        mode = aMode;
        
        updateColorsHistory = YES;
        shouldUpdateView = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(colorHistoryDidUpdateHistoryNotification:)
                                                     name:PIColorHistoryDidUpdateHistoryNotification
                                                   object:nil];
        
        [[PIPreferences shadredPreferences] addObserver:self
                                             forKeyPath:BGKeyPath(PIPreferences, colorCopyShortcut)
                                                options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                                context:PIPickerViewControllerKVOContext];
    }
    
    return self;
}

- (void)dealloc
{
    [timer invalidate];
    timer = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[PIPreferences shadredPreferences] removeObserver:self
                                            forKeyPath:BGKeyPath(PIPreferences, colorCopyShortcut)
                                               context:PIPickerViewControllerKVOContext];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (mode == PIPickerViewControllerModeMenu)
    {
        self.formatButton.hidden = YES;
    }
    else
    {
        self.formatButton.hidden = NO;
        
        for (PIColorPickerFormat format = 0; format < PIColorPickerFormatsCount; format++)
        {
            [self.formatButton addItemWithTitle:PIColorPickerFormatToString(format)];
        }
        
        [self.formatButton selectItemAtIndex:[[PIColorPicker defaultPicker] pickerFormat]];
    }
        
    [self updateColorCopyShortcut];
    [self updateHistory];
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
- (IBAction)colorHistoryButtonAction:(id)sender
{
    PIColorButton *colorHistoryButton = (PIColorButton *)sender;
    
    [[PIColorPicker defaultPicker] copyColorToPasteboard:colorHistoryButton.color saveToHistory:NO];
}

- (IBAction)formatButtonAction:(id)sender
{
    PIColorPickerFormat pickerFormat = (PIColorPickerFormat)[self.formatButton indexOfSelectedItem];
    [[PIColorPicker defaultPicker] setPickerFormat:pickerFormat];
}



#pragma mark ---
#pragma mark Private
#pragma mark ---
- (void)updateColorCopyShortcut
{
    MASShortcut *colorCopyShortcut = [[PIPreferences shadredPreferences] colorCopyShortcut];
    NSString *shortcutString = [NSString stringWithFormat:@"%@%@", colorCopyShortcut.modifierFlagsString, colorCopyShortcut.keyCodeString];
    self.shortcutLabel.stringValue = [NSString stringWithFormat:NSLocalizedString(@"Press %@ to copy color", @"Place holder is a key-combination which copies the current color to clipboard"), shortcutString];
}
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

- (void)updateHistory
{
    self.colorHistoryButton1.color = [[PIColorHistory defaultHistory] colorAtIndex:0];
    self.colorHistoryButton2.color = [[PIColorHistory defaultHistory] colorAtIndex:1];
    self.colorHistoryButton3.color = [[PIColorHistory defaultHistory] colorAtIndex:2];
    self.colorHistoryButton4.color = [[PIColorHistory defaultHistory] colorAtIndex:3];
    self.colorHistoryButton5.color = [[PIColorHistory defaultHistory] colorAtIndex:4];
    self.colorHistoryButton6.color = [[PIColorHistory defaultHistory] colorAtIndex:5];
}



#pragma mark ---
#pragma mark PIColorPicker Notifications
#pragma mark ---
- (void)colorPickerDidChangeColorNotification:(NSNotification *)notification
{
    [self updateView];
}



#pragma mark ---
#pragma mark PiColorHistory Notifictions
#pragma mark ---
- (void)colorHistoryDidUpdateHistoryNotification:(NSNotification *)notification
{
    [self updateHistory];
}


#pragma mark ---
#pragma mark KVO
#pragma mark ---
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (context != PIPickerViewControllerKVOContext)
    {
        @try {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        } @catch (NSException *exception) {
            BGExceptionLog(exception);
        }
        
        return;
    }
    
    if (object == [PIPreferences shadredPreferences])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([keyPath isEqualToString:BGKeyPath(PIPreferences, colorCopyShortcut)])
                [self updateColorCopyShortcut];
        });
    }
}

@end
