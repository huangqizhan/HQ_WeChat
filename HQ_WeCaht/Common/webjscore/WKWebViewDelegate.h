//
//  WKWebViewDelegate.h
//  HQ_WeChat
//
//  Created by 黄麒展 on 2018/1/19.
//  Copyright © 2018年 黄麒展. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@class WKWebViewDelegate;

@protocol  WKUserDelegate <NSObject>

@optional

////注入的JS回调
- (void)WKUserDelegate:(WKWebViewDelegate *)wkDelegate userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message;

///保存图片
- (void)WKUserDelegate:(WKWebViewDelegate *)wkDeleaget saveImg:(UIImage *)image;

///识别出的二维码
- (void)WKWebViewDelegate:(WKWebViewDelegate *)wkDelegate codeImage:(UIImage *)image codeStr:(NSString *)string;


@end


@interface WKWebViewDelegate : NSObject<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithDelegate:(UIViewController <WKUserDelegate> *)delegate webView:(WKWebView *)webView NS_DESIGNATED_INITIALIZER;




@end
