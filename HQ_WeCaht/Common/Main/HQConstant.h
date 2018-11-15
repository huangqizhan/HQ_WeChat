//
//  HQConstant.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/11/6.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/// 左、右距离屏幕的间距 12
FOUNDATION_EXTERN CGFloat const SUGlobalViewLeftOrRightMargin;
/// 顶部、底部、中间间距 距离屏幕的间距 10
FOUNDATION_EXTERN CGFloat const SUGlobalViewInnerMargin;


/// MVC
/// 登录的手机号
FOUNDATION_EXTERN NSString *const SULoginPhoneKey0;
/// 登录的验证码
FOUNDATION_EXTERN NSString *const SULoginVerifyCodeKey0;

/// MVVM Without RAC
/// 登录的手机号
FOUNDATION_EXTERN NSString *const SULoginPhoneKey1;
/// 登录的验证码
FOUNDATION_EXTERN NSString *const SULoginVerifyCodeKey1;

/// MVVM With RAC
/// 登录的手机号
FOUNDATION_EXTERN NSString *const SULoginPhoneKey2;
/// 登录的验证码
FOUNDATION_EXTERN NSString *const SULoginVerifyCodeKey2;


/// 项目中关于一些简单的业务逻辑验证放在ViewModel的命令中统一处理 NSError
/// eg：假设验证出来不是正确的手机号：
/// [RACSignal error:[NSError errorWithDomain:SUCommandErrorDomain code:SUCommandErrorCode userInfo:@{SUCommandErrorUserInfoKey:@"请输入正确的手机号码"}]];
FOUNDATION_EXTERN NSString * const SUCommandErrorDomain ;
FOUNDATION_EXTERN NSString * const SUCommandErrorUserInfoKey ;
FOUNDATION_EXTERN CGFloat    const SUCommandErrorCode ;



/// 搜索tips
FOUNDATION_EXTERN NSString *const SUSearchTipsText;


/// 首页banner视图的高度
#define SUGoodsBannerViewHeight  ceil((MHMainScreenWidth * 238.0f / 375.0f))


////////////////// MVVM ViewModel Params中的key //////////////////
/// MVVM View
/// The base map of 'params'
/// The `params` parameter in `-initWithParams:` method.
/// Key-Values's key
/// 传递唯一ID的key：例如：商品id 用户id...
FOUNDATION_EXTERN NSString *const SUViewModelIDKey;
/// 传递导航栏title的key：例如 导航栏的title...
FOUNDATION_EXTERN NSString *const SUViewModelTitleKey;
/// 传递数据模型的key：例如 商品模型的传递 用户模型的传递...
FOUNDATION_EXTERN NSString *const SUViewModelUtilKey;
/// 传递webView Request的key：例如 webView request...
FOUNDATION_EXTERN NSString *const SUViewModelRequestKey;










