//
//  UIScrollView+HQRefersh.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/25.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>


@class HQRefershBaseControll;


@interface UIScrollView (HQRefersh)


@property (nonatomic,strong) HQRefershBaseControll *headerRefersh;

@property (copy, nonatomic) void (^reloadDataBlock)(NSInteger totalDataCount);








@property (assign, nonatomic) CGFloat insetT;
@property (assign, nonatomic) CGFloat insetB;
@property (assign, nonatomic) CGFloat insetL;
@property (assign, nonatomic) CGFloat insetR;

@property (assign, nonatomic) CGFloat offsetX;
@property (assign, nonatomic) CGFloat offsetY;

@property (assign, nonatomic) CGFloat contentW;
@property (assign, nonatomic) CGFloat contentH;

@end
