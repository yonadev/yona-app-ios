//
//  EnvrinmentManager.m
//  Yona
//
//  Created by Ahmed Ali on 06/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

#import "EnvironmentManager.h"
#import "XTSettings.h"

typedef NS_ENUM(NSInteger, DeploymentEnvironment) {
    DeploymentEnvironmentProduction = 1,
    DeploymentEnvironmentDev,
    DeploymentEnvironmentQA
};

static NSString * baseUrl;

@implementation EnvironmentManager

// changed to set prod as standard
+ (NSString *)baseUrlString
{
    NSString *url = [[NSUserDefaults standardUserDefaults] stringForKey:@"YONA_URL"];
    if (url == nil || [url isEqual:@""]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:
                          @"SecretKeys" ofType:@"plist"];
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
        NSString *value = [dict valueForKey:@"Production URL"];
        url = value;
        [[NSUserDefaults standardUserDefaults] setObject:url forKey:@"YONA_URL"];
    }
    baseUrl = url;
    return baseUrl;
}

+ (NSNumber *)environment
{
    NSNumber * environment = [[NSUserDefaults standardUserDefaults] objectForKey:@"YonaEnvironment"];
    if(environment == nil){
        environment = @(DeploymentEnvironmentProduction);
        [self setEnvironment:environment];
    }
    return environment;
}

+ (void)setEnvironment:(NSNumber *)environment
{
    [[NSUserDefaults standardUserDefaults] setObject:environment forKey:@"YonaEnvironment"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)updateEnvironment
{
    NSNumber *env = [XTSettings settingsForKey:@"PrefsBundleMyOrderEnvironment"];
#ifndef DISTRIBUTE
    if (!env || [env integerValue] == 0) {
        env = @(DeploymentEnvironmentQA);
    }
    
#else
    env = @(DeploymentEnvironmentProduction);
#endif
    BOOL changed = NO;
    NSUInteger environment = [[self environment] integerValue];
    if(env.integerValue != environment){
        changed = YES;
        environment = env.integerValue;
        [self setEnvironment:env];
    }
    return changed;
}

+(void)updateEnvironmentWithURLString:(NSString*)environmentURLString{
    [[NSUserDefaults standardUserDefaults] setObject:environmentURLString forKey:@"YONA_URL"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

@end
