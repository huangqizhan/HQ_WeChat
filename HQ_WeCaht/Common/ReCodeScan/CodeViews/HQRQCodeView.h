//
//  HQRQCodeView.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/8/30.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Barcode,HQRQCodeView;

@protocol HQRQCodeViewPinGestureDelegate <NSObject>


@optional

/**
 放缩手势已经开始

 @param codeView self
 @param gesture 手势
 */
- (void)HQRQCodeView:(HQRQCodeView *)codeView gestureDidBegin:(UIPinchGestureRecognizer *)gesture;

/**
 放缩手势开始变化
 
 @param codeView self
 @param gesture 手势
 */
- (void)HQRQCodeView:(HQRQCodeView *)codeView gestureDidChange:(UIPinchGestureRecognizer *)gesture;
/**
 放缩手势已经停止
 
 @param codeView self
 @param gesture 手势
 */
- (void)HQRQCodeView:(HQRQCodeView *)codeView gestureDidEnd:(UIPinchGestureRecognizer *)gesture;

@end



@interface HQRQCodeView : UIView

/* 扫码区域**/
@property (nonatomic,assign) CGRect ScanRect;
/*手势代理*/
@property (nonatomic,weak) id <HQRQCodeViewPinGestureDelegate>delegate;

/* 将要开始扫描 开启相机的hud 内容*/
- (void)startRecodeWithContent:(NSString *)content;
/* 开始扫码   结束hud*/
- (void)beginRecodeWhenDidEndAnimation;
/*结束扫描*/
- (void)dismissReCodeView;

/////  根据扫码结果生成 BarCode对象
- (Barcode *)processMetadataObject:(AVMetadataMachineReadableCodeObject *)code;
///扫码结束之后显示聚焦动画
- (void)recodeDidFinishAnimationActionWithRect:(CGRect)rect  Complite:(void (^)())complite;


@end



@interface AnimationShapeLayer : UIView


@end








@interface ReCodeIndicatorView : UIView

- (void)startRecodeWithContent:(NSString *)content;

- (void)stopReCode;

@end





@interface Barcode : NSObject
/////扫码数据
@property (nonatomic, strong) AVMetadataMachineReadableCodeObject *metadataObject;
////二维码的四个拐角组成的四边形
@property (nonatomic, strong) UIBezierPath *cornersPath;
/////二维码在屏幕坐标系内的矩形区域
@property (nonatomic, strong) UIBezierPath *boundingBoxPath;
////在屏幕上的frame
@property (nonatomic,assign) CGRect codeFrame;
////扫码内容
@property (nonatomic,copy) NSString *codeString;

@end

