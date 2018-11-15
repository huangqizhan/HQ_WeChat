//
//  HQPopover.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/7.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"



@interface HQPopover : NSObject <MBProgressHUDDelegate>

#pragma mark -------- alert -----
+ (void)showMessageAlertWithTitle:(nullable NSString *)title message:(NSString *_Nullable)message;

+ (void)showMessageAlertWithTitle:(nullable NSString *)title message:(NSString *_Nullable)message actionTitle:(NSString *_Nullable)actionTitle;

+ (void)showMessageAlertWithTitle:(nullable NSString *)title message:(NSString *_Nullable)message actionTitle:(NSString *_Nullable)actionTitle actionHandler:(void (^ __nullable)())actionHandler;

+ (void)showConfirmAlertWithTitle:(nullable NSString *)title message:(NSString *_Nullable)message yesTitle:(NSString *_Nullable)yesTitle yesAction:(void (^ __nullable)())yesAction;

+ (void)showConfirmAlertWithTitle:(nullable NSString *)title message:(NSString *_Nullable)message yesTitle:(NSString *_Nullable)yesTitle yesAction:(void (^ __nullable)())yesAction cancelTitle:(NSString *_Nullable)cancelTitle cancelAction:(void (^ __nullable)())cancelAction;

+ (void)showConfirmAlertWithTitle:(NSString *_Nullable)title message:(NSString *_Nullable)message firstActionTitle:(NSString *_Nullable)firstActionTitle firstAction:(void (^ __nullable)())firstAction secondActionTitle:(NSString *_Nullable)secondActionTitle secondAction:(void (^ __nullable)())secondAction;



+ (UIViewController *_Nullable)mostFrontViewController;



#pragma mark  -------  HUD  ------------

+ (MBProgressHUD *_Nullable)showActionSuccessHUD:(NSString *_Nullable)title inView:(nullable UIView *)view;

+ (MBProgressHUD *_Nullable)showActionSuccessHUD:(NSString *_Nullable)title;

+ (MBProgressHUD *_Nullable)showTextHUD:(NSString *_Nullable)text inView:(nullable UIView *)view;

+ (MBProgressHUD *_Nullable)showTextHUD:(NSString *_Nullable)text;

+ (MBProgressHUD *_Nullable)showCircleProgressHUDInView:(UIView *_Nullable)view;

+ (MBProgressHUD *_Nullable)showActivityIndicatiorHUDWithTitle:(nullable NSString *)title inView:(nullable UIView *)view;

+ (MBProgressHUD *_Nullable)showActivityIndicatiorHUDWithTitle:(nullable NSString *)title;

+ (void)hideHUD:(MBProgressHUD *_Nullable)HUD animated:(BOOL)animated;






@end
