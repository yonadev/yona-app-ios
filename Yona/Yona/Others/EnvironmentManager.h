//
//  EnvironmentManager.h
//  Yona
//
//  Created by Ahmed Ali on 06/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface EnvironmentManager : NSObject
+ (NSString *)baseUrlString;
+ (BOOL)updateEnvironment;
@end
