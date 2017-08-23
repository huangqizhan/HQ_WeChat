//
//  HQEdiateImageController.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/25.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HQEdiateImageController : UIViewController <UIScrollViewDelegate,UIViewControllerTransitioningDelegate> {
    
    __weak UIScrollView *_scrollView;
}

////要编辑的image 
@property (nonatomic,strong) UIImage *originalImage;

@property (nonatomic,strong) UIImageView *ediateImageView;

@property (nonatomic,weak,readonly) UIScrollView *scrollView;

@property (nonatomic,strong) UIView *menuView;


- (void)fixZoomScaleWithAnimated:(BOOL)animated;

- (void)resetZoomScaleWithAnimated:(BOOL)animated;

- (void)resetBottomViewEdiateStatus;

- (void)resetImageViewFrame;

- (void)refershUIWhenediateCompliteWithNewImage:(UIImage *)newImage;


@end


#pragma mark ------ 裁剪跳转界面的专场动画  ----------- 

@interface HQEdiateImageControllerEdiateTranstion : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL presenting;

- (instancetype)initWithPresenting:(BOOL)presenting;

@end
