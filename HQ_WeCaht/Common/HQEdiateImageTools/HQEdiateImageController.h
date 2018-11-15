//
//  HQEdiateImageController.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/25.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HQEdiateImageController : UIViewController <UIScrollViewDelegate,UIViewControllerTransitioningDelegate> {
    
    __weak UIScrollView *_scrollView;
}

////要编辑的image 
@property (nonatomic,strong) UIImage *originalImage;

@property (nonatomic,strong) UIImageView *ediateImageView;
/////
@property (nonatomic,weak,readonly) UIScrollView *scrollView;
////底部栏视图
@property (nonatomic,strong) UIView *menuView;
////图片编辑后的回调
@property (nonatomic,copy) void (^CallBackImageAfterEdiate)(UIImage *);

/**
 重置scrollView的放大和缩小值

 @param animated bool
 */
- (void)resetZoomScaleWithAnimated:(BOOL)animated;

/**
 重置底部栏的初始状态
 */
- (void)resetBottomViewEdiateStatus;


/**
 裁剪图片时裁剪结果

 @param newImage 裁剪后的image
 */
- (void)refershUIWhenediateCompliteWithNewImage:(UIImage *)newImage;


@end


#pragma mark ------ 裁剪跳转界面的专场动画  ----------- 

@interface HQEdiateImageControllerEdiateTranstion : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL presenting;

- (instancetype)initWithPresenting:(BOOL)presenting;

@end
