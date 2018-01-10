//
//  UIColor+Extern.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/5/25.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UIColorRGBA(_red, _green, _blue, _alpha) [UIColor colorWithRed:((_red)/255.0) \
green:((_green)/255.0) blue:((_blue)/255.0) alpha:(_alpha)]

#define UIColorRGB(red, green, blue) UIColorRGBA(red, green, blue, 1)

#define UIColorHexRGB(rgbString) [UIColor colorWithHexRGB:(rgbString)]

#define UIColorHexRGBA(rgbaString) [UIColor colorWithHexRGBA:(rgbaString)]



@interface UIColor (Extern)

+ (UIColor *)randomColor;

+ (UIColor *)randomColorWithAlpha:(CGFloat)alpha;

+ (instancetype)colorWithHexRGBA:(NSString *)rgba;

+ (instancetype)colorWithHexRGB:(NSString *)rgb;

+ (instancetype)colorWithHexARGB:(NSString *)argb;

+ (BOOL)color:(UIColor *)color1 isEqualToColor:(UIColor *)color2 withTolerance:(CGFloat)tolerance;

//+ (UIColor *)colorWithHexString:(NSString *)hexStr;

@end
