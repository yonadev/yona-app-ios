//
//  UITabBarItem+AGi18n.m
//  AGi18n
//
//  Created by Tenyoku Lin on 8/4/15.
//

#import "UITabBarItem+AGi18n.h"

@implementation UITabBarItem (AGi18n)

- (void)localizeFromNib {
    //Replace text with localizable version
    if (self.title.length > 0) {
        self.title = [[NSBundle mainBundle] localizedStringForKey:self.title value:@"" table:nil];
    }
}

@end
