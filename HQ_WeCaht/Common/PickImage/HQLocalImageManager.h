//
//  HQLocalImageManager.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/22.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//


//#define ArrowPicMe @"Chat/ArrowMe"
//#define ArrowPicOther @"Chat/ArrowOther"
//#define MyPic @"Chat/MyPic"
//#define VodioPic @"Chat/VodioPic"

#import <Foundation/Foundation.h>
#import "CacheCore.h"
#import "WebImageCore.h"
#import "BaseCore.h"
#import "ImageCore.h"
#import "HQBroswerModel.h"



@interface HQLocalImageManager : NSObject

+ (instancetype)shareImageManager;

////chat 处理的webimageManager
+ (WebImageManager *)chatImageManager;

///存入缓存并且解码
+ (void )saveImage:(UIImage *)image iamgeName:(NSString *)imageName;

/// 从本地读取图片
+ (UIImage *)getImageWithImageName:(NSString *)imageName;

///删除本地图片
+ (void)removeImageWithImageName:(NSString *)imageName;

///保存资源包中的gif 到内存中 
+ (void)saveLocalGifImage:(MyImage *)image fileName:(NSString *)fileName;
///
+ (UIImage *)saveAndCodeImage:(UIImage *)image fileName:(NSString *)fileName;

@end
