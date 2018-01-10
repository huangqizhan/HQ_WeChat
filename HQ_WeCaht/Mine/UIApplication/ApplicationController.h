//
//  ApplicationController.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/11/17.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ApplicationController : UIViewController

@end




/////headerView
@interface HeadweView : UIView

@end


/////计算背景视图的宽高
@interface NewUserInfoDetailStretchHelper : NSObject

@property (nonatomic,strong) UIView *stretchView;
@property (nonatomic,assign) CGFloat imageRatio;
@property (nonatomic,assign) CGRect originFrame;

- (instancetype)initWithBgView:(UIView *)begView;


- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

@end


@interface  TestActionModel : NSObject

- (void)action:(id)sender forEvent:(UIEvent *)event;


@end
