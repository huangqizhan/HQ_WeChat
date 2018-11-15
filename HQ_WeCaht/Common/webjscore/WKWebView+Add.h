//
//  WKWebView+Add.h
//  HQ_WeChat
//
//  Created by 黄麒展  QQ 757618403 on 2018/1/19.
//  Copyright © 2018年 黄麒展  QQ 757618403. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface WKWebView (Add)

/**
 清楚webview缓存
 */
+ (void)cleanCacheAndCookie;



/**
 给WebView注入JS code

 @param userController userController
 */
- (void)addCustomerJavaScriptWith:(WKUserContentController *)userController;



/**
 添加JS互调方法

 @param delegate 签了 WKScriptMessageHandler  的 obj  
 */
- (void)addJavaScriptMessageHandlerWithDelegate:(id)delegate;

/**
 移除所有的js互调方法
 */
- (void)removeAllJavaScriptMessageHandler;

@end


