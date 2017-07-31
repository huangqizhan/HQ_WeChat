//
//  DownLoadPercentView.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/4/10.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownLoadPercentView : UIView


- (void)drawCircleWithPercent:(CGFloat)percent;

@end





@interface CustomerProcessView : UIView

@property (nonatomic,assign) CGFloat process;

@end
