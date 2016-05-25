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

static DeploymentEnvironment environment;

@implementation EnvironmentManager


+ (NSString *)baseUrlString
{
    
    switch (environment) {
        case DeploymentEnvironmentDev:
            baseUrl = @"http://85.222.227.142/";
            break;
        default:
            baseUrl = @"http://85.222.227.84/";
            break;
    }
    return baseUrl;
    
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
    
    if(env.integerValue != environment){
        changed = YES;
        environment = env.integerValue;
    }
    return changed;
}
@end
