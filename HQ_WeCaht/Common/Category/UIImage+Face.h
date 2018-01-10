//
//  UIImage+Face.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/9/8.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Face)

////获取图片中的多个头像图片
+(NSArray *)faceImagesByFaceRecognitionWithImage:(UIImage *)image;

////获取头像个数
+(NSInteger)totalNumberOfFacesByFaceRecognitionWithImage:(UIImage *)image;


@end
