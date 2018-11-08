//
//  UIImage+Add.h
//  YYKitStudy
//
//  Created by GoodSrc on 2017/12/13.
//  Copyright © 2017年 GoodSrc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, HQImageCombineType) {
    HQImageCombineHorizental,
    HQImageCombineVertical
};

@interface UIImage (Add)

///根据data 创建 gif Image
+ (UIImage *)imageWithSmallGIFData:(NSData *)data scale:(CGFloat)scale;

////是否是GFI Image 
+ (BOOL)isAnimatedGIFData:(NSData *)data ;
+ (BOOL)isAnimatedGIFFile:(NSString *)path;


///创建PDF
+ (UIImage *)imageWithPDF:(id)dataOrPath;
+ (UIImage *)imageWithPDF:(id)dataOrPath size:(CGSize)size;


///表情编码转表情Image      //\ue305    😄
+ (UIImage *)imageWithEmoji:(NSString *)emoji size:(CGFloat)size;


//// imageWIth Color
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

/// 是否由alpha 通道
- (BOOL)hasAlphaChannel;

///创建 image 并且返回 CGContext 
+ (UIImage *)imageWithSize:(CGSize)size drawBlock:(void (^)(CGContextRef context))drawBlock;

///根据 UIViewContentMode 和  CGRect   重新绘制  Image 到 CGContext
- (void)drawInRect:(CGRect)rect withContentMode:(UIViewContentMode)contentMode clipsToBounds:(BOOL)clips;
///压缩
- (UIImage *)imageByResizeToSize:(CGSize)size;
- (UIImage *)imageByResizeToSize:(CGSize)size contentMode:(UIViewContentMode)contentMode;
///裁剪
- (UIImage *)imageByCropToRect:(CGRect)rect;
///绘制边框
- (UIImage *)imageByInsetEdge:(UIEdgeInsets)insets withColor:(UIColor *)color;
///给Image 添加边框
- (UIImage *)imageByRoundCornerRadius:(CGFloat)radius ;
- (UIImage *)imageByRoundCornerRadius:(CGFloat)radius
                          borderWidth:(CGFloat)borderWidth
                          borderColor:(UIColor *)borderColor;
- (UIImage *)imageByRoundCornerRadius:(CGFloat)radius
                              corners:(UIRectCorner)corners
                          borderWidth:(CGFloat)borderWidth
                          borderColor:(UIColor *)borderColor
                       borderLineJoin:(CGLineJoin)borderLineJoin;
///图片旋转
- (UIImage *)imageByRotate:(CGFloat)radians fitSize:(BOOL)fitSize;
///翻转
- (UIImage *)flipHorizontal:(BOOL)horizontal vertical:(BOOL)vertical ;
////颜色覆盖
- (UIImage *)imageByTintColor:(UIColor *)color ;

///模糊
- (UIImage *)imageByGrayscale;
- (UIImage *)imageByBlurSoft;
- (UIImage *)imageByBlurLight;
- (UIImage *)imageByBlurExtraLight;
- (UIImage *)imageByBlurDark;
- (UIImage *)imageByBlurWithTint:(UIColor *)tintColor ;
- (UIImage *)imageByBlurRadius:(CGFloat)blurRadius
                     tintColor:(UIColor *)tintColor
                      tintMode:(CGBlendMode)tintBlendMode
                    saturation:(CGFloat)saturation
                     maskImage:(UIImage *)maskImage;
//拼接图片
+(UIImage *)combineWithImages:(NSArray *)images orientation:(HQImageCombineType)orientation;

//局部收缩
- (UIImage *)shrinkImageWithCapInsets:(UIEdgeInsets)capInsets actualSize:(CGSize)actualSize;

@end


NS_ASSUME_NONNULL_END
