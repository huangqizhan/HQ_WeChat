//
//  HQEdiateImageController.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/25.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HQEdiateImageController : UIViewController <UIScrollViewDelegate> {
    
    __weak UIScrollView *_scrollView;
}

////要编辑的image 
@property (nonatomic,strong) UIImage *originalImage;

@property (nonatomic,strong) UIImageView *imageView;

@property (nonatomic,weak,readonly) UIScrollView *scrollView;

@property (nonatomic,strong) UIView *menuView;


- (void)fixZoomScaleWithAnimated:(BOOL)animated;
- (void)resetZoomScaleWithAnimated:(BOOL)animated;


@end
