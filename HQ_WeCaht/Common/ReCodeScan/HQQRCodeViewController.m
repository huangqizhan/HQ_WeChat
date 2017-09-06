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


@interface Barcode : NSObject
/////扫码数据
@property (nonatomic, strong) AVMetadataMachineReadableCodeObject *metadataObject;
////二维码的四个拐角组成的四边形
@property (nonatomic, strong) UIBezierPath *cornersPath;
/////二维码在屏幕坐标系内的矩形区域
@property (nonatomic, strong) UIBezierPath *boundingBoxPath;
@end

@implementation Barcode

@end


@interface HQQRCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate,CAAnimationDelegate>

////输入输出回话
@property (nonatomic, strong) AVCaptureSession *qrSession;
////输入输出设备
@property (nonatomic, strong) AVCaptureDevice *captureDevice;
////输出数据的显示层
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *qrVideoPreviewLayer;
/////扫码视图
@property (nonatomic,strong) HQRQCodeView *recodeView;
///存放多个扫码数据
@property (nonatomic,strong) NSMutableDictionary *barcodes;
///合成语音朗读
@property (nonatomic,strong) AVSpeechSynthesizer *speechSynthesizer;


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
    if (![ReCodeHelper canAccessAVCaptureDeviceForMediaType:AVMediaTypeVideo]) {
        return;
    }
     [self setUp];
}
- (void)setUp{
    _barcodes = [NSMutableDictionary new];
    _speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
     [self.view addSubview:self.recodeView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self StartRecodeView];
    });
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
    NSSet *originalBarcodes = [NSSet setWithArray:_barcodes.allValues];
    
    [_qrSession stopRunning];
    // 1
    NSMutableSet *foundBarcodes = [NSMutableSet new];
    [metadataObjects enumerateObjectsUsingBlock: ^(AVMetadataObject *obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"Metadata: %@", obj);
        // 2
        if ([obj isKindOfClass:[AVMetadataMachineReadableCodeObject class]])
        {
            // 3
            AVMetadataMachineReadableCodeObject *code = (AVMetadataMachineReadableCodeObject*)
            [_qrVideoPreviewLayer transformedMetadataObjectForMetadataObject:obj];
            // 4
            Barcode *barcode = [self processMetadataObject:code];
            [foundBarcodes addObject:barcode];
        }
    }];
    
    NSMutableSet *newBarcodes = [foundBarcodes mutableCopy];
    [newBarcodes minusSet:originalBarcodes];
    
    NSMutableSet *goneBarcodes = [originalBarcodes mutableCopy];
    [goneBarcodes minusSet:foundBarcodes];
    [goneBarcodes enumerateObjectsUsingBlock: ^(Barcode *barcode, BOOL *stop) {
        [_barcodes removeObjectForKey:barcode.metadataObject.stringValue];
    }];

    dispatch_sync(dispatch_get_main_queue(), ^{
//        // Remove all old layers
//        // 5
//        NSArray *allSublayers = [_recodeView.layer.sublayers copy];
//        [allSublayers enumerateObjectsUsingBlock: ^(CALayer *layer, NSUInteger idx, BOOL *stop) {
//            if (layer != _qrVideoPreviewLayer) {
//            [layer removeFromSuperlayer];
//        }
//        }];
////         Add new layers
//        // 6
        [foundBarcodes enumerateObjectsUsingBlock: ^(Barcode *barcode, BOOL *stop) {
            CAShapeLayer *boundingBoxLayer = [CAShapeLayer new];
            boundingBoxLayer.path = barcode.boundingBoxPath.CGPath; boundingBoxLayer.lineWidth = 2.0f; boundingBoxLayer.strokeColor =  [UIColor greenColor].CGColor;
            boundingBoxLayer.fillColor =  [UIColor colorWithRed:0.0f green:1.0f blue:0.0f
                            alpha:0.5f].CGColor;
            [_recodeView.layer addSublayer:boundingBoxLayer];
            CAShapeLayer *cornersPathLayer = [CAShapeLayer new];
            cornersPathLayer.path = barcode.cornersPath.CGPath;
            cornersPathLayer.lineWidth = 2.0f;
            cornersPathLayer.strokeColor =  [UIColor blueColor].CGColor;
            cornersPathLayer.fillColor =  [UIColor colorWithRed:0.0f green:0.0f blue:1.0f  alpha:0.5f].CGColor; [_recodeView.layer addSublayer:cornersPathLayer];
        }];

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
- (void)stopSesstionRecode{
    [_qrSession stopRunning];
    [self.recodeView dismissReCodeView];  
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
    NSLog(@"animationDidStart");
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    [self.recodeView beginRecodeWhenDidEndAnimation];
}

- (Barcode *)processMetadataObject:(AVMetadataMachineReadableCodeObject *)code{
    // 1
    Barcode *barcode = _barcodes[code.stringValue];
    
    // 2
    if (!barcode)
    {
        barcode = [Barcode new];
        _barcodes[code.stringValue] = barcode;
    }
    
    // 3
    barcode.metadataObject = code;
    
    // Create the path joining code's corners
    
    // 4
    CGMutablePathRef cornersPath = CGPathCreateMutable();
    
    // 5
    CGPoint point;
    CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)code.corners[0], &point);
    
    // 6
    CGPathMoveToPoint(cornersPath, nil, point.x, point.y);
    
    // 7
    for (int i = 1; i < code.corners.count; i++) {
        CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)code.corners[i], &point);
        CGPathAddLineToPoint(cornersPath, nil, point.x, point.y);
    }
    
    // 8
    CGPathCloseSubpath(cornersPath);
    
    // 9
    barcode.cornersPath =[UIBezierPath bezierPathWithCGPath:cornersPath];
    CGPathRelease(cornersPath);
    
    // Create the path for the code's bounding box
    
    // 10
    barcode.boundingBoxPath = [UIBezierPath bezierPathWithRect:code.bounds];
    
    // 11
    return barcode;
    
    /*
     
     
    1 查询Barcode对象字典，看是否有相同内容的Barcode已经存在。
    2 如果没有，创建一个Barcode对象并将其加入到字典中。
    3 存储二维码的元数据到新创建的Barcode对象中。
    4 创建用于存储绘制二维码四个角路径的cornersPath。
    5 使用CoreGraphics转换第一个角的坐标为CGPoint实例。
    6 从第五步构造的角开始绘制路径。
    7 循环遍历其它三个角，创建相应的路径。
    8 绘制第四个点到第一个点路径后，关闭路径。
    9 通过cornersPath创建UIBezierPath对象并将其存储到Barcode对象中。
    10 通过bezierPathWithRect:方法创建边框块。
    11 返回Barcode对象。
     */
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



/*
 bounds定义了包含二维码图像的矩形，corners定义了二维码图像的实际坐标：
 
 
 **/
