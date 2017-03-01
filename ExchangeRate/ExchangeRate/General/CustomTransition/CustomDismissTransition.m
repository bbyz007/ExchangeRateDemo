//
//  CustomDismissTransition.m
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/15.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import "CustomDismissTransition.h"

@implementation CustomDismissTransition

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *fromView = fromVC.view;
    CGPoint initCenter = fromView.center;
    CGPoint toCenter = CGPointMake(initCenter.x + fromView.frame.size.width, initCenter.y);
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration animations:^{
        fromView.center = toCenter;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

@end
