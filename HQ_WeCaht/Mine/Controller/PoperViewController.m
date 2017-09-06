//
//  PoperViewController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/8/28.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "PoperViewController.h"
#import "HQPopoverAction.h"
#import "HQPopoverView.h"



@interface PoperViewController ()

@end

@implementation PoperViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
//    
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(leftButtonAction:)];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(rightButtonAction:)];
    
    UIButton *topRightBut = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [topRightBut setImage:[UIImage imageNamed:@"addActionIcon"] forState:UIControlStateNormal];
    [topRightBut addTarget:self action:@selector(rightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:topRightBut];
    
    
    UIButton *topBut = [[UIButton alloc] initWithFrame:CGRectMake((App_Frame_Width - 50)/2.0, 50, 50, 50)];
    topBut.backgroundColor = [UIColor greenColor];
    [topBut setTitle:@"top" forState:UIControlStateNormal];
    [topBut addTarget:self action:@selector(topButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:topBut];
    
    UIButton *bottomMiddleBut = [[UIButton alloc] initWithFrame:CGRectMake((App_Frame_Width - 50)/2.0, APP_Frame_Height-200, 50, 50)];
    
    bottomMiddleBut.backgroundColor = [UIColor greenColor];
    [bottomMiddleBut setTitle:@"boMBut" forState:UIControlStateNormal];
    [bottomMiddleBut addTarget:self action:@selector(bottomMiddleButAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bottomMiddleBut];
    
    UIButton *bottomLeftBut = [[UIButton alloc] initWithFrame:CGRectMake(30, APP_Frame_Height-150, 50, 50)];
    
    bottomLeftBut.backgroundColor = [UIColor greenColor];
    [bottomLeftBut setTitle:@"boLBut" forState:UIControlStateNormal];
    [bottomLeftBut addTarget:self action:@selector(bottomLeftButAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bottomLeftBut];
    
    UIButton *bottomRightBut = [[UIButton alloc] initWithFrame:CGRectMake(App_Frame_Width-80, APP_Frame_Height-150, 50, 50)];
    
    bottomRightBut.backgroundColor = [UIColor greenColor];
    [bottomRightBut setTitle:@"boRBut" forState:UIControlStateNormal];
    [bottomRightBut addTarget:self action:@selector(bottomRightButAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bottomRightBut];
    
    
    UIButton *backBut  = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    [backBut setTitle:@"back" forState:UIControlStateNormal];
    [backBut addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = backBut;
}
- (void)backButtonAction:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)leftButtonAction:(UIBarButtonItem *)sender{
    HQPopoverAction *action1 = [HQPopoverAction actionWithImage:[UIImage imageNamed:@"contacts_add_newmessage"] title:@"发起群聊" handler:^(HQPopoverAction *action) {
        
    }];
    HQPopoverAction *action2 = [HQPopoverAction actionWithImage:[UIImage imageNamed:@"contacts_add_friend"] title:@"添加朋友" handler:^(HQPopoverAction *action) {
        
    }];
    HQPopoverAction *action3 = [HQPopoverAction actionWithImage:[UIImage imageNamed:@"contacts_add_scan"] title:@"扫一扫" handler:^(HQPopoverAction *action) {
        
    }];
    HQPopoverAction *action4 = [HQPopoverAction actionWithImage:[UIImage imageNamed:@"contacts_add_money"] title:@"收付款" handler:^(HQPopoverAction *action) {
        
    }];
    
    HQPopoverView *popoverView = [HQPopoverView popoverView];
    popoverView.style = HQHQPopoverActionDarkStyle;
    // 在没有系统控件的情况下调用可以使用显示在指定的点坐标的方法弹出菜单控件.
    [popoverView showToPoint:CGPointMake(20, 64) withActions:@[action1, action2, action3, action4]];
}
- (NSArray <HQPopoverAction *> *)getQQActions{
    // 发起多人聊天 action
    HQPopoverAction *multichatAction = [HQPopoverAction actionWithImage:[UIImage imageNamed:@"right_menu_multichat"] title:@"发起多人聊天" handler:^(HQPopoverAction *action) {
        
        
    }];
    // 加好友 action
    HQPopoverAction *addFriAction = [HQPopoverAction actionWithImage:[UIImage imageNamed:@"right_menu_addFri"] title:@"加好友" handler:^(HQPopoverAction *action) {
        
    }];
    // 扫一扫 action
    HQPopoverAction *QRAction = [HQPopoverAction actionWithImage:[UIImage imageNamed:@"right_menu_QR"] title:@"扫一扫" handler:^(HQPopoverAction *action) {
        
    }];
    // 面对面快传 action
    HQPopoverAction *facetofaceAction = [HQPopoverAction actionWithImage:[UIImage imageNamed:@"right_menu_facetoface"] title:@"面对面快传" handler:^(HQPopoverAction *action) {
        
    }];
    // 付款 action
    HQPopoverAction *payMoneyAction = [HQPopoverAction actionWithImage:[UIImage imageNamed:@"right_menu_payMoney"] title:@"付款" handler:^(HQPopoverAction *action) {
        
    }];
    return @[multichatAction, addFriAction, QRAction, facetofaceAction, payMoneyAction];
}
- (void)rightButtonAction:(UIButton *)sender{
    
    HQPopoverView *popoverView = [HQPopoverView popoverView];
    [popoverView showToView:sender withActions: [self getQQActions]];
}

- (void)topButtonAction:(UIButton *)sender{
    HQPopoverView *popoverView = [HQPopoverView popoverView];
    popoverView.hideAfterTouchOutside = NO;
    [popoverView showToView:sender withActions: [self getQQActions]];

}
- (void)bottomMiddleButAction:(UIButton *)sender{
    // 不带图片
    HQPopoverAction *action1 = [HQPopoverAction actionWithTitle:@"加好友" handler:^(HQPopoverAction *action) {
        
    }];
    HQPopoverAction *action2 = [HQPopoverAction actionWithTitle:@"扫一扫" handler:^(HQPopoverAction *action) {
        
    }];
    HQPopoverAction *action3 = [HQPopoverAction actionWithTitle:@"发起聊天" handler:^(HQPopoverAction *action) {
        
    }];
    HQPopoverAction *action4 = [HQPopoverAction actionWithTitle:@"发起群聊" handler:^(HQPopoverAction *action) {
        
    }];
    HQPopoverAction *action5 = [HQPopoverAction actionWithTitle:@"查找群聊" handler:^(HQPopoverAction *action) {
        
    }];
    HQPopoverAction *action6 = [HQPopoverAction actionWithTitle:@"我的群聊" handler:^(HQPopoverAction *action) {
        
    }];
    
    HQPopoverView *popoverView = [HQPopoverView popoverView];
    popoverView.style = HQHQPopoverActionDarkStyle;
    popoverView.hideAfterTouchOutside = NO; // 点击外部时不允许隐藏
    [popoverView showToView:sender withActions:@[action1, action2, action3, action4, action5, action6]];

}
- (void)bottomLeftButAction:(UIButton *)sender{
    HQPopoverView *popoverView = [HQPopoverView popoverView];
    popoverView.showShade = YES;
    [popoverView showToView:sender withActions: [self getQQActions]];
}
- (void)bottomRightButAction:(UIButton *)sender{
    HQPopoverView *popoverView = [HQPopoverView popoverView];
    popoverView.showShade = YES;
    [popoverView showToView:sender withActions: [self getQQActions]];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
