//
//  HQEdiateImageController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/25.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQEdiateImageController.h"
#import "HQEdiateBottomView.h"
#import "HQEdiateImageBaseTools.h"
#import "HQEdiateToolInfo.h"




@interface HQEdiateImageController ()

@property (nonatomic,strong) HQEdiateImageBaseTools *currentTool;

@end

@implementation HQEdiateImageController

- (instancetype)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = YES;
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.clipsToBounds = YES;
    if([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]){
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]){
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    [self initImageScrollView];
    [self createMenuView];
    [self createNaviGationViews];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"IMG_0373" ofType:@".jpg"];
    _originalImage = [UIImage imageWithContentsOfFile:filePath];
    
    _imageView = [[UIImageView alloc] init];
    [_scrollView addSubview:_imageView];
    [self refreshImageView];
}
- (void)createMenuView{
    WEAKSELF;
    _menuView = [[HQEdiateBottomView alloc] initWithFrame:CGRectMake(0, APP_Frame_Height - 80, self.view.width, 80) andClickButtonIndex:^(HQEdiateToolInfo *toolInfo) {
        [weakSelf  clickBottomViewWith:toolInfo];
    }];
    [self.view addSubview:_menuView];
}
#pragma mark ------- 切换底部视图按钮 -----
- (void)clickBottomViewWith:(HQEdiateToolInfo *)toolInfo{
    [self hiddenMenuViewWithAnimation];
    Class toolClass = NSClassFromString(toolInfo.toolName);
    if (toolClass) {
        id object = [toolClass alloc];
        if (object && [object isKindOfClass:[HQEdiateImageBaseTools class] ]) {
            object = [object initWithEdiateController:self andEdiateToolInfo:toolInfo];
            [object setUpCurrentEdiateStatus];
            self.currentTool = object;
        }
    }
}
- (void)hiddenMenuViewWithAnimation{
    [UIView animateWithDuration:.15 animations:^{
        _menuView.top = APP_Frame_Height;
    }];
}
//底层ScrollView
- (void)initImageScrollView{
    UIScrollView *imageScroll = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    imageScroll.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageScroll.showsHorizontalScrollIndicator = NO;
    imageScroll.showsVerticalScrollIndicator = NO;
    imageScroll.backgroundColor = [UIColor blackColor];
    imageScroll.delegate = self;
    imageScroll.clipsToBounds = NO;
//    CGFloat y = self.navigationController.navigationBar.bottom;
    imageScroll.top =  0;
    imageScroll.height = APP_Frame_Height ;
    [self.view insertSubview:imageScroll atIndex:0];
    
    _scrollView = imageScroll;
}
- (void)createNaviGationViews{
    UIButton *cancelButton  = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
    
    UIButton *finishButton = [[UIButton alloc] initWithFrame:CGRectMake(App_Frame_Width-50, 10, 40, 40)];
    [finishButton setTitle:@"完成" forState:UIControlStateNormal];
    [finishButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [finishButton setTitleColor:CANCELBUTTONCOLOR forState:UIControlStateNormal];
    [finishButton addTarget:self action:@selector(finishButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:finishButton];
    
}
- (void)cancelButtonAction:(UIButton *)sender{
    [self dismissViewControllerAnimated:NO completion:nil];
}
- (void)finishButtonAction:(UIButton *)sender{
    
}
- (void)refreshImageView{
    _imageView.image = _originalImage;
    [self resetImageViewFrame];
    [self resetZoomScaleWithAnimated:NO];
}
- (void)resetImageViewFrame{
    CGSize size = (_imageView.image) ? _imageView.image.size : _imageView.frame.size;
    if(size.width>0 && size.height>0){
        CGFloat ratio = MIN(_scrollView.frame.size.width / size.width, _scrollView.frame.size.height / size.height);
        CGFloat W = ratio * size.width * _scrollView.zoomScale;
        CGFloat H = ratio * size.height * _scrollView.zoomScale;
        _imageView.frame = CGRectMake(MAX(0, (_scrollView.width-W)/2), MAX(0, (_scrollView.height-H)/2), W, H);
    }
}
- (void)resetZoomScaleWithAnimated:(BOOL)animated{
    
    CGFloat Rw = _scrollView.frame.size.width / _imageView.frame.size.width;
    CGFloat Rh = _scrollView.frame.size.height / _imageView.frame.size.height;
    
    //CGFloat scale = [[UIScreen mainScreen] scale];
    CGFloat scale = 1;
    Rw = MAX(Rw, _imageView.image.size.width / (scale * _scrollView.frame.size.width));
    Rh = MAX(Rh, _imageView.image.size.height / (scale * _scrollView.frame.size.height));
    
    _scrollView.contentSize = _imageView.frame.size;
    _scrollView.minimumZoomScale = 1;
    _scrollView.maximumZoomScale = MAX(MAX(Rw, Rh), 1);
    
    [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:animated];
}
#pragma mark- ScrollView delegate
- (void)fixZoomScaleWithAnimated:(BOOL)animated{
    CGFloat minZoomScale = _scrollView.minimumZoomScale;
    _scrollView.maximumZoomScale = 0.95*minZoomScale;
    _scrollView.minimumZoomScale = 0.95*minZoomScale;
    [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:animated];
}
#pragma mark - UIScrollViewDelegate
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    scrollView.contentInset = UIEdgeInsetsZero;
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self refreshImageContainerViewCenter];
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    [self refreshScrollViewContentSize];
}
#pragma mark ----------- Private -------------
- (void)refreshScrollViewContentSize {
    
}
- (void)refreshImageContainerViewCenter {
    CGFloat offsetX = (_scrollView.tz_width > _scrollView.contentSize.width) ? ((_scrollView.tz_width - _scrollView.contentSize.width) * 0.5) : 0.0;
    CGFloat offsetY = (_scrollView.tz_height > _scrollView.contentSize.height) ? ((_scrollView.tz_height - _scrollView.contentSize.height) * 0.5) : 0.0;
    self.imageView.center = CGPointMake(_scrollView.contentSize.width * 0.5 + offsetX, _scrollView.contentSize.height * 0.5 + offsetY);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
