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
    _ediateImageView.image = _originalImage;
    [_scrollView addSubview:_ediateImageView];
    [self refreshImageView];
    
    self.ediateImageView.userInteractionEnabled = YES;
    self.scrollView.panGestureRecognizer.minimumNumberOfTouches = 1;
    self.scrollView.maximumZoomScale = 100;
    self.scrollView.panGestureRecognizer.delaysTouchesBegan = NO;
    self.scrollView.pinchGestureRecognizer.delaysTouchesBegan = NO;
    
    CGRect gridFrame = [self.scrollView convertRect:_ediateImageView.frame toView:self.view];
    _gridView = [[HQEdiateImageCutView alloc] initWithSuperview:self.view frame:gridFrame];
    _gridView.imageEdiateController = self;
    _gridView.backgroundColor = [UIColor clearColor];
    _gridView.bgColor = [UIColor clearColor];
    _gridView.gridColor = [UIColor whiteColor];
    //[[UIColor whiteColor] colorWithAlphaComponent:0.8];
    _gridView.clipsToBounds = NO;
    [self resetScrollViewContentinsetWith:_gridView.gridLayer.frame];
    [self fixZoomScaleWithAnimated:YES];
}
//底层ScrollView
- (void)initImageScrollView{
    UIScrollView *imageScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(20, 20, App_Frame_Width-40, APP_Frame_Height-20-80)];
    imageScroll.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageScroll.showsHorizontalScrollIndicator = NO;
    imageScroll.showsVerticalScrollIndicator = NO;
    imageScroll.backgroundColor = [UIColor blackColor];
    imageScroll.delegate = self;
    imageScroll.clipsToBounds = NO;
    [self.view insertSubview:imageScroll atIndex:0];
    self.scrollView = imageScroll;
}
- (void)createMenuView{
    _menuView = [[UIView alloc] initWithFrame:CGRectMake(0, APP_Frame_Height-80, self.view.width, 80)];
    _menuView.backgroundColor = [UIColor blackColor];
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
///完成
- (void)confirmButtonAction:(UIButton *)sender{
    [UIView animateWithDuration:0.35 animations:^{
        [self refreshScrollViewToScalCenter:CGPointZero];
        _gridView.clippingRect = _gridView.bounds;
    }];
}
- (void)refreshScrollViewToScalCenter:(CGPoint )center{
    CGFloat wroate = _gridView.width/_gridView.gridLayer.clippingRect.size.width;
    CGFloat hroate = _gridView.height/_gridView.gridLayer.clippingRect.size.height;
    CGFloat raote  = self.scrollView.zoomScale + MIN(wroate, hroate);
    [self.scrollView setZoomScale:raote];
}
- (void)refreshImageView{
    _ediateImageView.image = _originalImage;
    [self resetImageViewFrame];
}
- (void)resetImageViewFrame{
    CGSize size = (_ediateImageView.image) ? _ediateImageView.image.size : _ediateImageView.frame.size;
    if(size.width>0 && size.height>0){
        CGFloat ratio = MIN((App_Frame_Width-40) / size.width, (APP_Frame_Height - 20 - 80) / size.height);
         CGFloat scale = _scrollView.zoomScale;
        CGFloat W = ratio * size.width *scale;
        CGFloat H = ratio * size.height * scale;
        _ediateImageView.frame = CGRectMake(MAX(0, ((App_Frame_Width-40) -W)/2), MAX(0, ((APP_Frame_Height - 20 - 80)-H)/2), W, H);
    }
}
- (void)resetScrollViewContentinsetWith:(CGRect )frame{
    ////刚开始系统默认  scrollView.contentInset的top  是放大视图ediateImageView的top      scrollView.contentInset的tleft 是放大视图ediateImageView的left  bottom 是0 right是0
    
    CGRect newRect = [_gridView convertRect:frame toView:self.scrollView];//newRect.origin.y-20
    self.scrollView.contentInset = UIEdgeInsetsMake(0, newRect.origin.x , self.scrollView.height-newRect.size.height, self.scrollView.width - newRect.size.width - newRect.origin.x);
}
- (void)fixZoomScaleWithAnimated:(BOOL)animated{
    [self.scrollView setZoomScale:1.001 animated:YES];
}
#pragma mark - UIScrollViewDelegate
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _ediateImageView;
}
- (void)refreshImageContainerViewCenter {
    CGFloat offsetX = (_scrollView.width > _scrollView.contentSize.width) ? ((_scrollView.width - _scrollView.contentSize.width) * 0.5) : 0.0;
    CGFloat offsetY = (_scrollView.height > _scrollView.contentSize.height) ? ((_scrollView.height - _scrollView.contentSize.height) * 0.5) : 0.0;
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
