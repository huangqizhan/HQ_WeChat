//
//  HQWebProcessView.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/22.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HQWebProcessView : UIView


//如果未设置，则使用系统默认tintColor
@property (nonatomic) UIColor *progressBarColor;

- (void)reset;

- (void)setProgress:(float)progress animated:(BOOL)animated;


@end
