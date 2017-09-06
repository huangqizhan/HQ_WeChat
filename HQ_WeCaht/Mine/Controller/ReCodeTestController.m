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



@interface ReCodeTestController () <AVCaptureMetadataOutputObjectsDelegate,CAAnimationDelegate>

////输入输出回话
@property (nonatomic, strong) AVCaptureSession *qrSession;
////输入输出设备
@property (nonatomic, strong) AVCaptureDevice *captureDevice;
////输出数据的显示层
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *qrVideoPreviewLayer;
/////扫码视图
@property (nonatomic,strong) HQRQCodeView *recodeView;


@end

@implementation ReCodeTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    self.title = @"Scan";
    if (![ReCodeHelper canAccessAVCaptureDeviceForMediaType:AVMediaTypeVideo]) {
        return;
    }
    [self.view addSubview:self.recodeView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self StartRecodeView];
    });
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
     [self.recodeView startRecodeWithContent:@"正在启动相机"];
}
- (void )StartRecodeView{
    _captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

    _qrVideoPreviewLayer = [AVCaptureVideoPreviewLayer captureVideoPreviewLayerWithFrame:self.view.bounds rectOfInterest:[ReCodeHelper getReaderViewBoundsWithSize:CGSizeMake(kReaderViewWidth, kReaderViewHeight)] captureDevice:_captureDevice metadataObjectsDelegate:self];
    if (_qrVideoPreviewLayer == nil) {
        return;
    }
    _qrSession = _qrVideoPreviewLayer.session;
    [self.view.layer insertSublayer:_qrVideoPreviewLayer atIndex:0];
    [self startRecodeWithAnimation];
    [_qrSession startRunning];
}
#pragma mark -------- 添加扫码视图的动画显示 ------
- (void)startRecodeWithAnimation{
    CAKeyframeAnimation *animationLayer = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animationLayer.duration = 0.1;
    animationLayer.delegate = self;
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animationLayer.values = values;
    [_qrVideoPreviewLayer addAnimation:animationLayer forKey:nil];
}
#pragma mark -AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
//    BOOL fail = YES;
//    
//    //扫描结果
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *responseObj = metadataObjects[0];
        //        //org.iso.QRCode
                if ([responseObj.type containsString:@"QRCode"]) {
                    NSLog(@"type = %@",responseObj.type);
                }
        if (responseObj) {
            NSString *strResponse = responseObj.stringValue;
            NSLog(@"qrcodestring==%@",strResponse);
            if (strResponse && ![strResponse isEqualToString:@""] && strResponse.length > 0) {
                NSLog(@"qrcodestring==%@",strResponse);
                if ([strResponse hasPrefix:@"http"]) {
                    AudioServicesPlaySystemSound(1360);
                }
            }
        }
    }
//
//    if (fail) {
//        if (self.SYQRCodeFailBlock) {
//            self.SYQRCodeFailBlock(self);
//        }
//    }
}
- (HQRQCodeView *)recodeView{
    if (_recodeView == nil) {
        _recodeView = [[HQRQCodeView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, APP_Frame_Height-64)];
    }
    return _recodeView;
}
#pragma mark ------- CAAnimationDelegate -----
- (void)animationDidStart:(CAAnimation *)anim{
    NSLog(@"animationDidStart");
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    [self.recodeView beginRecodeWhenDidEndAnimation];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
