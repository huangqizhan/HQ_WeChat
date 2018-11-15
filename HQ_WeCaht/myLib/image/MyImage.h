//
//  MyImage.h
//  YYStudyDemo
//
//  Created by hqz  QQ 757618403 on 2018/7/4.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageDeCode.h"
#import "SpriteSheetImage.h"
#import "AnimatedImageView.h"

/*
  如果数据是 gif/apng/webp MyImage 会自动解析数据
  MyImage 已经解码 在CPU  计算完之后 不用解码 直接给GPU渲染  不用解码
 */


NS_ASSUME_NONNULL_BEGIN
@interface MyImage : UIImage <YYAnimatedImage>

+ (nullable MyImage *)imageNamed:(NSString *)name; // no cache!
+ (nullable MyImage *)imageWithContentsOfFile:(NSString *)path;
+ (nullable MyImage *)imageWithData:(NSData *)data;
+ (nullable MyImage *)imageWithData:(NSData *)data scale:(CGFloat)scale;
///iamgeType
@property (nonatomic, readonly) YYImageType animatedImageType;

//// animatedData
@property (nullable, nonatomic, readonly) NSData *animatedImageData;

////数据大小
@property (nonatomic, readonly) NSUInteger animatedImageMemorySize;
///提前加载帧数 
@property (nonatomic) BOOL preloadAllAnimatedImageFrames;


@end

NS_ASSUME_NONNULL_END 
