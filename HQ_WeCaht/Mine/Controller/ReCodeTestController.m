//
//  ReCodeTestController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/9/5.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "ReCodeTestController.h"
#import "AVCaptureVideoPreviewLayer+Helper.h"
#import "HQRQCodeView.h"



@interface ReCodeTestController ()

@property (nonatomic,strong) HQRQCodeView *recodeView;


@end

@implementation ReCodeTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.recodeView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonAction:)];
}
- (void)doneButtonAction:(id)sender{
    [self.recodeView recodeDidFinishAnimationActionWithRect:CGRectZero Complite:^{
        
    }];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//     [self.recodeView startRecodeWithContent:@"正在启动相机"];
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

@end
