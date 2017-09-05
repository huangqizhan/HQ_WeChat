//
//  HQQRCodeViewController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/8/29.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQQRCodeViewController.h"
#import "HQRQCodeView.h"
#import "ZbarWraper.h"





@interface HQQRCodeViewController ()

@property (nonatomic,strong) HQRQCodeView *recodeView;
@property (nonatomic,strong) ZbarWraper *zabarWraper;

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
    
    [self performSelector:@selector(startReCode) withObject:nil afterDelay:0.3];
    
}

- (void)startReCode{
    
    UIView *videoView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    videoView.backgroundColor = [UIColor clearColor];
    [self.view insertSubview:videoView atIndex:0];
    
    _zabarWraper = [[ZbarWraper alloc]initWithPreView:videoView barCodeType:ZBAR_I25 block:^(NSArray<ZbarResult *> *result) {
        NSLog(@"result = %@",result);
//        //测试，只使用扫码结果第一项
//        LBXZbarResult *firstObj = result[0];
//        
//        LBXScanResult *scanResult = [[LBXScanResult alloc]init];
//        scanResult.strScanned = firstObj.strScanned;
//        scanResult.imgScanned = firstObj.imgScanned;
//        scanResult.strBarCodeType = [LBXZBarWrapper convertFormat2String:firstObj.format];
//        
//        [weakSelf scanResultWithArray:@[scanResult]];
    }];
    [_zabarWraper start];

}

- (HQRQCodeView *)recodeView{
    if (_recodeView == nil) {
        _recodeView = [[HQRQCodeView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, APP_Frame_Height-64)];
    }
    return _recodeView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
