//
//  HQEdiateImageCutView.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/8/10.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <UIKit/UIKit.h>


@class CutLineView;

@class HQCutImageController;

@interface HQEdiateImageCutView : UIView<UIGestureRecognizerDelegate>


@property (nonatomic,weak) HQCutImageController *imageEdiateController;

@property (nonatomic,strong) CutLineView *gridLayer;
@property (nonatomic, assign) CGRect clippingRect;  //裁剪范围

- (id)initWithSuperview:(UIView*)superview frame:(CGRect)frame;

/**
 设置裁剪view的背景颜色
 */
- (void)setBgColor:(UIColor*)bgColor;


/**
 设置裁剪的网格颜色
 */
- (void)setGridColor:(UIColor*)gridColor;


@end




@interface CutCircleView : UIView

@end




@interface CutLineView : CALayer

@property (nonatomic, assign) CGRect clippingRect; //裁剪范围
@property (nonatomic, strong) UIColor *bgColor;    //背景颜色
@property (nonatomic, strong) UIColor *gridColor;  //线条颜色


@end
