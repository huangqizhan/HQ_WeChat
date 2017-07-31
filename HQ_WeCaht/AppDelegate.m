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



@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [[HQTabBarViewController alloc] init];
    [self.window makeKeyAndVisible];
    [HQReceiveMessageManager shareInstance];
    [self configureAPIKey];
    return YES;
}

- (void)configureAPIKey{
    if ([HQ_WeChatAMapKey length] == 0){
        NSString *reason = [NSString stringWithFormat:@"apiKey为空，请检查key是否正确设置。"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:reason delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    [AMapServices sharedServices].apiKey = HQ_WeChatAMapKey;
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
