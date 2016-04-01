//
//  CucumberishExampleUITests-Swift.m
//  Yona
//
//  Created by Alessio Roberto on 31/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YonaUITests-Swift.h"
__attribute__((constructor))
void CucumberishInit()
{
    [CucumberishInitializer CucumberishSwiftInit];
}
