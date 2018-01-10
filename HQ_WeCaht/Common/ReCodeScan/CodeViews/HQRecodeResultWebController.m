//
//  HQRecodeResultWebController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/9/12.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQRecodeResultWebController.h"
#import "HQWebProcessView.h"
#import "HQWebJsManager.h"

@import WebKit;

@interface HQRecodeResultWebController ()<WKNavigationDelegate>{
    UIBarButtonItem *backBarButtonItem;
    BOOL translucent;
}

@property (nonatomic) WKWebView *webView;
@property (nonatomic) HQWebProcessView *webProgressView;


@end

@implementation HQRecodeResultWebController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //得到当前视图控制器中的所有控制器
    NSMutableArray *array = [self.navigationController.viewControllers mutableCopy];
    //把B从里面删除
    [array removeObjectAtIndex:1];
    //把删除后的控制器数组再次赋值
    [self.navigationController setViewControllers:[array copy] animated:YES];
    
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
    _webProgressView.progressBarColor = [UIColor colorWithRed:29/255.0 green:185/255.0 blue:14/255.0 alpha:1];
    _webProgressView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_webProgressView];
    
    [self addObservers];
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
