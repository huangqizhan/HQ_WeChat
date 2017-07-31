//
//  UIViewController+HQPresentTranstion.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/4/12.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (HQPresentTranstion)<UIViewControllerTransitioningDelegate>


- (void)setTranstionDelegate;

- (void)removeTranstionDelegate;

@end

