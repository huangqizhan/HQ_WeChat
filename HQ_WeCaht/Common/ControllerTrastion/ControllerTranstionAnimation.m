//
//  ControllerTranstionAnimation.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/4/10.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "ControllerTranstionAnimation.h"
#import "UIViewController+HQTranstion.h"

@implementation ControllerTranstionAnimation

- (id)init{
    self = [super init];
    if (self) {
    }
    return self;
}
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return self.animationDuration;
}
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    // 获得 fromViewController
    UIViewController<ControllerTranstionAnimationDetaSourse> *fromViewController =
    (UIViewController<ControllerTranstionAnimationDetaSourse> *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    // 获得 toViewController
    UIViewController<ControllerTranstionAnimationDetaSourse> *toViewController =
    (UIViewController<ControllerTranstionAnimationDetaSourse> *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    containerView.backgroundColor = [UIColor clearColor];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    // 设置  fromViewController
    UIButton *fromTransitionBut = _isForward ? [fromViewController pushTransitionImageView] : [fromViewController popTransitionImageView];
    UIButton *newTranstionBut = [[UIButton alloc]init];
    [newTranstionBut setBackgroundImage:fromTransitionBut.currentBackgroundImage forState:UIControlStateNormal];
    newTranstionBut.layer.cornerRadius = fromTransitionBut.layer.cornerRadius;
    CGRect ignRect = [fromTransitionBut.superview convertRect:fromTransitionBut.frame toView:containerView];
    newTranstionBut.frame = ignRect;
    newTranstionBut.hidden = NO;
    // 设置 toViewController
    UIButton *toTransitionBut = _isForward ? [toViewController popTransitionImageView] : [toViewController pushTransitionImageView];
    toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
    [toViewController.view addSubview:newTranstionBut];
    if (_isForward) {
        // push Animation
        toViewController.view.alpha = 0.0;
        [containerView addSubview:toViewController.view];
        toTransitionBut.hidden = YES;
        [toTransitionBut setBackgroundImage:fromTransitionBut.currentBackgroundImage forState:UIControlStateNormal];
        toViewController.view.backgroundColor = [UIColor blackColor];
        toViewController.scrollView.hidden = YES;
        [UIView animateWithDuration:0 animations:^{
            toViewController.view.alpha = 1.0;
            toTransitionBut.hidden = YES;
            [containerView addSubview:toViewController.view];
            [toTransitionBut setBackgroundImage:fromTransitionBut.currentBackgroundImage forState:UIControlStateNormal];
        } completion:^(BOOL finished) {
            toTransitionBut.hidden = YES;
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
            [UIView animateWithDuration:duration animations:^{
                CGRect frame = [containerView convertRect:toTransitionBut.frame fromView:toViewController.view];
                newTranstionBut.frame = frame;
//                newTranstionBut.transform = CGAffineTransformMakeScale(1.05, 1.05);
            } completion:^(BOOL finished) {
//                newTranstionBut.transform = CGAffineTransformMakeScale(1.0, 1.0);
                [newTranstionBut removeFromSuperview];
                fromTransitionBut.hidden = NO;
                toTransitionBut.hidden = NO;
                toViewController.scrollView.hidden = NO;
                [newTranstionBut removeFromSuperview];
//                // transition end
                [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
            }];
        }];
    } else {
        // pop Animation
        toTransitionBut.hidden = YES;
        [containerView insertSubview:toViewController.view belowSubview:fromViewController.view];
        [containerView addSubview:newTranstionBut];
        [UIView animateWithDuration:0 animations:^{
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:duration animations:^{
                fromViewController.view.alpha = 0.0;
                if (toTransitionBut) {
                    CGRect rect = [containerView convertRect:toTransitionBut.frame fromView:toTransitionBut.superview];
                    newTranstionBut.frame = rect;
                }else{
                    newTranstionBut.alpha = 0;
                }
            } completion:^(BOOL finished) {
                [newTranstionBut removeFromSuperview];
                fromTransitionBut.hidden = NO;
                toTransitionBut.hidden = NO;
                [newTranstionBut removeFromSuperview];
                // transition end
                [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
            }];
        }];
    }
}
@end
