//
//  HQCutImageController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/8/14.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQCutImageController.h"
#import "HQEdiateImageCutView.h"
#import "UIImage+Resize.h"



#define COVERVIEWCOLOR  [UIColor colorWithRed:0 green:00 blue:0 alpha:0.6]

@interface HQCutImageController () <UIScrollViewDelegate,HQCutCircleViewPanGestureDelegate>{
    CGRect _originalRect;
}

@property (nonatomic) UIImageView *ediateImageView;

@property (nonatomic) UIView *menuView;
@property (nonatomic) UIButton *cancelButton;
@property (nonatomic) UIButton *rotateButton;
@property (nonatomic) UIButton *reBackButton;
@property (nonatomic) UIButton *confirmButton;
@property (nonatomic) UIView *topCoverView;
@property (nonatomic) CoverView *leftCoverView;
@property (nonatomic) CoverView *bottomCoverView;
@property (nonatomic) CoverView *rightCoverView;
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
    [self creatCoverViewWhenCutFinish];
    
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
    _originalRect =  gridFrame;
    _gridView = [[HQEdiateImageCutView alloc] initWithSuperview:self.view frame:gridFrame];
    _gridView.imageEdiateController = self;
    _gridView.delegate = self;
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

    _reBackButton = [[UIButton alloc] initWithFrame:CGRectMake(App_Frame_Width/2.0-20, 20, 40, 40)];
    [_reBackButton setImage:[UIImage imageNamed:@"EditImageRevokeDisable_21x21_"] forState:UIControlStateNormal];
    [_reBackButton addTarget:self action:@selector(rebackButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_menuView  addSubview:_reBackButton];

    _confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(App_Frame_Width-60, 20, 40, 40)];
    [_confirmButton setImage:[UIImage imageNamed:@"EdiateImageConfirm"] forState:UIControlStateNormal];
    [_confirmButton addTarget:self action:@selector(confirmButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_menuView addSubview:_confirmButton];
}
- (void)creatCoverViewWhenCutFinish{
    
    _topCoverView = [[CoverView alloc] init];
    _topCoverView.backgroundColor = COVERVIEWCOLOR;
    [self.view addSubview:_topCoverView];
    
    _leftCoverView = [[CoverView alloc] init];
    _leftCoverView.backgroundColor = COVERVIEWCOLOR;
    [self.view addSubview:_leftCoverView];
    
    _bottomCoverView = [[CoverView alloc] init];
    _bottomCoverView.backgroundColor = COVERVIEWCOLOR;
    [self.view addSubview:_bottomCoverView];
    
    
    _rightCoverView = [[CoverView alloc] init];
    _rightCoverView.backgroundColor = COVERVIEWCOLOR;
    [self.view addSubview:_rightCoverView];
}
- (void)refreshCoverViewsSizes{
    CGRect cutRect = [_gridView.layer convertRect:_gridView.gridLayer.clippingRect toLayer:self.view.layer];
    [UIView animateWithDuration:.002 animations:^{
        _topCoverView.hidden = NO;
        _leftCoverView.hidden = NO;
        _bottomCoverView.hidden = NO;
        _rightCoverView.hidden = NO;
        _topCoverView.frame = CGRectMake(0, 0, App_Frame_Width, cutRect.origin.y);
        _leftCoverView.frame = CGRectMake(0, cutRect.origin.y, cutRect.origin.x, cutRect.size.height);
        _bottomCoverView.frame = CGRectMake(0, cutRect.origin.y + cutRect.size.height, App_Frame_Width, APP_Frame_Height-80-cutRect.origin.y + cutRect.size.height);
        _rightCoverView.frame = CGRectMake( cutRect.origin.x + cutRect.size.width , cutRect.origin.y, App_Frame_Width-cutRect.origin.x - cutRect.size.width, cutRect.size.height);
    }];
}
- (void)hiddenCoverViews{
    [UIView animateWithDuration:0.2 animations:^{
        _topCoverView.hidden = YES;
        _leftCoverView.hidden = YES;
        _bottomCoverView.hidden = YES;
        _rightCoverView.hidden = YES;
    }];
}
///取消
- (void)clearDrawViewButtonAction:(UIButton *)sender{
    if (_endEdiateImageCallBack) {
        _endEdiateImageCallBack();
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
///旋转
- (void)roateButtonAction:(UIButton *)sender{
    float centerX = _gridView.gridLayer.clippingRect.size.width/2.0;
    float centerY = _gridView.gridLayer.clippingRect.size.height/2.0;
    CGPoint centerPoint = [_gridView.gridLayer convertPoint:CGPointMake(centerX, centerY) toLayer:self.ediateImageView.layer];
    CGPoint anchorPoint = CGPointMake(centerPoint.x/self.ediateImageView.width, centerPoint.y/self.ediateImageView.height);
    float angle = M_PI/2.0;
    [UIView animateWithDuration:0.25 animations:^{
        self.ediateImageView.layer.anchorPoint = anchorPoint;
        _gridView.gridLayer.anchorPoint = anchorPoint;
        CATransform3D rotatedTransform = self.ediateImageView.layer.transform;
        rotatedTransform = CATransform3DMakeRotation(angle, 0, 0, 1.0);
        self.ediateImageView.layer.transform = rotatedTransform;
        _gridView.gridLayer.transform = rotatedTransform;
    } completion:^(BOOL finished) {
        
    }];
}
////返回上一步
- (void)rebackButtonAction:(UIButton *)sender{
    [self setReBackButtonStatusWith:NO];
    _gridView.clippingRect = CGRectMake(0, 0, _originalRect.size.width, _originalRect.size.height);
    [self.scrollView setZoomScale:1.001 animated:YES];
}
///完成
- (void)confirmButtonAction:(UIButton *)sender{
    ////截取的起始点
    CGPoint p = _gridView.gridLayer.clippingRect.origin;
    ////起始点转化到图片上
    CGPoint originPoint = [_gridView convertPoint:p toView:self.ediateImageView];
    ///提问题没搞清楚     图片放大后 frame 宽高没有改变  乘以 放大比例
    originPoint.x  *= self.scrollView.zoomScale;
    originPoint.y *= self.scrollView.zoomScale;
    ////截取图片的起始点不能超出图片的size 范围
            ///图片放大后的size跟图片的原始size的比例
    CGFloat imageWidthRote = self.ediateImageView.image.size.width/self.ediateImageView.width;
    CGFloat imageHeightRote = self.ediateImageView.image.size.height/self.ediateImageView.height;
    ////生成截取的目标frame
    CGRect targetRect = CGRectMake(originPoint.x*imageWidthRote, originPoint.y*imageHeightRote, _gridView.gridLayer.clippingRect.size.width*imageWidthRote, _gridView.gridLayer.clippingRect.size.height*imageHeightRote);
    ////截取图片  图片截取是按照
    UIImage *img = [self.ediateImageView.image croppedImage:targetRect];
    _ediateCompliteCallBack(img);
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)refreshScrollViewToScaleRect{
    CGFloat origalscale = _gridView.width/_gridView.height;
    CGFloat newscale = _gridView.gridLayer.clippingRect.size.width/_gridView.gridLayer.clippingRect.size.height;
    CGSize newSize ;
    if (newscale > origalscale) {
        newSize.width =   _gridView.width;
        newSize.height = (_gridView.width/_gridView.gridLayer.clippingRect.size.width)*_gridView.gridLayer.clippingRect.size.height;
    }else{
        newSize.height = _gridView.height;
        newSize.width = (_gridView.height/_gridView.gridLayer.clippingRect.size.height)*_gridView.gridLayer.clippingRect.size.width;
    }
    CGRect originalRect = [_gridView convertRect:_gridView.gridLayer.clippingRect toView:self.ediateImageView];
    [self.scrollView zoomToRect:originalRect animated:NO];
    
    CGPoint origalcenter = CGPointMake(_gridView.width/2.0, _gridView.height/2.0);
    CGRect targetRect = CGRectMake(origalcenter.x - newSize.width/2.0, origalcenter.y - newSize.height/2.0, newSize.width, newSize.height);
    _gridView.clippingRect = targetRect;
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
- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    [self setReBackButtonStatusWith:YES];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self refreshCoverViewsSizes];
}
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view{
    [self hiddenCoverViews];
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale{
    [self refreshCoverViewsSizes];
}
- (void)setReBackButtonStatusWith:(BOOL)active{
    [UIView animateKeyframesWithDuration: 0.35 delay: 0 options: 0 animations: ^{
        [UIView addKeyframeWithRelativeStartTime: 0  relativeDuration: 1 / 3.0 animations: ^{
              if (active) {
                  _reBackButton.transform = CGAffineTransformMakeScale(1.5, 1.5);
              }else{
                  _reBackButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
              }
         }];
    } completion: ^(BOOL finished) {
        
    }];
}

#pragma  ------- HQCutCircleViewPanGestureDelegate ------
/**
 切图圆角将要开始拖动
 
 @param ediateView HQEdiateImageCutView
 */
- (void)EdiateImageCutViewWillBeginDrag:(HQEdiateImageCutView *)ediateView{
    [self hiddenCoverViews];
}
/**
 切图圆角已经停止拖动
 @param ediateView HQEdiateImageCutView
 */
- (void)EdiateImageCutViewDidEndDrag:(HQEdiateImageCutView *)ediateView{
    [UIView animateWithDuration:0.35 animations:^{
        [self refreshScrollViewToScaleRect];
    } completion:^(BOOL finished) {
        [self refreshCoverViewsSizes];
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end





@implementation CoverView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    [super hitTest:point withEvent:event];
    return nil;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.nextResponder touchesBegan:touches withEvent:event];
}

@end
