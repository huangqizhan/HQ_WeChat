//
//  HQTabBarViewController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/2/20.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HQTabBarViewController.h"
#import "HQNavigationController.h"
#import "HQChatListViewController.h"
#import "HQContactViewController.h"
#import "HQDiscoverViewController.h"
#import "HQMineViewController.h"





@interface HQTabBarViewController ()

@end

@implementation HQTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    HQChatListViewController *messageVc = [[HQChatListViewController alloc] init];
    [self addChildVc:messageVc title:@"微信" image:@"tabbar_mainframe" selectedImage:@"tabbar_mainframeHL"];
    
    HQContactViewController *contactsVc = [[HQContactViewController alloc] init];
    [self addChildVc:contactsVc title:@"通讯录" image:@"tabbar_contacts" selectedImage:@"tabbar_contactsHL"];
    
    HQDiscoverViewController *applicationVc = [[HQDiscoverViewController alloc] init];
    [self addChildVc:applicationVc title:@"发现" image:@"tabbar_discover" selectedImage:@"tabbar_discoverHL"];
    
    HQMineViewController *mineVc = [[HQMineViewController alloc] init];
    [self addChildVc:mineVc title:@"我" image:@"tabbar_me" selectedImage:@"tabbar_meHL"];
    self.selectedIndex = 0;
    [self setupTabBar];
}

- (void)setupTabBar{
    UIView *bgView = [[UIView alloc] initWithFrame:self.tabBar.bounds];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.tabBar insertSubview:bgView atIndex:0];
    self.tabBar.opaque = YES;
}

- (void)addChildVc:(UIViewController *)childVc title:(NSString *)title image:(NSString *)image selectedImage:(NSString *)selectedImage{
    childVc.title = title;
    childVc.tabBarItem.image = [UIImage imageNamed:image];
    childVc.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = XZColor(123, 123, 123);
    NSMutableDictionary *selectTextAttrs = [NSMutableDictionary dictionary];
    selectTextAttrs[NSForegroundColorAttributeName] = XZColor(26, 178, 10);
    [childVc.tabBarItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
    [childVc.tabBarItem setTitleTextAttributes:selectTextAttrs forState:UIControlStateSelected];
    
    HQNavigationController *nav = [[HQNavigationController alloc] initWithRootViewController:childVc];
    [self addChildViewController:nav];
    
    
}
- (void)receiveNewMessage:(ChatMessageModel *)messageModel{
    @synchronized (self) {
        [self.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            HQNavigationController *navi = (HQNavigationController *)obj;
            [navi.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.class isSubclassOfClass:[HQMessageBaseController class]]) {
                    HQMessageBaseController *messgaeVC = (HQMessageBaseController *)obj;
                    [messgaeVC messageHandleWith:messageModel];
                }
            }];
        }];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
