//
//  NSObject+HQCGRectTransform.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/3.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSObject (HQCGRectTransform)

/**
 *  根据contentMode获取绘制的CGRect
 *
 */
+ (CGRect)lw_CGRectFitWithContentMode:(UIViewContentMode)contentMode
                                 rect:(CGRect)rect
                                 size:(CGSize)siz;

@end
