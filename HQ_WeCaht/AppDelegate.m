//
//  AppDelegate.m
//  HQ_WeCaht
//
//  Created by 黄麒展 on 17/2/19.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "AppDelegate.h"
#import "HQTabBarViewController.h"
#import "HQReceiveMessageManager.h"
#import <UserNotifications/UserNotifications.h>
#import "HQURLProticol.h"
#import "HQFirstConfigViewController.h"



@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    [NSURLProtocol registerClass:[HQURLProticol class]];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    if (![[HQFileTools GetUserDefaultWithKey:HQ_WeIsFirstInstallKey] boolValue]) {
        [HQFileTools SetUserDefault:@1 forKey:HQ_WeIsFirstInstallKey];
        HQFirstConfigViewController *firstVC = [[HQFirstConfigViewController alloc] init];
        self.window.rootViewController = firstVC;
    }else{
        [self registerLoclRegister:application];
        [self configerUI];
    }
    [self.window makeKeyAndVisible];
    return YES;
}
- (void)configerUI{
    [HQReceiveMessageManager shareInstance];
    [self configureAPIKey];
    self.window.rootViewController = [[HQTabBarViewController alloc] init];
}

/////注册本地通知
- (void)registerLoclRegister:(UIApplication *)application{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        // iOS 10 特有
        // 1、创建一个 UNUserNotificationCenter
        UNUserNotificationCenter *requestCenter = [UNUserNotificationCenter currentNotificationCenter];
        // 必须写代理，不然无法监听通知的接收与点击
        requestCenter.delegate = self;
        [requestCenter requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                // 点击允许
                NSLog(@"注册成功");
                [requestCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                    NSLog(@"%@",settings);
                }];
            }else {
                // 点击不允许
                NSLog(@"注册失败");
            }
        }];
    }else{
        // iOS 8 ~iOS 10
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil]];
    }
}
- (void)configureAPIKey{
    if ([HQ_WeChatAMapKey length] == 0){
        NSString *reason = [NSString stringWithFormat:@"apiKey为空，请检查key是否正确设置。"];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:reason delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
        NSLog(@"reason = %@",reason);
    }
    [AMapServices sharedServices].apiKey = HQ_WeChatAMapKey;
}

// iOS 10收到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    
    
    NSDictionary *userInfo = notification.request.content.userInfo;
    UNNotificationRequest *request = notification.request;  // 收到推送的请求
    UNNotificationContent *content = request.content;       // 收到推送的消息内容
    NSNumber *badge = content.badge;                        // 推送消息的角标
    NSString *body = content.body;                          // 推送消息体
    UNNotificationSound *sound = content.sound;             // 推送消息的声音
    NSString *subString = content.subtitle;                 // 推送消息的副标题
    NSString *title = content.title;                        // 推送消息的标题
    
    if ([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        
        NSLog(@"iOS10 前台收到本地通知：");
        
    } else {
        // 判断为本地通知
        NSLog(@"iOS 10 收到本地通知：{\nbody:%@,\ntitle:%@,\nsubtitle:%@,\nbadge:%@,\nsound:%@,\nuserInfo:%@\n}",body,title,subString,badge,sound,userInfo);
    }
    // Warning: UNUserNotificationCenter delegate received call to -userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler: but the completion handler was never called.
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
}

// 通知的点击事件
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
    
    // 通知图标减少一
    [UIApplication sharedApplication].applicationIconBadgeNumber --;
    
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    UNNotificationRequest *request = response.notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"iOS10 收到远程通知:");
        
    }
    else {
        // 判断为本地通知
        NSLog(@"iOS10 收到本地通知:{\\\\nbody:%@，\\\\ntitle:%@,\\\\nsubtitle:%@,\\\\nbadge：%@，\\\\nsound：%@，\\\\nuserInfo：%@\\\\n}",body,title,subtitle,badge,sound,userInfo);
    }
    
    // Warning: UNUserNotificationCenter delegate received call to -userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler: but the completion handler was never called.
    completionHandler();  // 系统要求执行这个方法
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    ////保存界面的数据
    HQTabBarViewController *tabbar = (HQTabBarViewController *)self.window.rootViewController;
    [tabbar.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        HQNavigationController *navi = (HQNavigationController *)obj;
        [navi.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.class isSubclassOfClass:[HQMessageBaseController class]]) {
                HQMessageBaseController *messgaeVC = (HQMessageBaseController *)obj;
                [messgaeVC saveUIDataWhenApplicationWillDissmiss];
            }
        }];
    }];
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    ////保存界面的数据
    HQTabBarViewController *tabbar = (HQTabBarViewController *)self.window.rootViewController;
    [tabbar.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        HQNavigationController *navi = (HQNavigationController *)obj;
        [navi.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.class isSubclassOfClass:[HQMessageBaseController class]]) {
                HQMessageBaseController *messgaeVC = (HQMessageBaseController *)obj;
                [messgaeVC saveUIDataWhenApplicationWillDissmiss];
            }
        }];
    }];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
