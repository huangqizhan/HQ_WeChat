//
//  ZbarWraper.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/9/4.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZBarSDK.h"


@interface ZbarResult : NSObject

////条码字符串
@property (nonatomic, copy) NSString* strScanned;
//// 扫码图像
@property (nonatomic, strong) UIImage* imgScanned;
////扫码码的类型，码制
@property (nonatomic, assign) zbar_symbol_type_t format;

@end




@interface ZbarWraper : NSObject


/**
 Zbar 扫描封装

 @param preView 父视图
 @param barCodeType 编码类型
 @param block 回调
 @return 扫描对象
 */
- (instancetype)initWithPreView:(UIView*)preView barCodeType:(zbar_symbol_type_t)barCodeType block:(void(^)(NSArray<ZbarResult*> *result))block;


////切换扫码类型
- (void)changeBarCode:(zbar_symbol_type_t)zbarFormat;


 ////启动扫码

- (void)start;


/// 关闭扫码
- (void)stop;


///根据闪光灯状态，切换成相反状态
- (void)openOrCloseFlash;



/**
 识别图片
 
 @param image 图片
 @param block 返回失败结果
 */
+ (void)recognizeImage:(UIImage*)image block:(void(^)(NSArray<ZbarResult*> *result))block;


/**
 将码的类型转换字符串表示
 
 @param format 码的类型
 @return 返回码的字符串
 */
+ (NSString*)convertFormat2String:(zbar_symbol_type_t)format;


@end
