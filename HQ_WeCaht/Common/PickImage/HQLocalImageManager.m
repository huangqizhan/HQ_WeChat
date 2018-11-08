//
//  HQLocalImageManager.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/22.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQLocalImageManager.h"
#import "UIImage+Resize.h"
#import "HQFileTools.h"
#import "UIImage+CompressImage.h"

@interface HQLocalImageManager ()


@end

@implementation HQLocalImageManager

+ (instancetype)shareImageManager{
    static HQLocalImageManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HQLocalImageManager alloc] init];
    });
    return manager;
}

////caht 处理的webimageManager
+ (WebImageManager *)chatImageManager{
    static WebImageManager *imageManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        WebImageCache *cache = [[WebImageCache alloc] initWithPath:[UIApplication sharedApplication].cachesPath];
        imageManager = [[WebImageManager alloc] initWithCache:cache queue:[WebImageManager sharedManager].queue];
        ///在把图片存入缓存之前处理圆角
        imageManager.sharedTransformBlock = ^UIImage * _Nullable(UIImage *image, NSURL *url) {
            if (!image) return image;
            image = [image imageByRoundCornerRadius:6];
            return image;
        };
    });
    return imageManager;
}

+ (WebImageCache *)imageCache{
    static WebImageCache *imageCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imageCache = [self chatImageManager].cache;
       imageCache.memoryCache.shouldRemoveAllObjectsOnMemoryWarning = YES;
        imageCache.memoryCache.shouldRemoveAllObjectsWhenEnteringBackground = NO;
        imageCache.name = @"ChatImageCache";
    });
    return imageCache;
}


+ (void )saveImage:(UIImage *)image iamgeName:(NSString *)imageName{
    if (!image || !imageName) return ;
    if(!image) return ;
    image = [image imageByRoundCornerRadius:6];
    [[self imageCache] setImage:image forKey:imageName];
}

+ (UIImage *)getImageWithImageName:(NSString *)imageName{
    return [[self imageCache] getImageForKey:imageName];
}
+ (void)removeImageWithImageName:(NSString *)imageName{
    [[self imageCache] removeImageForKey:imageName withType:YYImageCacheTypeAll];
}

