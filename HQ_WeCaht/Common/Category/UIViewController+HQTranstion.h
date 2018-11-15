//
//  UIViewController+HQTranstion.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/4/10.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (HQTranstion)<UINavigationControllerDelegate>

@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactivePopTransition;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSNumber *toViewControllerImagePointY;
@property (nonatomic, strong) NSNumber *cancelAnimationPointY;
@property (nonatomic, strong) NSNumber *animationDuration;
@property (nonatomic, assign) CGRect orgineViewRect;


- (void)hq_pushTransitionAnimationWithToViewControllerImagePointY:(CGFloat)toViewControllerImagePointY
                                                 animationDuration:(CGFloat)animationDuration;

- (void)hq_popTransitionAnimationWithCurrentScrollView:(UIScrollView*)scrollView
                                      animationDuration:(CGFloat)animationDuration
                                isInteractiveTransition:(BOOL)isInteractiveTransition;

- (void)hq_popTransitionAnimationWithCurrentScrollView:(UIScrollView*)scrollView
                                 cancelAnimationCgrect:(CGRect)cancelAnimationCgrect
                                     animationDuration:(CGFloat)animationDuration
                               isInteractiveTransition:(BOOL)isInteractiveTransition;

- (void)hq_addTransitionDelegate:(UIViewController*)viewController;
- (void)hq_removeTransitionDelegate;

- (void)hq_setUpReturnBtnWithColor:(UIColor *)color callBackHandler:(void (^)())callBackHandler;
- (void)hq_setupReturnBtnWithImage:(UIImage *)image color:(UIColor *)color callBackHandler:(void (^)())callBackHandler;

- (void)returnAction:(id)sender;


@end
