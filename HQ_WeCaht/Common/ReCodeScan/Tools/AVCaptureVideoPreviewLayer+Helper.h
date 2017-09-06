//
//  AVCaptureVideoPreviewLayer+Helper.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/9/5.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface AVCaptureVideoPreviewLayer (Helper)


+ (AVCaptureVideoPreviewLayer *)captureVideoPreviewLayerWithFrame:(CGRect)frame
                                                   rectOfInterest:(CGRect)rectOfInterest
                                                    captureDevice:(AVCaptureDevice *)captureDevice
                                          metadataObjectsDelegate:(id<AVCaptureMetadataOutputObjectsDelegate>)metadataObjectsDelegate;

@end
