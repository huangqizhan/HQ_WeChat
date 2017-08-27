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
#import "HQCutImageController.h"




@interface HQEdiateImageController (){
}
@property (nonatomic) UIView *topView;
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
    self.view.backgroundColor = [UIColor blackColor];
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
    _ediateImageView= [[UIImageView alloc] init];
    _ediateImageView.clipsToBounds = YES;
    [_scrollView addSubview:_ediateImageView];
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
            self.currentTool = object;
        }
    }
}
//初始化当前工具
- (void)setCurrentTool:(HQEdiateImageBaseTools *)currentTool{
    [_currentTool clearCurrentEdiateStatus];
    _currentTool = currentTool;
    [_scrollView setZoomScale:1.0 animated:YES];
    [_currentTool setUpCurrentEdiateStatus];
}
- (void)hiddenMenuViewWithAnimation{
    [UIView animateWithDuration:.15 animations:^{
        _menuView.top = APP_Frame_Height;
    }];
}
- (void)resetBottomViewEdiateStatus{
    [UIView animateWithDuration:.15 animations:^{
        _menuView.top = APP_Frame_Height - 80;
        [_scrollView setZoomScale:1.0];
    }];
}
- (void)reSetEdiateControllerContentUIFrameWithBottomViewHeight:(CGFloat)bottomViewHeight{
    self.scrollView.height = APP_Frame_Height-bottomViewHeight;
     [self refreshImageView];
}
//底层ScrollView
- (void)initImageScrollView{
    UIScrollView *imageScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, App_Frame_Width, APP_Frame_Height-80-40)];
    imageScroll.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageScroll.showsHorizontalScrollIndicator = NO;
    imageScroll.showsVerticalScrollIndicator = NO;
    imageScroll.backgroundColor = [UIColor blackColor];
    imageScroll.delegate = self;
    imageScroll.clipsToBounds = NO;
    [self.view insertSubview:imageScroll atIndex:0];
    _scrollView = imageScroll;
}
- (void)createNaviGationViews{
    
    _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, 40)];
    _topView.backgroundColor = [UIColor  clearColor];
    [self.view addSubview:_topView];
    
    UIButton *cancelButton  = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 40, 40)];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:cancelButton];
    
    UIButton *finishButton = [[UIButton alloc] initWithFrame:CGRectMake(App_Frame_Width-50, 0, 40, 40)];
    [finishButton setTitle:@"完成" forState:UIControlStateNormal];
    [finishButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [finishButton setTitleColor:CANCELBUTTONCOLOR forState:UIControlStateNormal];
    [finishButton addTarget:self action:@selector(finishButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:finishButton];
    
}
- (void)cancelButtonAction:(UIButton *)sender{
    [self dismissViewControllerAnimated:NO completion:nil];
}
- (void)finishButtonAction:(UIButton *)sender{
    [self.currentTool executeWithCompletionBlock:^(UIImage *image, NSError *error, NSDictionary *userInfo) {
        _originalImage = image;
        [self refreshImageView];
    }];
}
- (void)refreshImageView{
    _ediateImageView.image = _originalImage;
    [self resetImageViewFrame];
    [self resetZoomScaleWithAnimated:NO];
}
- (void)resetImageViewFrame{
    CGSize size = (_ediateImageView.image) ? _ediateImageView.image.size : _ediateImageView.frame.size;
    if(size.width>0 && size.height>0){
        CGFloat ratio = MIN(_scrollView.frame.size.width / size.width, _scrollView.frame.size.height / size.height);
        CGFloat W = ratio * size.width * _scrollView.zoomScale;
        CGFloat H = ratio * size.height * _scrollView.zoomScale;
        _ediateImageView.frame = CGRectMake(MAX(0, (_scrollView.width-W)/2), MAX(0, (_scrollView.height-H)/2), W, H);
    }
}
- (void)resetZoomScaleWithAnimated:(BOOL)animated{
    
    CGFloat Rw = _scrollView.frame.size.width / _ediateImageView.frame.size.width;
    CGFloat Rh = _scrollView.frame.size.height / _ediateImageView.frame.size.height;
    
    //CGFloat scale = [[UIScreen mainScreen] scale];
    CGFloat scale = 1;
    Rw = MAX(Rw, _ediateImageView.image.size.width / (scale * _scrollView.frame.size.width));
    Rh = MAX(Rh, _ediateImageView.image.size.height / (scale * _scrollView.frame.size.height));
    
    _scrollView.contentSize = _ediateImageView.frame.size;
    _scrollView.minimumZoomScale = 1;
    _scrollView.maximumZoomScale = 10;
    
    [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:animated];
}
- (void)refershUIWhenediateCompliteWithNewImage:(UIImage *)newImage{
    _originalImage = newImage;
    _ediateImageView.image = _originalImage;
    [self resetImageViewFrame];
    [self resetZoomScaleWithAnimated:NO];
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
    return _ediateImageView;
}
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    scrollView.contentInset = UIEdgeInsetsZero;
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self refreshImageContainerViewCenter];
}

