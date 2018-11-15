//
//  JSWebViewController.m
//  HQ_WeChat
//
//  Created by 黄麒展  QQ 757618403 on 2018/1/24.
//  Copyright © 2018年 黄麒展  QQ 757618403. All rights reserved.
//

#import "JSWebViewController.h"
#import "WKWebViewJavascriptBridge.h"



@interface JSWebViewController ()<WKNavigationDelegate>{
    
    WKWebViewJavascriptBridge *_brige;
}
@property (nonatomic,strong) WKWebView *webView;

@end

@implementation JSWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    
    // 设置偏好设置
    config.preferences = [[WKPreferences alloc] init];
    //     默认认为YES
    config.preferences.javaScriptEnabled = YES;
    // 在iOS上默认为NO，表示不能自动通过窗口打开
    config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    
    // web内容处理池
    config.processPool = [[WKProcessPool alloc] init];
    
    // 通过JS与webview内容交互
    config.userContentController = [[WKUserContentController alloc] init];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 600) configuration:config];
    _webView.allowsLinkPreview = NO;
    
    
    _webView.navigationDelegate = self;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.allowsBackForwardNavigationGestures = YES;
    [self.view addSubview:self.webView];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"ExampleApp" withExtension:@"html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    
    
    UIButton *popBut = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, 40, 40)];
    [popBut setTitle:@"cle" forState:UIControlStateNormal];
    popBut.backgroundColor = [UIColor blackColor];
    [popBut addTarget:self action:@selector(clearButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:popBut];
    
    UIButton *callBut = [[UIButton alloc] initWithFrame:CGRectMake(120, 20, 40, 40)];
    [callBut setTitle:@"call" forState:UIControlStateNormal];
    callBut.backgroundColor = [UIColor blackColor];
    [callBut addTarget:self action:@selector(callButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:callBut];
    
    
    _brige = [WKWebViewJavascriptBridge bridgeForWebView:self.webView];
    [_brige registerHandler:@"loginAction" handler:^(id data, WVJBResponseCallback responseCallback) {
        responseCallback(@{@"1":@"2"});
    }];
}
- (void)callButtonAction:(UIButton *)sender{
    [_brige callHandler:@"registerAction" data:@{@"num":@"123"} responseCallback:^(id responseData) {
        NSLog(@"responseData = %@",responseData);
    }];
}
- (void)clearButtonAction:(UIButton *)sneder{
    [self cleanCacheAndCookie];
}
- (void)cleanCacheAndCookie{
    //清除cookies
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]){
        [storage deleteCookie:cookie];
    }
    //清除UIWebView的缓存
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
    
    NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
    
    //// Date from
    
    NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
    
    //// Execute
    
    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
    }];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    
}


- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation{
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
