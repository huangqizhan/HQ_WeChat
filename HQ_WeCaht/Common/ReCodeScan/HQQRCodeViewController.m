//
//  HQQRCodeViewController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/8/29.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQQRCodeViewController.h"
#import "HQRQCodeView.h"




@interface HQQRCodeViewController ()

@property (nonatomic,strong) HQRQCodeView *recodeView;

@end

@implementation HQQRCodeViewController


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.recodeView startRecodeWithContent:@"正在启动相机"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.title = @"扫码";
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone; //UIRectEdgeAll
    }
    [self creatRecodeView];
}
- (void)creatRecodeView{
    [self.view addSubview:self.recodeView];

}


- (HQRQCodeView *)recodeView{
    if (_recodeView == nil) {
        _recodeView = [[HQRQCodeView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, APP_Frame_Height-64)];
    }
    return _recodeView;
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
