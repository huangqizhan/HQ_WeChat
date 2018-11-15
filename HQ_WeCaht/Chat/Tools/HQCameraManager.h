//
//  HQCameraManager.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/20.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "HQCameraDefine.h"


#define MAX_PINCH_SCALE_NUM   3.f
#define MIN_PINCH_SCALE_NUM   1.f

typedef void(^DidCapturePhotoBlock)(UIImage *stillImage);


@protocol HQCameraManagerDelehate;

@interface HQCameraManager : NSObject

@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureDeviceInput *inputDevice;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;


@property (nonatomic, assign) CGFloat preScaleNum;
@property (nonatomic, assign) CGFloat scaleNum;


@property (nonatomic,assign)id <HQCameraManagerDelehate>delegate;

- (void)configureWithParentLayer:(UIView*)parent previewRect:(CGRect)preivewRect;

- (void)takePicture:(DidCapturePhotoBlock)block;
- (void)switchCamera:(BOOL)isFrontCamera;
- (void)pinchCameraViewWithScalNum:(CGFloat)scale;
- (void)pinchCameraView:(UIPinchGestureRecognizer*)gesture;
- (void)switchFlashMode:(UIButton*)sender;
- (void)focusInPoint:(CGPoint)devicePoint;
- (void)switchGrid:(BOOL)toShow;

@end



@protocol HQCameraManagerDelehate <NSObject>

@optional

- (void)didCapturePhoto:(UIImage*)stillImage;

@end
