//
//  ControllerPresentTranstionAnimation.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/4/12.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ControllerPresentTranstionAnimationDelegate <NSObject>

- (UIButton *)presentTranstionButton;
- (UIButton *)dismissTranstionButton;

@end



@interface ControllerPresentTranstionAnimation : NSObject<UIViewControllerAnimatedTransitioning>

////是否是push 转场
@property (nonatomic, assign) BOOL isForward;


@end
