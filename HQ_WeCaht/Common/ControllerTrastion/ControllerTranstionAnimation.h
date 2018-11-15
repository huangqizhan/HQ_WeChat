//
//  ControllerTranstionAnimation.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/4/10.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol ControllerTranstionAnimationDetaSourse <NSObject>


- (UIButton *)pushTransitionImageView;
- (UIButton *)popTransitionImageView;

@end


@interface ControllerTranstionAnimation : NSObject <UIViewControllerAnimatedTransitioning>

////是否是push 转场
@property (nonatomic, assign) BOOL isForward;
////动画时间
@property (nonatomic, assign) NSTimeInterval animationDuration;
///
@property (nonatomic, assign) CGFloat toViewControllerImagePointY;

///// 将要显示图片时的  做动画前的 rect
@property (nonatomic,assign) CGRect origineRect;



@end
