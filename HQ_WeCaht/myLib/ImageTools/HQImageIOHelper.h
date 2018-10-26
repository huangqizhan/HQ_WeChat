//
//  HQImageIOHelper.h
//  HQ_WeChat
//
//  Created by 黄麒展 on 2018/10/22.
//  Copyright © 2018年 黄麒展. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CacheCore.h"
#import "WebImageCore.h"
#import "BaseCore.h"
#import "ImageCore.h"

/**
 负责处理本地的图片读写/处理
 */
@interface HQImageIOHelper : NSObject

////头像处理的webimageManager
+ (WebImageManager *)avatarImageManager;
///获取本地图片  保存到缓存中  自动配置scale 
+ (UIImage *)imageWithNamed:(NSString *)name;
///根据路径获取图片  保存到缓存中 自动配置scale 
+ (UIImage *)imageWithPath:(NSString *)path;
@end


