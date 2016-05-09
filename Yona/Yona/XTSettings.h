//
//  XTSettings
//
//  Created by Taras Kalapun
//  Copyright (c) 2012 Xaton. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface XTSettings : NSObject

+ (void)presetVersionAndDefaults;
+ (void)presetVersionAndDefaultsOnKey:(NSString *)key;

+ (void)setSettingsBundleDefaults;
+ (void)setSettingsBundleDefaultsForFile:(NSString *)plistFileName;

+ (void)synchronize;

+ (id)settingsForKey:(NSString *)key;

#pragma mark - Random helpers
+ (void)listFonts;

@end