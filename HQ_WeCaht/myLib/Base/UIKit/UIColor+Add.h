//
//  UIColor+Add.h
//  YYKitStudy
//
//  Created by GoodSrc on 2017/12/13.
//  Copyright © 2017年 GoodSrc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


#ifndef UIColorHex
#define UIColorHex(_hex_)   [UIColor colorWithHexString:((__bridge NSString *)CFSTR(#_hex_))]
#endif


extern void YY_RGB2HSL(CGFloat r, CGFloat g, CGFloat b,
                       CGFloat *h, CGFloat *s, CGFloat *l);

extern void YY_HSL2RGB(CGFloat h, CGFloat s, CGFloat l,
                       CGFloat *r, CGFloat *g, CGFloat *b);

extern void YY_RGB2HSB(CGFloat r, CGFloat g, CGFloat b,
                       CGFloat *h, CGFloat *s, CGFloat *v);

extern void YY_HSB2RGB(CGFloat h, CGFloat s, CGFloat v,
                       CGFloat *r, CGFloat *g, CGFloat *b);

extern void YY_RGB2CMYK(CGFloat r, CGFloat g, CGFloat b,
                        CGFloat *c, CGFloat *m, CGFloat *y, CGFloat *k);

extern void YY_CMYK2RGB(CGFloat c, CGFloat m, CGFloat y, CGFloat k,
                        CGFloat *r, CGFloat *g, CGFloat *b);

extern void YY_HSB2HSL(CGFloat h, CGFloat s, CGFloat b,
                       CGFloat *hh, CGFloat *ss, CGFloat *ll);

extern void YY_HSL2HSB(CGFloat h, CGFloat s, CGFloat l,
                       CGFloat *hh, CGFloat *ss, CGFloat *bb);

////十六进制字符串转 RGB
extern BOOL hexStrToRGBA(NSString *str,
                         CGFloat *r, CGFloat *g, CGFloat *b, CGFloat *a) ;


@interface UIColor (Add)

////用HSL  生成color  
+ (UIColor *)colorWithHue:(CGFloat)hue
               saturation:(CGFloat)saturation
                lightness:(CGFloat)lightness
                    alpha:(CGFloat)alpha;
///用CMYK 生成 color 
+ (UIColor *)colorWithCyan:(CGFloat)cyan
                   magenta:(CGFloat)magenta
                    yellow:(CGFloat)yellow
                     black:(CGFloat)black
                     alpha:(CGFloat)alpha;

////32位 RGB 生成 color 
+ (UIColor *)colorWithRGB:(uint32_t)rgbValue;

////用带32位 alpha  生成 color
+ (UIColor *)colorWithRGBA:(uint32_t)rgbaValue;

////用带32位 alpha  生成 color
+ (UIColor *)colorWithRGB:(uint32_t)rgbValue alpha:(CGFloat)alpha;
////color 转 32位
- (uint32_t)rgbValue;
////带 alpha 的 color 转 32位
- (uint32_t)rgbaValue;

///用16进制 创建color
+ (instancetype)colorWithHexString:(NSString *)hexStr;
///color 转成16 进制字符串
- (NSString *)hexString;
///color 转成16 进制字符串
- (NSString *)hexStringWithAlpha;
////添加color
- (UIColor *)colorByAddColor:(UIColor *)add blendMode:(CGBlendMode)blendMode;
///HSB 创建color 
- (UIColor *)colorByChangeHue:(CGFloat)h saturation:(CGFloat)s brightness:(CGFloat)b alpha:(CGFloat)a;
///获取color的HSB 
- (BOOL)getHue:(CGFloat *)hue saturation:(CGFloat *)saturation lightness:(CGFloat *)lightness alpha:(CGFloat *)alpha ;
///R
@property (nonatomic, readonly) CGFloat red;
///G
@property (nonatomic, readonly) CGFloat green;

///B
@property (nonatomic, readonly) CGFloat blue;
///色相
@property (nonatomic, readonly) CGFloat hue;
///饱和度
@property (nonatomic, readonly) CGFloat saturation;
///亮度
@property (nonatomic, readonly) CGFloat brightness;
///alpha
@property (nonatomic, readonly) CGFloat alpha;

/**
 The color's colorspace model.
 */
@property (nonatomic, readonly) CGColorSpaceModel colorSpaceModel;

/**
 Readable colorspace string.
 */
@property (nullable, nonatomic, readonly) NSString *colorSpaceString;



@end


NS_ASSUME_NONNULL_END