+ (UIImage *)saveAndCodeImage:(UIImage *)image fileName:(NSString *)fileName{
    image = [image imageByRoundCornerRadius:6];
    image = [image imageByDecoded];
    [[self imageCache] setImage:image forKey:fileName];
    return image;
}
///**
// 获取我的尖头图片
//
// @param imageName 图片名
// 
// */
//+ (void)getArrowMeImageName:(NSString *)imageName complite:(void (^)(UIImage *image))complite{
//    if (imageName == nil) {
//        if (complite) complite( nil);
//    }
//    NSString *filePath = [[self creatFileAtPath:ArrowPicMe] stringByAppendingPathComponent:imageName];
//    if ([[self imageCache] objectForKey:imageName]) {
//        UIImage *im = [[self imageCache] objectForKey:imageName];
//        if (complite) complite(im);
//        return;
//    }
//    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
//    if (image) {
//        [[self imageCache] setObject:image forKey:imageName];
//    }
//    if (complite) complite(image);
//}
//
///**
// 获取他人尖头图片
//
// @param imageName 图片名
// @return 图片
// */
//+ (UIImage *)getArrowOtherImageName:(NSString *)imageName{
//    if (imageName == nil) {
//        return nil;
//    }
//    NSString *filePath = [[self creatFileAtPath:ArrowPicOther] stringByAppendingPathComponent:imageName];
//    if ([[self imageCache] objectForKey:imageName]) {
//        return [[self imageCache] objectForKey:imageName];
//    }
//    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
//    if (image) {
//        [[self imageCache] setObject:image forKey:imageName];
//    }
//    return image;
//}
//
///**
// 聊天界面压缩后的图片   界面显示
// 
// @param imageName 图片名
// 
// */
//+ (void)getChatMineMessageImageWtihImageName:(NSString *)imageName withImageSize:(CGSize)imageSize andComplite:(void (^)(UIImage *))complite{
//    dispatch_queue_t queue = dispatch_queue_create("readImage", DISPATCH_QUEUE_CONCURRENT);
//    dispatch_async(queue, ^{
//        if (imageName == nil) {
//            if (complite) complite(nil);
//        }
//        NSString *filePath = [[self creatFileAtPath:ArrowPicMe] stringByAppendingPathComponent:imageName];
//        if ([[self imageCache] objectForKey:imageName]) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if (complite) complite([[self imageCache] objectForKey:imageName]);
//                return ;
//            });
//        }
//        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
//        //    image = [UIImage makeArrowImageWithSize:imageSize image:image isSender:YES];
//        image = [UIImage needCompressImage:image size:imageSize scale:0.5];
//        if (image) {
//            [[self imageCache] setObject:image forKey:imageName];
//        }
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (complite) complite(image);
//        });
//    });
//}
//+ (UIImage *)getChatMineMessageImageWtihImageName:(NSString *)imageName withImageSize:(CGSize)imageSize{
//    if (imageName == nil) {
//        return nil;
//    }
//    NSString *filePath = [[self creatFileAtPath:ArrowPicMe] stringByAppendingPathComponent:imageName];
//    if ([[self imageCache] objectForKey:imageName]) {
//        return  [[self imageCache] objectForKey:imageName];
//    }
//    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
//    //    image = [UIImage makeArrowImageWithSize:imageSize image:image isSender:YES];
//    image = [UIImage needCompressImage:image size:imageSize scale:0.2];
//    return image;
//}
///**
// 聊天界面压缩后的图片他人   界面显示
// @param imageName 图片名
// @param imageSize 压缩的尺寸
// @return 图片
// */
//+ (UIImage *)getChatOtherMessageImageWtihImageName:(NSString *)imageName withImageSize:(CGSize)imageSize{
//    if (imageName == nil) {
//        return nil;
//    }
//    NSString *filePath = [[self creatFileAtPath:ArrowPicOther] stringByAppendingPathComponent:imageName];
//    if ([[self imageCache] objectForKey:imageName]) {
//        return [[self imageCache] objectForKey:imageName];
//    }
//    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
////    image = [UIImage makeArrowImageWithSize:imageSize image:image isSender:NO];
//    image = [UIImage needCompressImage:image size:imageSize scale:0.2];
//    return image;
//}
///**
// 删除我的尖头图片
//
// @param imageName 图片名
// */
//+ (void)removoeMeImageFromSandBoxWith:(NSString *)imageName{
//    if (imageName == nil) {
//        return;
//    }
//    NSString *filePath = [[self creatFileAtPath:ArrowPicMe] stringByAppendingPathComponent:imageName];
//    if ([[self imageCache] objectForKey:imageName]) {
//        [[self imageCache] removeObjectForKey:imageName];
//    }
//    [self removeFileAtPath:filePath];
//}
//
///**
// 删除我的尖头图片
// 
// @param imageName 图片名
// */
//+ (void)removoeOtherImageFromSandBoxWith:(NSString *)imageName{
//    if (imageName == nil) {
//        return;
//    }
//    NSString *filePath = [[self creatFileAtPath:ArrowPicOther] stringByAppendingPathComponent:imageName];
//    if ([[self imageCache] objectForKey:imageName]) {
//        [[self imageCache] removeObjectForKey:imageName];
//    }
//    [self removeFileAtPath:filePath];
//}
//
///**
// 保存图片到沙盒 library Chat/MyPic
//
// @param image  保存的图片
// @param fileName  图片名称
// @return 路径
// */
//+ (NSString *)saveArrowOtherToSandBox:(UIImage *)image
//                         withFileName:(NSString *)fileName
//                         andImageSize:(CGSize)imageSize
//                          andIsSender:(BOOL)isSender{
////    image = [UIImage makeArrowImageWithSize:imageSize image:image isSender:isSender];
//   [[self imageCache] setObject:image forKey:fileName];
//   NSString *filePath = [[self creatFileAtPath:MyPic] stringByAppendingPathComponent:fileName];
//   NSData *imageData  = UIImagePNGRepresentation(image);
//   BOOL isSave = [imageData writeToFile:filePath atomically:NO];
//    if (!isSave) {
//        NSLog(@"保存失败");
//    }
//    return filePath;
//}
//
///**
// 保存我的图片
//
// @param image 图片
// @param fileName 图片名
// @return 图片保存路径
// */
//+ (NSString *)saveArrowMeToSandBox:(UIImage *)image
//                      withFileName:(NSString *)fileName
//                      andImageSize:(CGSize)imageSize
//                       andIsSender:(BOOL)isSender{
//    
//    NSString *filePath = [[self creatFileAtPath:ArrowPicMe] stringByAppendingPathComponent:fileName];
//    image = [UIImage makeArrowImageWithSize:imageSize image:image isSender:isSender];
//    [[self imageCache] setObject:image forKey:fileName];
//    NSData *imageData = UIImagePNGRepresentation(image);
//    BOOL isSave = [imageData writeToFile:filePath atomically:NO];
//    if (!isSave) {
//        NSLog(@"保存失败");
//    }
//    return filePath;
//}
//
//+ (void)saveImage:(UIImage *)image andFileName:(NSString *)iamgeName{
//    dispatch_queue_t queue = dispatch_queue_create("saveImageQueue", DISPATCH_QUEUE_CONCURRENT);
//    dispatch_async(queue, ^{
//        NSString *filePath = [[self creatFileAtPath:ArrowPicMe] stringByAppendingPathComponent:iamgeName];
//        NSData *imageData = UIImagePNGRepresentation(image);
//        BOOL isSave = [imageData writeToFile:filePath atomically:NO];
//        if (!isSave) {
//            NSLog(@"保存失败");
//        }
//    });
//}
//////创建文件
//+ (NSString *)creatFileAtPath:(NSString *)path{
//    
//    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:path];
//    
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    
//    if (![fileManager fileExistsAtPath:filePath]) {
//        BOOL isCreat = [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
//        if (!isCreat) {
//            NSLog(@"creat file faild");
//            return nil;
//        }
//    }
//    return filePath;
//}
/////// pricate
//+ (void)removeFileAtPath:(NSString *)path{
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    if ([fileManager fileExistsAtPath:path]) {
//        BOOL isRemove = [fileManager removeItemAtPath:path error:nil];
//        if (!isRemove) {
//            NSLog(@"remove faild");
//        }else{
//            NSLog(@"remove success");
//        }
//    }
//}
//+ (void)saveChatBegImage:(UIImage *)begImage withFileName:(NSString *)fileName  andScale:(CGFloat )scale andComplite:(void (^)(BOOL resukt))complite{
//    NSString *filePath = [[self creatFileAtPath:MyPic] stringByAppendingPathComponent:fileName];
//    dispatch_queue_t queue = dispatch_queue_create("saveQueue", DISPATCH_QUEUE_CONCURRENT);
//    dispatch_async(queue, ^{
//        [self removeFileAtPath:filePath];
//        if ([[self imageCache] objectForKey:fileName]) {
//            [[self imageCache] removeObjectForKey:fileName];
//        }
//        UIImage *image = [UIImage needCompressImage:begImage size:begImage.size scale:scale];
//        NSData *imageData = UIImagePNGRepresentation(image);
//        BOOL isSave = [imageData writeToFile:filePath atomically:NO];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (complite) {
//                complite(isSave);
//            }
//        });
//    });
//}
//+ (void)removeChatBegImageWith:(NSString *)fileName{
//    dispatch_queue_t queue = dispatch_queue_create("removeBeg", DISPATCH_QUEUE_CONCURRENT);
//    dispatch_async(queue, ^{
//        NSString *filePath = [[self creatFileAtPath:MyPic] stringByAppendingPathComponent:fileName];
//        [self removeFileAtPath:filePath];
//    });
//    
//}
//+ (UIImage *)getChatBegImageWith:(NSString *)fileName{
//    if (fileName == nil) {
//        return nil;
//    }
//    NSString *filePath = [[self creatFileAtPath:MyPic] stringByAppendingPathComponent:fileName];
//    if ([[self imageCache] objectForKey:fileName]) {
//        return [[self imageCache] objectForKey:fileName];
//    }
//    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
//    if (image) {
//        [[self imageCache] setObject:image forKey:fileName];
//    }else{
//        image = nil;
//    }
//    return image;
//}
//
//+ (UIImage *)compocessImageWithImage:(UIImage *)image andImageSize:(CGSize)imageSize andIsSender:(BOOL)IsSender{
////    image = [UIImage makeArrowImageWithSize:imageSize image:image isSender:IsSender];
//    image = [UIImage needCompressImage:image size:imageSize scale:0.2];
//    return image;
//}
//
//+ (UIImage *)loadlocalGifImageWith:(NSString *)fileName andScal:(CGFloat)scal{
//    NSString *path = [[NSBundle mainBundle]pathForResource:fileName ofType:@"gif"];
//    NSData *data = [NSData dataWithContentsOfFile:path];
////    UIImage *image = [UIImage yy_imageWithSmallGIFData:data scale:2];
//    return nil;
//}
//+ (NSData *)loadLocalGifImageDataWith:(NSString *)fileName{
//    NSString *path = [[NSBundle mainBundle]pathForResource:fileName ofType:@"gif"];
//    return [NSData dataWithContentsOfFile:path];
//}
//+ (void)clearImageCacheOriginImageWhenBroswerFinishWith:(NSArray <HQBroswerModel *>*)models{
//    dispatch_queue_t queue = dispatch_queue_create("removeQueue", DISPATCH_QUEUE_CONCURRENT);
//    dispatch_async(queue, ^{
//        [[self imageCache] removeAllObjects];
//        for (HQBroswerModel *model in models) {
//            if (model.speakerId == [HQPublicManager shareManagerInstance].userinfoModel.userId) {
//                [[self imageCache] removeObjectForKey:model.fileName];
//            }else{
//                [[self imageCache] removeObjectForKey:model.fileName];
//            }
//        }
//    });
//}
//
//// 缩放，临时的方法
//+ (CGSize)handleImage:(CGSize)retSize{
//    CGFloat scaleH = 0.22;
//    CGFloat scaleW = 0.38;
//    CGFloat height = 0;
//    CGFloat width = 0;
//    if (retSize.height / APP_Frame_Height + 0.16 > retSize.width / App_Frame_Width) {
//        height = APP_Frame_Height * scaleH;
//        width = retSize.width / retSize.height * height;
//    } else {
//        width = App_Frame_Width * scaleW;
//        height = retSize.height / retSize.width * width;
//    }
//    return CGSizeMake(width*5, height*5);
//}
//
//+ (NSBundle *)bundle{
//    static NSBundle *bundle = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        bundle = [NSBundle mainBundle];
//    });
//    return bundle;
//}
//
//
//+ (UIImage *)imageWithNamed:(NSString *)name{
//    if (!name) return nil;
//    UIImage *image = [[self imageCache] objectForKey:name];
//    if (image) return image;
//    NSString *ext = name.pathExtension;
//    if (ext.length == 0) ext = @"png";
//    
//    NSString *path = [[self bundle] pathForScaledResource:name ofType:@"png"];
//    if (!path) return nil;
//    ///此处不使用 imageNamed  系统不会有缓存
//    image = [UIImage imageWithContentsOfFile:path];
//    ///把图片转成位图
//    image = [image imageByDecoded];
//    if(!image) return nil;
//    [[self imageCache] setObject:image forKey:name];
//    return image;
//}
//
//+ (UIImage *)imageWithPath:(NSString *)path {
//    if (!path) return nil;
//    UIImage *image = [[self imageCache] objectForKey:path];
//    if (image) return image;
//    if (path.pathScale == 1) {
//        // 查找 @2x @3x 的图片
//        NSArray *scales = [NSBundle preferredScales];
//        for (NSNumber *scale in scales) {
//            image = [UIImage imageWithContentsOfFile:[path stringByAppendingPathScale:scale.floatValue]];
//            if (image) break;
//        }
//    } else {
//        image = [UIImage imageWithContentsOfFile:path];
//    }
//    if (image) {
//        image = [image imageByDecoded];
//        [[self imageCache] setObject:image forKey:path];
//    }
//    return image;
//}
//


@end
