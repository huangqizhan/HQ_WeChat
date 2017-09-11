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

#define kLLTextColor_green [UIColor colorWithRed:29/255.0 green:185/255.0 blue:14/255.0 alpha:1]


@import WebKit;

@interface HQWebViewController () <WKNavigationDelegate>

@property (nonatomic) WKWebView *webView;
@property (nonatomic) HQWebProcessView *webProgressView;

@end

@implementation HQWebViewController{
    UIBarButtonItem *backBarButtonItem;
    BOOL translucent;
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


/*
 注意 ： callHandle 是oc或者js调对方的函数  前提是 对方必须先注册该方法名  
 
 */
