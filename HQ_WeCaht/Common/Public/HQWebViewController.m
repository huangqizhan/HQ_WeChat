//
//  HQWebViewController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/22.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQWebViewController.h"
#import "HQWebProcessView.h"
#import "HQWebJsManager.h"
#import "WKWebView+Ad.h"

#define kLLTextColor_green [UIColor colorWithRed:29/255.0 green:185/255.0 blue:14/255.0 alpha:1]


@import WebKit;

@interface HQWebViewController () <WKNavigationDelegate,WKScriptMessageHandler>{
    UIBarButtonItem *backBarButtonItem;
    BOOL translucent;
}

@property (nonatomic) WKWebView *webView;
@property (nonatomic) HQWebProcessView *webProgressView;

@end

@implementation HQWebViewController{

}
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    translucent = self.navigationController.navigationBar.translucent;
    self.navigationController.navigationBar.translucent = NO;
    //    backBarButtonItem = self.fromViewController.navigationItem.backBarButtonItem;
    //    self.fromViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:nil action:nil];
    
    UIButton *popBut = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [popBut setTitle:@"cle" forState:UIControlStateNormal];
    [popBut addTarget:self action:@selector(clearButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:popBut];

}
- (void)clearButtonAction:(UIButton *)sender{
    [WKWebView cleanCacheAndCookie];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.translucent = translucent;
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //    self.fromViewController.navigationItem.backBarButtonItem = backBarButtonItem;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    
    // 设置偏好设置
    config.preferences = [[WKPreferences alloc] init];
    // 默认为0
    config.preferences.minimumFontSize = 10;
    // 默认认为YES
    config.preferences.javaScriptEnabled = YES;
    // 在iOS上默认为NO，表示不能自动通过窗口打开
    config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    
    // web内容处理池
    config.processPool = [[WKProcessPool alloc] init];
    
    // 通过JS与webview内容交互
    config.userContentController = [[WKUserContentController alloc] init];
    // 注入JS对象名称AppModel，当JS通过AppModel来调用时，
    // 我们可以在WKScriptMessageHandler代理中接收到
    [config.userContentController addScriptMessageHandler:self name:@"AppModel"];

    
    
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    self.webView.navigationDelegate = self;
//    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
//    self.webView.scrollView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.9];
    self.webView.scrollView.backgroundColor = UIColorRGB(45, 49, 50);
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.allowsBackForwardNavigationGestures = YES;
    [self.view addSubview:self.webView];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    [self.webView loadRequest:request];
    [self.webView setNeedsUpdateConstraints];
    [[HQWebJsManager shareInstanceJSManager] registerJsHandlsWithWkWebVieW:self.webView];
    [[HQWebJsManager shareInstanceJSManager].bridge setWebViewDelegate:self];
    CGFloat progressBarHeight = 2.f;
    _webProgressView = [[HQWebProcessView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, progressBarHeight)];
    _webProgressView.progressBarColor = kLLTextColor_green;
    _webProgressView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_webProgressView];
    
    [self addObservers];
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
///屏幕旋转
- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
- (void)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - 加载进度 -

- (void)addObservers {
    [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    [_webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    [_webView.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
}
- (void)dealloc {
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [_webView removeObserver:self forKeyPath:@"title"];
    [_webView.scrollView removeObserver:self forKeyPath:@"contentSize"];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        if (object == self.webView) {
            [self.webProgressView setProgress:self.webView.estimatedProgress animated:YES];
        }else {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }else if ([keyPath isEqualToString:@"title"]) {
        if (object == self.webView) {
            self.title = self.webView.title;
        }else{
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }else if ([keyPath isEqualToString:@"contentSize"]){
        if (object == self.webView.scrollView) {
//            self.scrollView.contentSize = self.webView.scrollView.contentSize;
        }else {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
#pragma mark ---------- WKNavigationDelegate ---------
///页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self.webProgressView setProgress:0 animated:YES];
    NSLog(@"didStartProvisionalNavigation");
}
/// 页面加载完毕时调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"didFinishNavigation");
}
///跳转失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"didFailProvisionalNavigation");
}
///请求之前，决定是否要跳转:用户点击网页上的链接，需要打开新页面时，将先调用这个方法。
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSLog(@"decidePolicyForNavigationAction");
    decisionHandler(WKNavigationActionPolicyAllow);
    
    /*
     WKNavigationTypeLinkActivated 链接的href属性被用户激活。
     WKNavigationTypeFormSubmitted 一个表单提交。
     WKNavigationTypeBackForward 回到前面的条目列表请求。
     WKNavigationTypeReload 网页加载。
     WKNavigationTypeFormResubmitted 一个表单提交(例如通过前进,后退,或重新加载)。
     WKNavigationTypeOther 导航是发生一些其他原因。

     
     // 不允许web内跳转
     WKNavigationActionPolicyCancel,
     WKNavigationActionPolicyAllow,
     
     
     */
}
////接收到相应数据后，决定是否跳转
//- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
//    NSLog(@"decidePolicyForNavigationResponse");
//    if (!navigationResponse.isForMainFrame){
//        decisionHandler(WKNavigationResponsePolicyCancel);
//    }else{
//        decisionHandler(WKNavigationResponsePolicyAllow);
//    }
//    NSLog(@"2");
//    /*
//
//     */
//    /*
//     if (navigationAction.navigationType == WKNavigationTypeLinkActivated){
//     decisionHandler(WKNavigationActionPolicyCancel);
//     }else{
//     decisionHandler(WKNavigationActionPolicyAllow);
//     }
//     */
//}
//// 主机地址被重定向时调用
//- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
//    NSLog(@"didReceiveServerRedirectForProvisionalNavigation");
//}
//// 当内容开始返回时调用
//- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation{
//    NSLog(@"didCommitNavigation");
//}
//// 如果需要证书验证，与使用AFN进行HTTPS证书验证是一样的
//- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *__nullable credential))completionHandler{
//    NSLog(@"didReceiveAuthenticationChallenge");
//}
////9.0才能使用，web内容处理中断时会触发
//- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView{
//    NSLog(@"webViewWebContentProcessDidTerminate");
//}
/*
 */

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"AppModel"]) {
        // 打印所传过来的参数，只支持NSNumber, NSString, NSDate, NSArray,NSDictionary, and NSNull类型
        NSLog(@"接收到JS端信息：%@", message.body);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


/*
 注意 ： callHandle 是oc或者js调对方的函数  前提是 对方必须先注册该方法名  
 
 */
