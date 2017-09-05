//
//  ReCodeTestController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/9/5.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "ReCodeTestController.h"
#import "AVCaptureVideoPreviewLayer+Helper.h"

@interface ReCodeTestController () <AVCaptureMetadataOutputObjectsDelegate>

////输入输出回话
@property (nonatomic, strong) AVCaptureSession *qrSession;
////输入输出设备
@property (nonatomic, strong) AVCaptureDevice *captureDevice;
////输出数据的显示层
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *qrVideoPreviewLayer;


@end

@implementation ReCodeTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    self.title = @"Scan";
    if ([ReCodeHelper canAccessAVCaptureDeviceForMediaType:AVMediaTypeVideo]) {
        NSLog(@"process");
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self StartRecodeView];
    });
}
- (BOOL)StartRecodeView{
    _captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

    _qrVideoPreviewLayer = [AVCaptureVideoPreviewLayer captureVideoPreviewLayerWithFrame:self.view.bounds rectOfInterest:[ReCodeHelper getReaderViewBoundsWithSize:CGSizeMake(kReaderViewWidth, kReaderViewHeight)] captureDevice:_captureDevice metadataObjectsDelegate:self];
    if (_qrVideoPreviewLayer == nil) {
        return NO;
    }
    _qrSession = _qrVideoPreviewLayer.session;
    [self.view.layer insertSublayer:_qrVideoPreviewLayer atIndex:0];
    [_qrVideoPreviewLayer addAnimation:[ReCodeHelper zoomOutAnimation] forKey:nil];

    
    [_qrSession startRunning];
    return YES;
}
#pragma mark -AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
//    [self stopSYQRCodeReading];
//    
//    BOOL fail = YES;
//    
//    //扫描结果
//    if (metadataObjects.count > 0) {
//        AVMetadataMachineReadableCodeObject *responseObj = metadataObjects[0];
//        //        //org.iso.QRCode
//        //        if ([responseObj.type containsString:@"QRCode"]) {
//        //
//        //        }
//        if (responseObj) {
//            NSString *strResponse = responseObj.stringValue;
//            
//            if (strResponse && ![strResponse isEqualToString:@""] && strResponse.length > 0) {
//                NSLog(@"qrcodestring==%@",strResponse);
//                
//                if ([strResponse hasPrefix:@"http"]) {
//                    fail = NO;
//#warning scan success提示
//                    AudioServicesPlaySystemSound(1360);
//                    
//                    if (self.SYQRCodeSuncessBlock) {
//                        self.SYQRCodeSuncessBlock(self, strResponse);
//                    }
//                }
//            }
//        }
//    }
//    
//    if (fail) {
//        if (self.SYQRCodeFailBlock) {
//            self.SYQRCodeFailBlock(self);
//        }
//    }
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
