//
//  XTSettings
//
//  Created by Taras Kalapun
//  Copyright (c) 2012 Xaton. All rights reserved.
//

#import "XTSettings.h"

@implementation XTSettings

#pragma mark - Settings.bundle

+ (void)presetVersionAndDefaults {
    [[self class] presetVersionAndDefaultsOnKey:nil];
}

+ (void)presetVersionAndDefaultsOnKey:(NSString *)key
{
    if (key == nil) {
        key = @"AppVersionKey";
    }
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *versionInUD = [[NSUserDefaults standardUserDefaults] stringForKey:key];
    
    // Check some var from Settings.bundle
    if (!versionInUD || ![version isEqualToString:versionInUD]) {
        [[self class] setSettingsBundleDefaults];
        [[NSUserDefaults standardUserDefaults] setObject:version forKey:key];
    }
}

+ (void)setSettingsBundleDefaults
{
    [[self class] setSettingsBundleDefaultsForFile:@"Root.plist"];
}

+ (void)setSettingsBundleDefaultsForFile:(NSString *)plistFileName
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    //bundle path
    NSString *bPath = [[NSBundle mainBundle] bundlePath];
    NSString *settingsPath = [bPath stringByAppendingPathComponent:@"Settings.bundle"];
    NSString *plistFile = [settingsPath stringByAppendingPathComponent:plistFileName];
    
    //preferences
    NSDictionary *settingsDictionary = [NSDictionary dictionaryWithContentsOfFile:plistFile];
    NSArray *preferencesArray = [settingsDictionary objectForKey:@"PreferenceSpecifiers"];
    
    //loop thru prefs
    NSDictionary *item;
    for(item in preferencesArray)
    {
        //get the key
        NSString *keyValue = [item objectForKey:@"Key"];
        
        //get the default
        id defaultValue = [item objectForKey:@"DefaultValue"];
        
        // if we have both, set in defaults
        if (keyValue && defaultValue)
            [standardUserDefaults setObject:defaultValue forKey:keyValue];
        
        //get the file item if any - (recurse thru the other settings files)
        NSString *fileValue = [item objectForKey:@"File"];
        if (fileValue)
            [[self class] setSettingsBundleDefaultsForFile:[fileValue stringByAppendingString:@".plist"]];
        
    }
    [standardUserDefaults synchronize];
}

#pragma mark - Helpers

+ (void)synchronize
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)settingsForKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

#pragma mark - Random helpers

+ (void)listFonts {
    NSArray *fonts = [UIFont familyNames];
    for (NSString *fName in fonts) {
        NSLog(@"---> %@ :", fName);
        NSLog(@"\n%@", [UIFont fontNamesForFamilyName:fName]);
    }
}

@end