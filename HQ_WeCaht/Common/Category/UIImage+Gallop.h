//
//  UIImage+Gallop.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/3.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Gallop)



/**
 *  将一张图片按照contentMode和指定的size处理
 *
 */
- (UIImage *)lw_processedImageWithContentMode:(UIViewContentMode)contentMode size:(CGSize)size;


/**
 *  在指定区域内按照UIViewContentMode的样式和是否clips绘制
 *
 */
- (void)lw_drawInRect:(CGRect)rect contentMode:(UIViewContentMode)contentMode clipsToBounds:(BOOL)clips;


/**
 *  纠正图片的方向
 *
 */
- (UIImage *)lw_fixOrientation;


/**
 *  根据颜色生成纯色图片
 *
 */
+ (UIImage *)lw_imageWithColor:(UIColor *)color;

/**
 *  取图片某一像素的颜色
 *
 */
- (UIColor *)lw_colorAtPixel:(CGPoint)point;

/**
 *  获得灰度图
 *
 */
- (UIImage *)lw_convertToGrayImage;


/**
 *  用一个Gif生成UIImage
 *
 *  @param theData 传入一个GIFData对象
 */
+ (UIImage *)lw_animatedImageWithAnimatedGIFData:(NSData *)theData;

/**
 *  用一个Gif生成UIImage
 *
 *  @param theURL 传入一个GIF路径
 */
+ (UIImage *)lw_animatedImageWithAnimatedGIFURL:(NSURL *)theURL;

/**
 *  按给定的方向旋转图片
 *
 */
- (UIImage*)lw_rotate:(UIImageOrientation)orient;

/**
 *  垂直翻转
 *
 */
- (UIImage *)lw_flipVertical;

/**
 *  水平翻转
 *
 */
- (UIImage *)lw_flipHorizontal;


/**
 *  将图片旋转degrees角度
 *
 */
- (UIImage *)lw_imageRotatedByDegrees:(CGFloat)degrees;

/**
 *  将图片旋转radians弧度
 *
 */
- (UIImage *)lw_imageRotatedByRadians:(CGFloat)radians;

/**
 * 截取当前image对象rect区域内的图像
 *
 */
- (UIImage *)lw_subImageWithRect:(CGRect)rect;

/**
 * 压缩图片至指定尺寸
 *
 */
- (UIImage *)lw_rescaleImageToSize:(CGSize)size;

/**
 * 压缩图片至指定像素
 *
 */
- (UIImage *)lw_rescaleImageToPX:(CGFloat)toPX;

/**
 * 在指定的size里面生成一个平铺的图片
 *
 */
- (UIImage *)lw_getTiledImageWithSize:(CGSize)size;


/**
 * UIView转化为UIImage
 *
 */
+ (UIImage *)lw_imageFromView:(UIView *)view;

/**
 * 将两个图片生成一张图片
 *
 */
+ (UIImage*)lw_mergeImage:(UIImage*)firstImage withImage:(UIImage*)secondImage;

/**
 * 图片模糊处理
 *
 */
- (UIImage *)lw_applyBlurWithRadius:(CGFloat)blurRadius
                          tintColor:(UIColor *)tintColor
              saturationDeltaFactor:(CGFloat)saturationDeltaFactor
                          maskImage:(UIImage *)maskImage;


@end
