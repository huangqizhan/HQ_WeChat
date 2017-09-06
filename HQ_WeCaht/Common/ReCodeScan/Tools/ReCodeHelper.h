//
//  ReCodeHelper.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/9/5.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


static const float kLineMinY = 100;
static const float kLineMaxY = 380;
static const float kReaderViewWidth = 200;
static const float kReaderViewHeight = 200;

@interface ReCodeHelper : NSObject


/**
 检测是否获得摄像头权限

 @param mediaType 媒体类型
 @return bool
 */
+ (BOOL)canAccessAVCaptureDeviceForMediaType:(NSString *)mediaType;


/**
 读取图片二维码

 @param imagePicked image
 @return code
 */
+ (NSString *)readQRCodeImage:(UIImage *)imagePicked;


/**
 生成二维码

 @param strQRCode code
 @return image
 */
+ (UIImage *)generateQRCodeImage:(NSString *)strQRCode  size:(CGSize)size;


/**
 扫码区域

 @param asize 扫码区的宽高
 @return frame
 */
+ (CGRect)getReaderViewBoundsWithSize:(CGSize)asize;


/**
 添加扫码动画

 @return 动画
 */
+ (CAKeyframeAnimation *)zoomOutAnimation;

@end
