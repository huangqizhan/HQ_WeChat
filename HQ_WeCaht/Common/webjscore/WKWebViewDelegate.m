//
//  WKWebViewDelegate.m
//  HQ_WeChat
//
//  Created by 黄麒展 on 2018/1/19.
//  Copyright © 2018年 黄麒展. All rights reserved.
//

#import "WKWebViewDelegate.h"
#import "HQActionSheet.h"
#import "UIApplication+HQExtern.h"
#import "WKWebView+Add.h"
#import "SDWebImageDownloader.h"
#import "UIImage+Face.h"


@interface  WKWebViewDelegate ()

@property (nonatomic,weak) UIViewController <WKUserDelegate> *delegate;


/**
 WKWebView 不能使用 JavaScriptCore   只能使用MessageHandler 和截取地址
 此处只使用 MessageHandler  
 */
@property (nonatomic,weak) WKWebView *webView;
@property (nonatomic,assign) float ptX;
@property (nonatomic,assign) float ptY;
@property (nonatomic,assign) NSTimeInterval pressTimerval;


@end



@implementation WKWebViewDelegate


- (instancetype)initWithDelegate:(UIViewController <WKUserDelegate> *)delegate webView:(WKWebView *)webView {
    self = [super init];
    if (self) {
        _delegate = delegate;
        _webView = webView;
    }
    return self;
}

#pragma mark - WKNavigationDelegate

// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSString *requestString = navigationAction.request.URL.absoluteString;
    NSString *scheme = [navigationAction.request.URL scheme];
    //自定义协议
    if ([scheme isEqualToString:@"haleyaction"]) {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    NSArray *components = [requestString componentsSeparatedByString:@":"];
    if ([components count] > 1 && [(NSString *)[components objectAtIndex:0]
                                   isEqualToString:@"myweb"]) {
        if([(NSString *)[components objectAtIndex:1] isEqualToString:@"touch"]){
            //NSLog(@"you are touching!");
            if ([(NSString *)[components objectAtIndex:2] isEqualToString:@"start"]){
                _ptX  =[[components objectAtIndex:3]floatValue];
                _ptY =[[components objectAtIndex:4]floatValue];
                _pressTimerval = [[NSDate date] timeIntervalSince1970];
            }else if ([(NSString *)[components objectAtIndex:2] isEqualToString:@"move"]){
                _ptX  =[[components objectAtIndex:3]floatValue];
                _ptY =[[components objectAtIndex:4]floatValue];
            }else if ([(NSString*)[components objectAtIndex:2]isEqualToString:@"end"]) {
                NSString *js = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).tagName", _ptX, _ptY];
                ///这是判断IMG标签名
                WEAKSELF;
                [_webView evaluateJavaScript:js completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                    if ([result isEqualToString:@"IMG"] && ([[NSDate date] timeIntervalSince1970] - _pressTimerval) > 0.5) {
                        NSString *srcjs = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", _ptX, _ptY];
                        [_webView evaluateJavaScript:srcjs completionHandler:^(id _Nullable res, NSError * _Nullable error) {
                            [weakSelf handleImgLongPress:res];
                        }];
                    }
                }];
            }
        }
    }
    ///此处回调必须实现
    decisionHandler(WKNavigationActionPolicyAllow);
}
// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    ///此处回调必须实现
    decisionHandler(WKNavigationResponsePolicyAllow);
    
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"start load");
}
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
}
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation{
}
//
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
     // 不要证书验证
    completionHandler(NSURLSessionAuthChallengeUseCredential, nil);
}
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView{

}

#pragma mark   ------- WKUIDelegate  --------
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    return webView;
}
- (void)webViewDidClose:(WKWebView *)webView {
    
}
////alert 弹窗
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    completionHandler();
}
///Confirm选择框
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
    
}
///TextInput输入框
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler{
    
}
- (BOOL)webView:(WKWebView *)webView shouldPreviewElement:(WKPreviewElementInfo *)elementInfo {
    return YES;
}

- (nullable UIViewController *)webView:(WKWebView *)webView previewingViewControllerForElement:(WKPreviewElementInfo *)elementInfo defaultActions:(NSArray<id <WKPreviewActionItem>> *)previewActions {
    return _delegate;
}
- (void)webView:(WKWebView *)webView commitPreviewingViewController:(UIViewController *)previewingViewController {
    
}


#pragma mark ------ WKScriptMessageHandler -----
- (void)userContentController:(nonnull WKUserContentController *)userContentController didReceiveScriptMessage:(nonnull WKScriptMessage *)message {
    if (_delegate && [_delegate respondsToSelector:@selector(WKUserDelegate:userContentController:didReceiveScriptMessage:)]) {
        [_delegate  WKUserDelegate:self userContentController:userContentController didReceiveScriptMessage:message];
    }
}



#pragma mark -------- HTML 图片长按 事件处理 处理  ---------

- (void)handleImgLongPress:(NSString *)urlStr{
    ///判断URL 是否正确
    WEAKSELF;
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:urlStr] options:SDWebImageDownloaderUseNSURLCache progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        if (image == nil) {
            return ;
        }
        NSString *result = [UIImage detactErCodeWithImage:image];
        [weakSelf showActionSheetWith:result?YES:NO image:image codeStr:result];
    }];
}

- (void)showActionSheetWith:(BOOL)erCode image:(UIImage *)image codeStr:(NSString *)codeStr{
    HQActionSheet *actionSheet = [[HQActionSheet alloc] initWithTitle:nil];
    WEAK_SELF;
    HQActionSheetAction *action = [HQActionSheetAction actionWithTitle:@"保存图片" handler:^(HQActionSheetAction *action) {
        if (_delegate && [_delegate respondsToSelector:@selector(WKUserDelegate:saveImg:)]) {
            [_delegate WKUserDelegate:weakSelf saveImg:image];
        }
    } style:HQActionStyleDefault];
    HQActionSheetAction *action1 = [HQActionSheetAction actionWithTitle:@"识别二维码" handler:^(HQActionSheetAction *action) {
        if (_delegate && [_delegate respondsToSelector:@selector(WKWebViewDelegate:codeImage:codeStr:)]) {
            [_delegate WKWebViewDelegate:self codeImage:image codeStr:codeStr];
        }
    } style:HQActionStyleDefault];
    [actionSheet addAction:action];
    if (erCode) {
        [actionSheet addAction:action1];
    }
    [actionSheet showInWindow:[UIApplication popOverWindow]];

}

@end
