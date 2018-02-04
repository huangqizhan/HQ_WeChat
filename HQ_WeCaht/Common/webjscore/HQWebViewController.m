//
//  HQWebViewController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/22.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQWebViewController.h"
#import "HQWebProcessView.h"
#import "WKWebView+Add.h"
#import "HQURLProticol.h"
#import "WKWebViewDelegate.h"
#import "UIImage+Resize.h"


#define kLLTextColor_green [UIColor colorWithRed:29/255.0 green:185/255.0 blue:14/255.0 alpha:1]


@import WebKit;

@interface HQWebViewController () <WKNavigationDelegate,/*,WKScriptMessageHandler,*/WKUserDelegate>{
    UIBarButtonItem *backBarButtonItem;
    BOOL translucent;
}

@property (nonatomic,strong) WKWebView *webView;
@property (nonatomic,strong) HQWebProcessView *webProgressView;
@property (nonatomic,strong) WKWebViewDelegate *webViewDelegate;

@end

@implementation HQWebViewController



- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    [NSURLProtocol unregisterClass:[HQURLProticol class]];
    self.navigationController.navigationBar.translucent = translucent;
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

    
//    UIButton *But = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
//    [But setTitle:@"cle" forState:UIControlStateNormal];
//    [But addTarget:self action:@selector(jsAction:) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:But];
}
- (void)clearButtonAction:(UIButton *)sender{
    [WKWebView cleanCacheAndCookie];
}
- (void)jsAction:(UIButton *)sender{
//    self.jscontext = [[JSContext alloc] init];
////    NSString *js = @"function addAction(a,b) {return a+b}";
//    [self.jscontext[@""] callWithArguments:@[]];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //    self.fromViewController.navigationItem.backBarButtonItem = backBarButtonItem;
}


- (void)viewDidLoad {
    [super viewDidLoad];
//    [NSURLProtocol registerClass:[HQURLProticol class]];
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

  self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    _webViewDelegate = [[WKWebViewDelegate alloc] initWithDelegate:self webView:_webView];
    _webView.allowsLinkPreview = NO;

    
    
//    // 注入JS (function)对象名称AppModel，当JS通过AppModel来调用时，
//    // 我们可以在WKScriptMessageHandler代理中接收到
//    [config.userContentController addScriptMessageHandler:_webViewDelegate name:@"Share"];
    [_webView addJavaScriptMessageHandlerWithDelegate:_webViewDelegate];

    [_webView addCustomerJavaScriptWith:config.userContentController];
    _webView.navigationDelegate = _webViewDelegate;
    self.webView.UIDelegate = _webViewDelegate;
    self.webView.scrollView.backgroundColor = UIColorRGB(45, 49, 50);
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.allowsBackForwardNavigationGestures = YES;
    [self.view addSubview:self.webView];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    [self.webView loadRequest:request];
    [self.webView setNeedsUpdateConstraints];
    CGFloat progressBarHeight = 2.f;
    _webProgressView = [[HQWebProcessView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, progressBarHeight)];
    _webProgressView.progressBarColor = kLLTextColor_green;
    _webProgressView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_webProgressView];
    
    [self addObservers];
}
//- (UIStatusBarStyle)preferredStatusBarStyle {
//    return UIStatusBarStyleLightContent;
//}
/////屏幕旋转
//- (BOOL)shouldAutorotate {
//    return YES;
//}

//- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskAllButUpsideDown;
//}
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
    [_webView.configuration.userContentController removeAllUserScripts];
    [_webView removeAllJavaScriptMessageHandler];
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
            
        }else {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
#pragma mark - WKScriptMessageHandler
- (void)WKUserDelegate:(WKWebViewDelegate *)wkDelegate userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{

    if ([message.name isEqualToString:LOCAIOTNACTION]) {
        NSLog(@"接收到JS端信息：%@", message.body);
        NSString *jsStr = [NSString stringWithFormat:@"shareResult(%d,%d,%d)",1,2,3];
        [_webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            NSLog(@"%@----%@",result, error);
        }];
    }else if ([message.name isEqualToString:SCANACTION]){
        
    }else if ([message.name isEqualToString:SHAKEACTION]){
        
    }
}

/*
 接收到JS端信息：{
 action = shareResult;
 content = "\U6d4b\U8bd5\U5206\U4eab\U7684\U5185\U5bb9";
 title = "\U6d4b\U8bd5\U5206\U4eab\U7684\U6807\U9898";
 url = "http://www.baidu.com";
 }
 
 
 js端出发js互调方法
 function payClick(){
  window.webkit.messageHandlers.locationAction.postMessage({title:'测试分享的标题',content:'测试分享的内容',url:'http://www.baidu.com', action:'shareResult'});
 }
 
 js 端 接受方法
 function shareResult(a,b,c){
 document.getElementById("returnValue").value = a+b+c;
 return a+b+c;
 }
 
 
 */
///保存图片
- (void)WKUserDelegate:(WKWebViewDelegate *)wkDeleaget saveImg:(UIImage *)image{
    [UIImage saveImageToPhotoAlbum:image];//存至本机
}
///识别出的二维码
- (void)WKWebViewDelegate:(WKWebViewDelegate *)wkDelegate codeImage:(UIImage *)image codeStr:(NSString *)string{
    NSLog(@"str =  %@",string);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end



