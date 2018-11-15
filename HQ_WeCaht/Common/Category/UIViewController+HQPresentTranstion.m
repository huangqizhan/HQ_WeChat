//
//  UIViewController+HQPresentTranstion.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/4/12.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "UIViewController+HQPresentTranstion.h"


@implementation UIViewController (HQPresentTranstion)

- (void)setTranstionDelegate{
    self.transitioningDelegate = self;
}
- (void)removeTranstionDelegate{
    self.transitioningDelegate = nil;
}
//- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
//    HQCustomerTranstionAnimation* animator = [[HQCustomerTranstionAnimation alloc] initWithPresenting:YES];
//    return animator;
//}
//- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
//    HQCustomerTranstionAnimation* animator = [[HQCustomerTranstionAnimation alloc] initWithPresenting:NO];
//    return animator;
//}

@end

