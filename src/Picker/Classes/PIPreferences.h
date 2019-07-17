//
//  PIPreferences.h
//  Picker
//
//  Created by Dominic Rodemer on 17.07.19.
//

#import <Foundation/Foundation.h>

@class MASShortcut;

@interface PIPreferences : NSObject
{
    MASShortcut *colorCopyShortcut;
    MASShortcut *pinToScreenShortcut;
}

@property (nonatomic, strong) MASShortcut *colorCopyShortcut;
@property (nonatomic, strong) MASShortcut *pinToScreenShortcut;

+ (instancetype)shadredPreferences;

+ (NSDictionary *)defaults;

@end
