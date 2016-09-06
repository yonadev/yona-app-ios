//
//  SHSwippableTableViewCell.h
//  GRPPY
//
//  Created by Ahmed Ali on 22/06/16.
//  Copyright © 2016 MyOrder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SHSwippableTableViewCell : UITableViewCell

@property (nonatomic) BOOL allowsSwipeAction;

- (void)animateSwippingAction;
- (void)closeCell;
- (void)openCell;
@end
