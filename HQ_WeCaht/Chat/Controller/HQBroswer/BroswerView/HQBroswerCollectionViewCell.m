//
//  HQBroswerCollectionViewCell.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/4/12.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HQBroswerCollectionViewCell.h"
#import "HQBroswerModel.h"





@interface HQBroswerCollectionViewCell()



@end

@implementation HQBroswerCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.previreView];
    }
    return self;
}

- (void)setBroswerModel:(HQBroswerModel *)broswerModel{
    _broswerModel = broswerModel;
    self.previreView.broswerModel = _broswerModel;
}

- (void)singleTapAction{
    if (_singleTapGestureBlock) {
        _singleTapGestureBlock();
    }
}
- (HQBroswerPrevireView *)previreView{
    if (_previreView == nil) {
        _previreView = [[HQBroswerPrevireView alloc] initWithFrame:self.bounds];
        WEAKSELF;
        [_previreView setSingleTapGestureBlock:^{
            [weakSelf singleTapAction];
        }];
    }
    return _previreView;
}
@end



@interface HQBroswerPrevireView ()<UIScrollViewDelegate>


@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIImageView *contentImageView;
@property (nonatomic) UIImageView *tempImageView;

@end


@implementation HQBroswerPrevireView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.frame = CGRectMake(10, 0, self.width - 20, self.height);
        _scrollView.bouncesZoom = YES;
        _scrollView.maximumZoomScale = 2.5;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delaysContentTouches = NO;
        _scrollView.canCancelContentTouches = YES;
        _scrollView.alwaysBounceVertical = NO;
        _scrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:_scrollView];
        
//        _imageContainerView = [[UIView alloc] initWithFrame:_scrollView.bounds];
//        _imageContainerView.clipsToBounds = YES;
//        _imageContainerView.contentMode = UIViewContentModeScaleAspectFill;
//        _imageContainerView.backgroundColor = [UIColor clearColor];
//        [_scrollView addSubview:_imageContainerView];
        
        _contentImageView = [[UIImageView alloc] initWithFrame:_scrollView.bounds];
        _contentImageView.backgroundColor = [UIColor blackColor];
        _contentImageView.backgroundColor = [UIColor clearColor];
        _contentImageView.contentMode = UIViewContentModeScaleAspectFill;
        _contentImageView.clipsToBounds = YES;
        [_scrollView addSubview:_contentImageView];
        
        
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [self addGestureRecognizer:tap1];
        
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        tap2.numberOfTapsRequired = 2;
        [tap1 requireGestureRecognizerToFail:tap2];
        [self addGestureRecognizer:tap2];
    }
    return self;
}
- (void)setBroswerModel:(HQBroswerModel *)broswerModel{
    _broswerModel = broswerModel;
    _contentImageView.image = _broswerModel.tempImage;
    if (_broswerModel.origineImage) {
        _contentImageView.image = _broswerModel.origineImage;
    }
    [self resizeSubviews];
    if (_broswerModel.origineImage == nil) {
//        WEAKSELF;
//        [HQLocalImageManager getChatMineMessageImageWtihImageName:_broswerModel.fileName withImageSize:CGSizeMake(_broswerModel.tempImage.size.width*5, _broswerModel.tempImage.size.height*5) andComplite:^(UIImage *image) {
//            _broswerModel.origineImage = image;
//            [weakSelf setDataWith:image];
//            [weakSelf resizeSubviews];
//        }];
    }
}

- (void)setDataWith:(UIImage *)image{
    self.contentImageView.image = image;
}
#pragma mark - UITapGestureRecognizer Event

- (void)doubleTap:(UITapGestureRecognizer *)tap {
    if (_scrollView.zoomScale > 1.0) {
        _scrollView.contentInset = UIEdgeInsetsZero;
        [_scrollView setZoomScale:1.0 animated:YES];
    } else {
        CGPoint touchPoint = [tap locationInView:self.contentImageView];
        CGFloat newZoomScale = _scrollView.maximumZoomScale;
        CGFloat xsize = self.frame.size.width / newZoomScale;
        CGFloat ysize = self.frame.size.height / newZoomScale;
        [_scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}
- (void)singleTap:(UITapGestureRecognizer *)tap {
    if (self.singleTapGestureBlock) {
        self.singleTapGestureBlock();
    }
}

#pragma mark - UIScrollViewDelegate

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _contentImageView;
}
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    scrollView.contentInset = UIEdgeInsetsZero;
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
     [self refreshImageContainerViewCenter];
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    scrollView.contentInset = UIEdgeInsetsZero;
}
- (void)resizeSubviews {
    CGRect resultRect;
    CGSize size = (_contentImageView.image) ? _contentImageView.image.size : CGSizeMake(App_Frame_Width, APP_Frame_Height);
    CGFloat ratio = MIN(App_Frame_Width / size.width, APP_Frame_Height / size.height);
    CGFloat W = ratio * size.width ;
    CGFloat H = ratio * size.height ;
    resultRect = CGRectMake(MAX(0, (App_Frame_Width-W)/2), MAX(0, (APP_Frame_Height-H)/2), W, H);
    _contentImageView.frame = resultRect;

}
- (void)refreshImageContainerViewCenter {
    CGFloat offsetX = (_scrollView.tz_width > _scrollView.contentSize.width) ? ((_scrollView.tz_width - _scrollView.contentSize.width) * 0.5) : 0.0;
    CGFloat offsetY = (_scrollView.tz_height > _scrollView.contentSize.height) ? ((_scrollView.tz_height - _scrollView.contentSize.height) * 0.5) : 0.0;
    _contentImageView.center = CGPointMake(_scrollView.contentSize.width * 0.5 + offsetX, _scrollView.contentSize.height * 0.5 + offsetY);
}
@end
