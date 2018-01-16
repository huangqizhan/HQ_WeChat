//
//  UINavigationController+FullScreenGesture.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2018/1/16.
//  Copyright © 2018年 黄麒展. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (FullScreenGesture)

@property (nonatomic, strong, readonly) UIPanGestureRecognizer *fullscreenPopGestureRecognizer;

@property (nonatomic, assign) BOOL viewControllerBasedNavigationBarAppearanceEnabled;



@end



@interface  UIViewController (FDFullscreenPopGesture)



/// Whether the interactive pop gesture is disabled when contained in a navigation
/// stack.
@property (nonatomic, assign) BOOL interactivePopDisabled;

/// Indicate this view controller prefers its navigation bar hidden or not,
/// checked when view controller based navigation bar's appearance is enabled.
/// Default to NO, bars are more likely to show.
@property (nonatomic, assign) BOOL prefersNavigationBarHidden;

/// Max allowed initial distance to left edge when you begin the interactive pop
/// gesture. 0 by default, which means it will ignore this limit.
@property (nonatomic, assign) CGFloat interactivePopMaxAllowedInitialDistanceToLeftEdge;

@end

