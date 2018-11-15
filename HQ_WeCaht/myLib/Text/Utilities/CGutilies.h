//
//  CGutilies.h
//  YYStudyDemo
//
//  Created by hqz  QQ 757618403 on 2018/9/25.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <Accelerate/Accelerate.h>
#import <UIKit/UIKit.h>
#import "Global.h"

YYSS_EXTERN_C_BEGIN
///创建ARGB位图
CGContextRef CgcontextCreateARGBBitmapContext(CGSize size,BOOL opaque,CGFloat scale);

///创建灰度位图
CGContextRef CGContextCreateGrayBitmapCgcontext(CGSize size,CGFloat scale);


CGFloat ScreenScale(void);

CGSize ScreenSize(void);


/*
 计算两个视图之间转化的 CGAffineTransform
 */





// main screen's scale
#ifndef kScreenScale
#define kScreenScale ScreenScale()
#endif

// main screen's size (portrait)
#ifndef kScreenSize
#define kScreenSize ScreenSize()
#endif

// main screen's width (portrait)
#ifndef kScreenWidth
#define kScreenWidth ScreenSize().width
#endif

// main screen's height (portrait)
#ifndef kScreenHeight
#define kScreenHeight ScreenSize().height
#endif

YYSS_EXTERN_C_END 