- (void)refreshImageContainerViewCenter {
    CGFloat offsetX = (_scrollView.tz_width > _scrollView.contentSize.width) ? ((_scrollView.tz_width - _scrollView.contentSize.width) * 0.5) : 0.0;
    CGFloat offsetY = (_scrollView.tz_height > _scrollView.contentSize.height) ? ((_scrollView.tz_height - _scrollView.contentSize.height) * 0.5) : 0.0;
    self.ediateImageView.center = CGPointMake(_scrollView.contentSize.width * 0.5 + offsetX, _scrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark ------- UIViewControllerTransitioningDelegate ------
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    HQEdiateImageControllerEdiateTranstion* animator = [[HQEdiateImageControllerEdiateTranstion alloc] initWithPresenting:YES];
    return animator;
}
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    HQEdiateImageControllerEdiateTranstion* animator = [[HQEdiateImageControllerEdiateTranstion alloc] initWithPresenting:NO];
    return animator;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end





































@implementation HQEdiateImageControllerEdiateTranstion

- (instancetype)initWithPresenting:(BOOL)presenting{
    self = [super init];
    if (self) {
    }
    self.presenting = presenting;
    return self;
}
// 返回动画时长
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.35;
}
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (self.presenting) {
        [self presentingAnimation:transitionContext];
    }
    else {
        [self dismissingAnimation:transitionContext];
    }
}
// present视图控制器的自定义动画(modal出视图控制器)
- (void)presentingAnimation:(id<UIViewControllerContextTransitioning>)transitionContext {
    // 通过字符串常量Key从转场上下文种获得相应的对象
    UIView *containerView = [transitionContext containerView];
    HQEdiateImageController *fromVC = (HQEdiateImageController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *fromView = fromVC.view;
    
    HQCutImageController *toVC = (HQCutImageController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = toVC.view;
    
    // 要将toView添加到容器视图中
    [containerView addSubview:toView];
    toView.transform = CGAffineTransformIdentity;
    toView.alpha = 0;
    fromView.alpha = 1;
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
    } completion:^(BOOL finished) {
        BOOL success = ![transitionContext transitionWasCancelled];
        [UIView animateWithDuration:.35 animations:^{
            toView.alpha = 1;
            fromView.alpha = 0;
        } completion:^(BOOL finished) {
            // 注意:这边一定要调用这句否则UIKit会一直等待动画完成
            [transitionContext completeTransition:success];
        }];
    }];
}
// dissmiss视图控制器的自定义动画(关闭modal视图控制器)
- (void)dismissingAnimation:(id<UIViewControllerContextTransitioning>)transitionContext {
    // 通过字符串常量Key从转场上下文种获得相应的对象
    UIView *containerView = [transitionContext containerView];
    HQCutImageController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *fromView = fromVC.view;
    //[transitionContext viewForKey:UITransitionContextFromViewKey];
    HQEdiateImageController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = toVC.view;
    //    [transitionContext viewForKey:UITransitionContextToViewKey];
    // 先把原来的视图添加回去
    [containerView insertSubview:toView atIndex:0];
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        //        fromView.transform = CGAffineTransformMakeScale(1.0, 0.001);
        toView.transform = CGAffineTransformIdentity;
        //sy这边不能直接设置成0,否则看不出动画效果
    } completion:^(BOOL finished){
        [UIView animateWithDuration:.35 animations:^{
            toView.alpha = 1.0;
            fromView.alpha = 0.0;
        }completion:^(BOOL finished) {
            BOOL success = ![transitionContext transitionWasCancelled];
            // 注意要把视图移除
            [fromView removeFromSuperview];
            // 注意:这边一定要调用这句否则UIKit会一直等待动画完成
            [transitionContext completeTransition:success];
        }];
    }];
}


@end
