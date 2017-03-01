//
//  CustomPresentTransition.m
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/15.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import "CustomPresentTransition.h"

@implementation CustomPresentTransition

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = toVC.view;
    
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:toView];
    
    CGRect targetFrame = [transitionContext finalFrameForViewController:toVC];
    toView.frame = CGRectOffset(targetFrame, targetFrame.size.width, 0);
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration animations:^{
        toView.frame = targetFrame;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}


@end
