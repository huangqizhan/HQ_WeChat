//
//  UINavigationController+FullScreenGesture.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2018/1/16.
//  Copyright © 2018年 黄麒展  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (FullScreenGesture)
/**自定义返回手势*/
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *fullscreenPopGestureRecognizer;
/**显示控制器时 是否可以设置导航栏 */
@property (nonatomic, assign) BOOL viewControllerBasedNavigationBarAppearanceEnabled;



@end



@interface  UIViewController (FDFullscreenPopGesture)



/**  是否禁止使用手势返回     */
@property (nonatomic, assign) BOOL interactivePopDisabled;

/** 是否隐藏导航栏          */
@property (nonatomic, assign) BOOL prefersNavigationBarHidden;

/** 右滑返回手势的距左边的距离   */
@property (nonatomic, assign) CGFloat interactivePopMaxAllowedInitialDistanceToLeftEdge;

@end

