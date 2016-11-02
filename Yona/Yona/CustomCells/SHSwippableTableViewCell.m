//
//  SHSwippableTableViewCell.m
//  GRPPY
//
//  Created by Ahmed Ali on 22/06/16.
//  Copyright © 2016 MyOrder. All rights reserved.
//

#import "SHSwippableTableViewCell.h"
@interface SHSwippableTableViewCell()

@property (weak, nonatomic) IBOutlet UIView * swipableContent;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *swipableContentHorizontalConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint * actionViewWidthConstraint;
@property (nonatomic) UIPanGestureRecognizer * panRecognizer;
@property (nonatomic) CGPoint panStartPoint;
@property (nonatomic) BOOL initialConstant;

@end
@implementation SHSwippableTableViewCell

- (void)animateSwippingAction
{
    self.swipableContentHorizontalConstraint.constant = -self.actionViewWidthConstraint.constant;
    [UIView animateWithDuration:0.6 animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.swipableContentHorizontalConstraint.constant = -5;
        [UIView animateWithDuration:0.3 animations:^{
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.swipableContentHorizontalConstraint.constant = -self.actionViewWidthConstraint.constant;
            [UIView animateWithDuration:0.7 animations:^{
                [self layoutIfNeeded];
            } completion:^(BOOL finished) {
                self.swipableContentHorizontalConstraint.constant = 0;
                [UIView animateWithDuration:0.3 animations:^{
                    [self layoutIfNeeded];
                } completion:^(BOOL finished) {
                    
                }];
            }];
        }];
    }];
    
    
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.isOpen = NO;
    
    self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanning:)];
    self.panRecognizer.cancelsTouchesInView = NO;
    self.panRecognizer.delegate = self;
    [self.swipableContent addGestureRecognizer:self.panRecognizer];
    
}


- (void)handlePanning:(UIPanGestureRecognizer *)recognizer
{
    if(!self.allowsSwipeAction){
        return;
    }
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:{
            self.panStartPoint = [recognizer translationInView:self.swipableContent];
            self.initialConstant = self.swipableContentHorizontalConstraint.constant;
            break;
        }
            
            
        case UIGestureRecognizerStateChanged: {
            CGPoint currentPoint = [recognizer translationInView:self.swipableContent];
            CGFloat deltaX = currentPoint.x - self.panStartPoint.x;
            BOOL panningLeft = NO;
            if (deltaX < 0) {
                panningLeft = YES;
            }
            if(self.initialConstant == 0){
                self.swipableContentHorizontalConstraint.constant = MIN(deltaX, 0);
            }else{
                deltaX -= self.actionViewWidthConstraint.constant;
                self.swipableContentHorizontalConstraint.constant = MIN(deltaX, 0);
            }
            
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:{
            if(fabs(self.swipableContentHorizontalConstraint.constant) >= (0.5 * self.actionViewWidthConstraint.constant)){
                [self openCell];
            }else{
                [self closeCell];
            }
        }
        default:
            break;
    }
}

-(void) resest
{
    self.swipableContentHorizontalConstraint.constant = 0;
    self.isOpen = NO;
    [self layoutIfNeeded];
}


- (void)closeCell
{
    _isOpen = NO;
    //Nothing to do...
    if (self.swipableContentHorizontalConstraint.constant ==  0) {
        return;
    }
    
    self.swipableContentHorizontalConstraint.constant = 0;
    
    [self updateConstraintsIfNeeded:YES];
}

- (void)openCell
{
    _isOpen = YES;
    //Nothing to do...
    if (self.swipableContentHorizontalConstraint.constant ==  -self.actionViewWidthConstraint.constant) {
        return;
    }
    
    self.swipableContentHorizontalConstraint.constant = -(self.actionViewWidthConstraint.constant);
    
    [self updateConstraintsIfNeeded:YES];
}


- (void)updateConstraintsIfNeeded:(BOOL)animated{
    float duration = 0;
    if (animated) {
        duration = 0.2;
    }
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self layoutIfNeeded];
    } completion:nil];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
