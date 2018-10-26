//
//  HQImageIOHelper.m
//  HQ_WeChat
//
//  Created by 黄麒展 on 2018/10/22.
//  Copyright © 2018年 黄麒展. All rights reserved.
//

#import "HQImageIOHelper.h"


@implementation HQImageIOHelper
+ (NSBundle *)bundle{
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bundle = [NSBundle mainBundle];
    });
    return bundle;
}

+ (MemoryCache *)imageCache{
    static MemoryCache *imageCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imageCache = [MemoryCache new];
      imageCache.shouldRemoveAllObjectsOnMemoryWarning = YES;
        imageCache.shouldRemoveAllObjectsWhenEnteringBackground = NO;
        imageCache.name = @"ImageCache";
    });
    return imageCache;
}
////头像处理的webimageManager
+ (WebImageManager *)avatarImageManager{
    static WebImageManager *imageManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        WebImageCache *cache = [[WebImageCache alloc] initWithPath:[UIApplication sharedApplication].cachesPath];
        imageManager = [[WebImageManager alloc] initWithCache:cache queue:[WebImageManager sharedManager].queue];
        ///在把图片存入缓存之前处理圆角
        imageManager.sharedTransformBlock = ^UIImage * _Nullable(UIImage *image, NSURL *url) {
            if (!image) return image;
            image = [image imageByRoundCornerRadius:100];
            return image;
        };
    });
    return imageManager;
}

+ (UIImage *)imageWithNamed:(NSString *)name{
    if (!name) return nil;
    UIImage *image = [[self imageCache] objectForKey:name];
    if (image) return image;
    NSString *ext = name.pathExtension;
    if (ext.length == 0) ext = @"png";
    
    NSString *path = [[self bundle] pathForScaledResource:name ofType:@"png"];
    if (!path) return nil;
    ///此处不使用 imageNamed  系统不会有缓存
    image = [UIImage imageWithContentsOfFile:path];
    ///把图片转成位图
    image = [image imageByDecoded];
    if(!image) return nil;
    [[self imageCache] setObject:image forKey:name];
    return image;
}

+ (UIImage *)imageWithPath:(NSString *)path {
    if (!path) return nil;
    UIImage *image = [[self imageCache] objectForKey:path];
    if (image) return image;
    if (path.pathScale == 1) {
        // 查找 @2x @3x 的图片
        NSArray *scales = [NSBundle preferredScales];
        for (NSNumber *scale in scales) {
            image = [UIImage imageWithContentsOfFile:[path stringByAppendingPathScale:scale.floatValue]];
            if (image) break;
        }
    } else {
        image = [UIImage imageWithContentsOfFile:path];
    }
    if (image) {
        image = [image imageByDecoded];
        [[self imageCache] setObject:image forKey:path];
    }
    return image;
}


@end
