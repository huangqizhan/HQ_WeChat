//
//  HQQRCodeViewController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/8/29.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQQRCodeViewController.h"
#import "HQRQCodeView.h"
#import "AVCaptureVideoPreviewLayer+Helper.h"
#import "HQReCodeResultController.h"
#import "HQRecodeResultWebController.h"


@interface HQQRCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate,CAAnimationDelegate,HQRQCodeViewPinGestureDelegate>

////输入输出回话
@property (nonatomic, strong) AVCaptureSession *qrSession;
////输入输出设备
@property (nonatomic, strong) AVCaptureDevice *captureDevice;
////输出数据的显示层
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *qrVideoPreviewLayer;
/////扫码视图
@property (nonatomic,strong) HQRQCodeView *recodeView;
///合成语音朗读
@property (nonatomic,strong) AVSpeechSynthesizer *speechSynthesizer;
///开始放缩时的值
@property (nonatomic,assign) CGFloat initialPinchZoom;


@end

@implementation HQQRCodeViewController


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.recodeView startRecodeWithContent:@"正在启动相机"];
    if (!_qrSession.isRunning) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.recodeView beginRecodeWhenDidEndAnimation];
            [self startSesstionRecode];
        });
    }
}
- (void)willMoveToParentViewController:(UIViewController*)parent{
    if ([self isViewLoaded]) {
        [self stopSesstionRecode];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.title = @"扫码";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"开灯" style:UIBarButtonItemStylePlain target:self action:@selector(flushFocusAction:)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone; //UIRectEdgeAll
    }
    if (![ReCodeHelper canAccessAVCaptureDeviceForMediaType:AVMediaTypeVideo]) {
        return;
    }
    [self setUp];
}
- (void)applicationWillEnterForeground:(NSNotification *)note{
    [self startSesstionRecode];
}
- (void)applicationDidEnterBackground:(NSNotification *)note{
    [self stopSesstionRecode];
}

- (void)flushFocusAction:(UIBarButtonItem *)sender{
    if ([sender.title isEqualToString:@"开灯"]) {
        [self turnOnTorch:YES];
        [sender setTitle:@"关灯"];
    }else{
        [self turnOnTorch:NO];
        [sender setTitle:@"开灯"];
    }
}
- (void)turnOnTorch:(BOOL)on {
    if (_captureDevice) {
        [_captureDevice lockForConfiguration:nil];
        if (on) {
            [_captureDevice setTorchMode:AVCaptureTorchModeOn];
        }
        else {
            [_captureDevice setTorchMode: AVCaptureTorchModeOff];
        }
        
        [_captureDevice unlockForConfiguration];
    }
}
- (void)setUp{
    
     [self.view addSubview:self.recodeView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self StartRecodeView];
    });
}

