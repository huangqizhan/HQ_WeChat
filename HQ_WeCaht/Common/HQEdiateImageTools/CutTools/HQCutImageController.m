//
//  HQCutImageController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/8/14.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQCutImageController.h"
#import "HQEdiateImageCutView.h"


@interface HQCutImageController () <UIScrollViewDelegate>

@property (nonatomic) UIImageView *ediateImageView;

@property (nonatomic) UIView *menuView;
@property (nonatomic) UIButton *cancelButton;
@property (nonatomic) UIButton *rotateButton;
@property (nonatomic) UIButton *reBackButton;
@property (nonatomic) UIButton *confirmButton;
@property (nonatomic) HQEdiateImageCutView *gridView;

@end

@implementation HQCutImageController

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
    
    _ediateImageView= [[UIImageView alloc] init];
    [_scrollView addSubview:_ediateImageView];
    [self refreshImageView];
    
    self.ediateImageView.userInteractionEnabled = YES;
    self.scrollView.panGestureRecognizer.minimumNumberOfTouches = 1;
    self.scrollView.maximumZoomScale = 100;
    self.scrollView.panGestureRecognizer.delaysTouchesBegan = NO;
    self.scrollView.pinchGestureRecognizer.delaysTouchesBegan = NO;
    
    _gridView = [[HQEdiateImageCutView alloc] initWithSuperview:self.view frame:_ediateImageView.frame];
    _gridView.imageEdiateController = self;
    _gridView.backgroundColor = [UIColor clearColor];
    _gridView.bgColor = [UIColor clearColor];
    _gridView.gridColor = [UIColor whiteColor];
    //[[UIColor whiteColor] colorWithAlphaComponent:0.8];
    _gridView.clipsToBounds = NO;
//    [self resetScrollViewContentinsetWith:_gridView.frame];
    [self fixZoomScaleWithAnimated:YES];
}
//底层ScrollView
- (void)initImageScrollView{
    UIScrollView *imageScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 20, App_Frame_Width, APP_Frame_Height-20-80)];
    imageScroll.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageScroll.showsHorizontalScrollIndicator = NO;
    imageScroll.showsVerticalScrollIndicator = NO;
    imageScroll.backgroundColor = [UIColor redColor];
    imageScroll.delegate = self;
    imageScroll.clipsToBounds = NO;
    [self.view insertSubview:imageScroll atIndex:0];
    _scrollView = imageScroll;
}
- (void)createMenuView{
    
    _menuView = [[UIView alloc] initWithFrame:CGRectMake(0, APP_Frame_Height-80, self.view.width, 80) ];
    _menuView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:_menuView];
    
    _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 40, 40)];
    [_cancelButton setImage:[UIImage imageNamed:@"EdiateImageDismissBut"] forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(clearDrawViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_menuView addSubview:_cancelButton];

    _rotateButton = [[UIButton alloc] initWithFrame:CGRectMake(App_Frame_Width/4.0, 20, 40, 40)];
    [_rotateButton setImage:[UIImage imageNamed:@"EdiateImageRotaio"] forState:UIControlStateNormal];
    [_rotateButton addTarget:self action:@selector(roateButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_menuView addSubview:_rotateButton];

    _reBackButton = [[UIButton alloc] initWithFrame:CGRectMake(App_Frame_Width/2.0+20, 20, 40, 40)];
    [_reBackButton setImage:[UIImage imageNamed:@"EditImageRevokeDisable_21x21_"] forState:UIControlStateNormal];
    [_reBackButton addTarget:self action:@selector(rebackButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_menuView  addSubview:_reBackButton];

    _confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(App_Frame_Width-60, 20, 40, 40)];
    [_confirmButton setImage:[UIImage imageNamed:@"EdiateImageConfirm"] forState:UIControlStateNormal];
    [_confirmButton addTarget:self action:@selector(confirmButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_menuView addSubview:_confirmButton];
    
}
///取消
- (void)clearDrawViewButtonAction:(UIButton *)sender{
    [self dismissViewControllerAnimated:NO completion:nil];
}
///旋转
- (void)roateButtonAction:(UIButton *)sender{
    
}
////返回上一步
- (void)rebackButtonAction:(UIButton *)sender{
    
}
- (void)confirmButtonAction:(UIButton *)sender{
    
}
- (void)refreshImageView{
    _ediateImageView.image = _originalImage;
    [self resetImageViewFrame];
    [self resetZoomScaleWithAnimated:YES];
}
- (void)resetImageViewFrame{
    CGSize size = (_ediateImageView.image) ? _ediateImageView.image.size : _ediateImageView.frame.size;
    if(size.width>0 && size.height>0){
        CGFloat ratio = MIN(App_Frame_Width / size.width, (APP_Frame_Height - 20 - 120) / size.height);
         CGFloat scale = _scrollView.zoomScale;
        CGFloat W = ratio * size.width *scale;
        CGFloat H = ratio * size.height * scale;
        _ediateImageView.frame = CGRectMake(MAX(0, (App_Frame_Width-W)/2), MAX(20, ((APP_Frame_Height - 20 - 120)-H)/2), W, H);;
    }
}
- (void)resetScrollViewContentinsetWith:(CGRect )frame{
    CGRect newRect = [_gridView convertRect:frame toView:self.view];
    _scrollView.contentInset = UIEdgeInsetsMake(newRect.origin.y-20, newRect.origin.x ,_scrollView.height - newRect.size.height - newRect.origin.y + 20 , _scrollView.width - newRect.size.width - newRect.origin.x);
}
- (void)resetZoomScaleWithAnimated:(BOOL)animated{
    CGFloat Rw = _scrollView.frame.size.width / _ediateImageView.frame.size.width;
    CGFloat Rh = _scrollView.frame.size.height / _ediateImageView.frame.size.height;
    CGFloat scale = 1;
    Rw = MAX(Rw, _ediateImageView.image.size.width / (scale * _scrollView.frame.size.width));
    Rh = MAX(Rh, _ediateImageView.image.size.height / (scale * _scrollView.frame.size.height));
    _scrollView.contentSize = _ediateImageView.frame.size;
    _scrollView.minimumZoomScale = 1;
    _scrollView.maximumZoomScale = MAX(MAX(Rw, Rh), 1);
//    [_scrollView setZoomScale:1.01 animated:animated];
}

- (void)fixZoomScaleWithAnimated:(BOOL)animated{
    CGFloat minZoomScale = _scrollView.minimumZoomScale;
//    _scrollView.maximumZoomScale = 0.95*minZoomScale;
//    _scrollView.minimumZoomScale = 0.95*minZoomScale;
    [_scrollView setZoomScale:0.5*minZoomScale animated:animated];
}
#pragma mark - UIScrollViewDelegate
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _ediateImageView;
}
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
//    scrollView.contentInset = UIEdgeInsetsZero;
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self refreshImageContainerViewCenter];
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
//    [self refreshScrollViewContentSize];
}
#pragma mark ----------- Private -------------
- (void)refreshScrollViewContentSize {
    
}
- (void)refreshImageContainerViewCenter {
    CGFloat offsetX = (_scrollView.tz_width > _scrollView.contentSize.width) ? ((_scrollView.tz_width - _scrollView.contentSize.width) * 0.5) : 0.0;
    CGFloat offsetY = (_scrollView.tz_height > _scrollView.contentSize.height) ? ((_scrollView.tz_height - _scrollView.contentSize.height) * 0.5) : 0.0;
    self.ediateImageView.center = CGPointMake(_scrollView.contentSize.width * 0.5 + offsetX, _scrollView.contentSize.height * 0.5 + offsetY);
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
