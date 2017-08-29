//
//  UIApplication+HQExtern.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/5/26.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"


@interface UIApplication (HQExtern)

+ (UIViewController *_Nullable)rootViewController;

+ (UIWindow *_Nullable)currentWindow;

+ (UIWindow *_Nullable)popOverWindow;

+ (void)addViewToPopOverWindow:(UIView *_Nullable)view;

+ (void)removeViewFromPopOverWindow:(UIView *_Nullable)view;

+ (AppDelegate *_Nullable)appDelegate;

+ (UIViewController *_Nullable)viewControllerForView:(UIView *_Nullable)view;

+ (void)removeViewControllerFromParentViewController:(UIViewController *_Nullable)viewController;

+ (void)addViewController:(UIViewController *_Nullable)viewController  toViewController:(UIViewController *_Nullable)parentViewController;

+ (void)startObserveRunLoop;
    
+ (void)stopObserveRunLoop;

+ (void)showMessageAlertWithTitle:(nullable NSString *)title message:(NSString *_Nullable)message;

+ (void)showMessageAlertWithTitle:(nullable NSString *)title message:(NSString *_Nullable)message actionTitle:(NSString *_Nullable)actionTitle;

+ (void)showMessageAlertWithTitle:(nullable NSString *)title message:(NSString *_Nullable)message actionTitle:(NSString *_Nullable)actionTitle actionHandler:(void (^ __nullable)())actionHandler;

+ (void)showConfirmAlertWithTitle:(nullable NSString *)title message:(NSString *_Nullable)message yesTitle:(NSString *_Nullable)yesTitle yesAction:(void (^ __nullable)())yesAction;

+ (void)showConfirmAlertWithTitle:(nullable NSString *)title message:(NSString *_Nullable)message yesTitle:(NSString *_Nullable)yesTitle yesAction:(void (^ __nullable)())yesAction cancelTitle:(NSString *_Nullable)cancelTitle cancelAction:(void (^ __nullable)())cancelAction;

+ (void)showConfirmAlertWithTitle:(NSString *_Nullable)title message:(NSString *_Nullable)message firstActionTitle:(NSString *_Nullable)firstActionTitle firstAction:(void (^ __nullable)())firstAction secondActionTitle:(NSString *_Nullable)secondActionTitle secondAction:(void (^ __nullable)())secondAction;


+ (AVCaptureVideoOrientation) videoOrientationFromCurrentDeviceOrientation;

+ (CGRect)screenBounds;

@end
