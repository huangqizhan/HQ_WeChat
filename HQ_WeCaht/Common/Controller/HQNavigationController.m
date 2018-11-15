//
//  HQNavigationController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/2/20.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HQNavigationController.h"

@interface HQNavigationController ()<UIGestureRecognizerDelegate,UINavigationControllerDelegate>

@end

@implementation HQNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        self.interactivePopGestureRecognizer.delegate   = self;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *item = [UIBarButtonItem appearance];
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = [UIColor whiteColor];
    textAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:16.0];
    [item setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
//    self.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,NSFontAttributeName,[UIFont fontWithName:@"Arial" size:18], nil];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage gxz_imageWithColor:XZColor(43, 45, 40)] forBarMetrics:UIBarMetricsDefault];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    self.navigationBar.translucent = NO;
}
- (BOOL)shouldAutorotate {
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.topViewController supportedInterfaceOrientations];
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.topViewController.preferredStatusBarStyle;
}

- (BOOL)prefersStatusBarHidden {
    return self.topViewController.prefersStatusBarHidden;
}


//FIXME:这样做防止主界面卡顿时，导致一个ViewController被push多次
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.childViewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
        if ([[self.childViewControllers lastObject] isKindOfClass:[viewController class]]) {
            return;
        }
    }
    [super pushViewController:viewController animated:animated];
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setBarAlpha:(CGFloat)alpha {
    self.navigationBar.subviews[0].alpha = alpha;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