- (void )StartRecodeView{
    if (_captureDevice == nil) {
        _captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    if (_qrVideoPreviewLayer == nil) {
        _qrVideoPreviewLayer = [AVCaptureVideoPreviewLayer captureVideoPreviewLayerWithFrame:self.view.bounds rectOfInterest:[ReCodeHelper getReaderViewBoundsWithSize:CGSizeMake(kReaderViewWidth, kReaderViewHeight)] captureDevice:_captureDevice metadataObjectsDelegate:self];
    }
    if (_qrVideoPreviewLayer == nil) {
        return;
    }
//    _speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
    _qrSession = _qrVideoPreviewLayer.session;
    [self.view.layer insertSublayer:_qrVideoPreviewLayer atIndex:0];
    [self startRecodeWithAnimation];
    [self startSesstionRecode];
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
    [self stopSesstionRecode];
    ///用 AVCaptureMetadataOutput输出的数据已经进行了处理 
    NSMutableSet *foundBarcodes = [NSMutableSet new];
    [metadataObjects enumerateObjectsUsingBlock: ^(AVMetadataObject *obj, NSUInteger idx, BOOL *stop) {////二维码org.iso.QRCode      条形码 org.iso.Code128
        if ([obj isKindOfClass:[AVMetadataMachineReadableCodeObject class]]){
            AVMetadataMachineReadableCodeObject *code = (AVMetadataMachineReadableCodeObject*)
            [_qrVideoPreviewLayer transformedMetadataObjectForMetadataObject:obj];
            Barcode *barcode = [_recodeView processMetadataObject:code];
            [foundBarcodes addObject:barcode];
        }
    }];
    dispatch_sync(dispatch_get_main_queue(), ^{
        [foundBarcodes enumerateObjectsUsingBlock: ^(Barcode *barcode, BOOL *stop) {
            /*
             [_recodeView.layer addSublayer:boundingBoxLayer];
             //添加在屏幕坐标中的矩形区域
             CAShapeLayer *boundingBoxLayer = [CAShapeLayer new];
             boundingBoxLayer.path = barcode.boundingBoxPath.CGPath;
             boundingBoxLayer.lineWidth = 2.0f;
             boundingBoxLayer.strokeColor =  [UIColor greenColor].CGColor;
             boundingBoxLayer.fillColor =  [UIColor colorWithRed:0.0f green:1.0f blue:0.0f  alpha:0.5f].CGColor;
             [_recodeView.layer addSublayer:boundingBoxLayer];
             */
//            CAShapeLayer *cornersPathLayer = [CAShapeLayer new];
//            cornersPathLayer.path = barcode.cornersPath.CGPath;
//            cornersPathLayer.lineWidth = 2.0f;
//            cornersPathLayer.strokeColor =  [UIColor colorWithRed:(85.0)/255.0 green:(185.0)/255.0 blue:(50.0)/255.0 alpha:0.5].CGColor;
//            cornersPathLayer.fillColor =  [UIColor colorWithRed:(85.0)/255.0 green:(185.0)/255.0 blue:(50.0)/255.0 alpha:0.5].CGColor;
//            [_recodeView.layer addSublayer:cornersPathLayer];
            WEAKSELF;
            [self.recodeView recodeDidFinishAnimationActionWithRect:barcode.codeFrame Complite:^{
                [weakSelf  handleRecodeResultString:barcode.codeString];
            }];
        }];
         ////语音朗读
//        [foundBarcodes enumerateObjectsUsingBlock:^(Barcode *barcode, BOOL *stop) {
//            AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:barcode.metadataObject.stringValue];
//            utterance.rate = AVSpeechUtteranceMinimumSpeechRate + ((AVSpeechUtteranceMaximumSpeechRate - AVSpeechUtteranceMinimumSpeechRate) * 0.5f);
//            utterance.volume = 1.0f;
//            utterance.pitchMultiplier = 1.2f;
//            [_speechSynthesizer speakUtterance:utterance];
//        }];
    });
    /*
     1  创建用于遍历检测到的二维码的NSMutableSet。
     2 处理类型为AVMetadataMachineReadableCodeObject的对象。
     3 转换图像的bounds和corner坐标。将相对坐标转换为容器view的坐标。
     4处理二维码数据，将其加入到字典中。
     5 移除预览view中的所有子层。
     6 遍历所有检测到的二维码，为它们添加边界路径和角路径。这些layer有着不同的颜色，alpha值也被设置为0.5，这样我们可以透过叠加层看到原始二维码图片。
     */
}

- (void)handleRecodeResultString:(NSString *)resultString{
    NSURL *url = [[NSURL alloc] initWithString:resultString];
    if (([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"]) || [[UIApplication sharedApplication] canOpenURL:url]) {
        [self pushToWebControllerWithUrl:url];
    }else{
        [self pushToRecodeResultControllerWith:resultString];

    }
}
- (void)pushToRecodeResultControllerWith:(NSString *)codeString{
    HQReCodeResultController *resultVC = [[HQReCodeResultController alloc] init];
    resultVC.codeString = codeString;
    [self.navigationController pushViewController:resultVC animated:YES];
}
- (void)pushToWebControllerWithUrl:(NSURL *)url{
    HQRecodeResultWebController *webVC = [[HQRecodeResultWebController alloc] init];
    webVC.url = url;
    [self.navigationController pushViewController:webVC animated:YES];
}
- (void)stopSesstionRecode{
    [_qrSession stopRunning];
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];;
    [self.recodeView dismissReCodeView];
}
- (void)startSesstionRecode{
    [_qrSession startRunning];
    [[AVAudioSession sharedInstance] setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:0 error:nil];
}
- (void)addTestViewWithBouns:(CGRect )bounds{
    CGRect oriFrame = self.recodeView.ScanRect;
    CGRect newRect  = CGRectMake(oriFrame.origin.x*bounds.origin.x+self.recodeView.ScanRect.origin.x, oriFrame.origin.y*bounds.origin.y+self.recodeView.ScanRect.origin.y, oriFrame.size.width*bounds.size.width, oriFrame.size.height*bounds.size.height);
    UIView *testView = [[UIView alloc] initWithFrame:newRect];
    testView.backgroundColor = [UIColor redColor];
    [self.recodeView addSubview:testView];
}
#pragma mark ------- CAAnimationDelegate -----
- (void)animationDidStart:(CAAnimation *)anim{
//    NSLog(@"animationDidStart");
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    [self.recodeView beginRecodeWhenDidEndAnimation];
}

#pragma mark -------- HQRQCodeViewPinGestureDelegate ----

- (void)HQRQCodeView:(HQRQCodeView *)codeView gestureDidBegin:(UIPinchGestureRecognizer *)gesture{
    if (_captureDevice == nil) {
        return;
    }
    _initialPinchZoom = _captureDevice.videoZoomFactor;
}
- (void)HQRQCodeView:(HQRQCodeView *)codeView gestureDidChange:(UIPinchGestureRecognizer *)gesture{
    if (_captureDevice == nil) {
        return;
    }
    NSError *error = nil;
    [_captureDevice lockForConfiguration:&error];
    if (!error) {
        CGFloat zoomFactor;
        CGFloat scale = gesture.scale;
        if (scale < 1.0f) {
            zoomFactor = _initialPinchZoom - pow(_captureDevice.activeFormat.videoMaxZoomFactor, 1.0f - gesture.scale);
        }else{
            zoomFactor = _initialPinchZoom + pow(_captureDevice.activeFormat.videoMaxZoomFactor, (gesture.scale - 1.0f) / 2.0f);
        }
        zoomFactor = MIN(10.0f, zoomFactor);
        zoomFactor = MAX(1.0f, zoomFactor);
        _captureDevice.videoZoomFactor = zoomFactor;
        [_captureDevice unlockForConfiguration];
    }
}
- (void)HQRQCodeView:(HQRQCodeView *)codeView gestureDidEnd:(UIPinchGestureRecognizer *)gesture{
}
- (HQRQCodeView *)recodeView{
    if (_recodeView == nil) {
        _recodeView = [[HQRQCodeView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, APP_Frame_Height-64)];
        _recodeView.delegate = self;
    }
    return _recodeView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

/*
 bounds定义了包含二维码图像的矩形，corners定义了二维码图像的实际坐标：
 
 **/
