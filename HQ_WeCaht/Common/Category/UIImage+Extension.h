//
//  UIImage+Extension.h
//  XZ_WeChat
//
//  Created by 郭现壮 on 16/9/27.
//  Copyright © 2016年 gxz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)


+ (UIImage *)gxz_imageWithColor:(UIColor *)color;

+ (UIImage *)videoFramerateWithPath:(NSString *)videoPath;

// 压缩图片
+ (UIImage *)simpleImage:(UIImage *)originImg;

+ (UIImage *)makeArrowImageWithSize:(CGSize)imageSize
                              image:(UIImage *)image
                           isSender:(BOOL)isSender;

+ (UIImage *)addImage2:(UIImage *)firstImg
               toImage:(UIImage *)secondImg;

+ (UIImage *)addImage:(UIImage *)firstImg
              toImage:(UIImage *)secondImg;


+  (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;




/**
 *  将一张图片按照contentMode和指定的size处理
 *
 */
- (UIImage *)processedImageWithContentMode:(UIViewContentMode)contentMode size:(CGSize)size;

/**
 *  在指定区域内按照UIViewContentMode的样式和是否clips绘制
 *
 */
- (void)drawInRect:(CGRect)rect contentMode:(UIViewContentMode)contentMode clipsToBounds:(BOOL)clips;


/**
 *  取图片某一像素的颜色
 *
 */
- (UIColor *)colorAtPixel:(CGPoint)point;

/**
 *  获得灰度图
 *
 */
- (UIImage *)convertToGrayImage;



@end
