//
//  UIImage+Resize.h
//  SCCaptureCameraDemo
//
//  Created by Aevitx on 14-1-17.
//  Copyright (c) 2014年 Aevitx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Resize)

///截取图片  截取时  按照图片的原始size 截取   范围如果超出图片大小范围 则返回空
- (UIImage *)croppedImage:(CGRect)bounds;

///
- (UIImage *)resizedImage:(CGSize)newSize
     interpolationQuality:(CGInterpolationQuality)quality;

- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality;

- (UIImage *)resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality;

- (CGAffineTransform)transformForOrientation:(CGSize)newSize;

- (UIImage *)fixOrientation;

- (UIImage *)rotatedByDegrees:(CGFloat)degrees;

+ (UIImage*)createImageWithColor:(UIColor*)color size:(CGSize)imageSize;

+ (void)drawALineWithFrame:(CGRect)frame andColor:(UIColor*)color inLayer:(CALayer*)parentLayer;
+ (void)saveImageToPhotoAlbum:(UIImage*)image;

///压缩图片
+ (UIImage *)imageCompartionRatio:(UIImage *)oldImage;

////broswer   图片大小
+ (CGRect)caculateBroswerImageSizeWith:(UIImage *)image;


+ (UIImage *)imageWithView:(UIView *)view;

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

- (UIImage *)resizableImage;

- (UIImage *) partialImageWithPercentage:(float)percentage vertical:(BOOL)vertical grayscaleRest:(BOOL)grayscaleRest;
@end
