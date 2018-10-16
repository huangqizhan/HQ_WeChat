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


static UIImage *_failedImage;

@interface HQLocalImageManager ()

@property (nonatomic,strong) NSCache *vidioImageCache;
@property (nonatomic,strong) NSCache *imageCacheMe;
@property (nonatomic,strong) NSCache *imageCacheOther;

@end

@implementation HQLocalImageManager


+ (instancetype)shareImageManager{
    static HQLocalImageManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HQLocalImageManager alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:manager selector:@selector(clearImageCache) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        _failedImage  = [UIImage imageNamed:@"icon_album_picture_fail_big"];

    });
    return manager;
}
- (void)clearImageCache{
    [self.vidioImageCache removeAllObjects];
    [self.imageCacheMe removeAllObjects];
    [self.imageCacheOther removeAllObjects];
}

/**
 获取我的尖头图片

 @param imageName 图片名
 
 */
- (void)getArrowMeImageName:(NSString *)imageName complite:(void (^)(UIImage *image))complite{
    if (imageName == nil) {
        if (complite) complite( nil);
    }
    NSString *filePath = [[self creatFileAtPath:ArrowPicMe] stringByAppendingPathComponent:imageName];
    if ([self.imageCacheMe objectForKey:imageName]) {
        UIImage *im = [self.imageCacheMe objectForKey:imageName];
        if (complite) complite(im);
        return;
    }
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    if (image) {
        [self.imageCacheMe setObject:image forKey:imageName];
    }else{
        image = _failedImage;
    }
    if (complite) complite(image);
}

/**
 获取他人尖头图片

 @param imageName 图片名
 @return 图片
 */
- (UIImage *)getArrowOtherImageName:(NSString *)imageName{
    if (imageName == nil) {
        return nil;
    }
    NSString *filePath = [[self creatFileAtPath:ArrowPicOther] stringByAppendingPathComponent:imageName];
    if ([self.imageCacheOther objectForKey:imageName]) {
        return [self.imageCacheOther objectForKey:imageName];
    }
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    if (image) {
        [self.imageCacheOther setObject:image forKey:imageName];
    }else{
        image = _failedImage;
    }
    return image;
}

/**
 聊天界面压缩后的图片   界面显示
 
 @param imageName 图片名
 
 */
- (void)getChatMineMessageImageWtihImageName:(NSString *)imageName withImageSize:(CGSize)imageSize andComplite:(void (^)(UIImage *))complite{
    dispatch_queue_t queue = dispatch_queue_create("readImage", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        if (imageName == nil) {
            if (complite) complite(nil);
        }
        NSString *filePath = [[self creatFileAtPath:ArrowPicMe] stringByAppendingPathComponent:imageName];
        if ([self.imageCacheMe objectForKey:imageName]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (complite) complite([self.imageCacheMe objectForKey:imageName]);
                return ;
            });
        }
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        //    image = [UIImage makeArrowImageWithSize:imageSize image:image isSender:YES];
        image = [UIImage needCompressImage:image size:imageSize scale:0.5];
        if (image) {
            [self.imageCacheMe setObject:image forKey:imageName];
        }else{
            image = _failedImage;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complite) complite(image);
        });
    });
}
- (UIImage *)getChatMineMessageImageWtihImageName:(NSString *)imageName withImageSize:(CGSize)imageSize{
    if (imageName == nil) {
        return nil;
    }
    NSString *filePath = [[self creatFileAtPath:ArrowPicMe] stringByAppendingPathComponent:imageName];
    if ([self.imageCacheMe objectForKey:imageName]) {
        return  [self.imageCacheMe objectForKey:imageName];
    }
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    //    image = [UIImage makeArrowImageWithSize:imageSize image:image isSender:YES];
    image = [UIImage needCompressImage:image size:imageSize scale:0.2];
    return image;
}
/**
 聊天界面压缩后的图片他人   界面显示
 @param imageName 图片名
 @param imageSize 压缩的尺寸
 @return 图片
 */
- (UIImage *)getChatOtherMessageImageWtihImageName:(NSString *)imageName withImageSize:(CGSize)imageSize{
    if (imageName == nil) {
        return nil;
    }
    NSString *filePath = [[self creatFileAtPath:ArrowPicOther] stringByAppendingPathComponent:imageName];
    if ([self.imageCacheOther objectForKey:imageName]) {
        return [self.imageCacheOther objectForKey:imageName];
    }
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
//    image = [UIImage makeArrowImageWithSize:imageSize image:image isSender:NO];
    image = [UIImage needCompressImage:image size:imageSize scale:0.2];
    return image;
}
/**
 删除我的尖头图片

 @param imageName 图片名
 */
- (void)removoeMeImageFromSandBoxWith:(NSString *)imageName{
    if (imageName == nil) {
        return;
    }
    NSString *filePath = [[self creatFileAtPath:ArrowPicMe] stringByAppendingPathComponent:imageName];
    if ([self.imageCacheMe objectForKey:imageName]) {
        [self.imageCacheMe removeObjectForKey:imageName];
    }
    [self removeFileAtPath:filePath];
}

/**
 删除我的尖头图片
 
 @param imageName 图片名
 */
- (void)removoeOtherImageFromSandBoxWith:(NSString *)imageName{
    if (imageName == nil) {
        return;
    }
    NSString *filePath = [[self creatFileAtPath:ArrowPicOther] stringByAppendingPathComponent:imageName];
    if ([self.imageCacheOther objectForKey:imageName]) {
        [self.imageCacheOther removeObjectForKey:imageName];
    }
    [self removeFileAtPath:filePath];
}

/**
 保存图片到沙盒 library Chat/MyPic

 @param image  保存的图片
 @param fileName  图片名称
 @return 路径
 */
- (NSString *)saveArrowOtherToSandBox:(UIImage *)image
                         withFileName:(NSString *)fileName
                         andImageSize:(CGSize)imageSize
                          andIsSender:(BOOL)isSender{
//    image = [UIImage makeArrowImageWithSize:imageSize image:image isSender:isSender];
   [self.imageCacheOther setObject:image forKey:fileName];
   NSString *filePath = [[self creatFileAtPath:MyPic] stringByAppendingPathComponent:fileName];
   NSData *imageData  = UIImagePNGRepresentation(image);
   BOOL isSave = [imageData writeToFile:filePath atomically:NO];
    if (!isSave) {
        NSLog(@"保存失败");
    }
    return filePath;
}

/**
 保存我的图片

 @param image 图片
 @param fileName 图片名
 @return 图片保存路径
 */
- (NSString *)saveArrowMeToSandBox:(UIImage *)image
                      withFileName:(NSString *)fileName
                      andImageSize:(CGSize)imageSize
                       andIsSender:(BOOL)isSender{
    
    NSString *filePath = [[self creatFileAtPath:ArrowPicMe] stringByAppendingPathComponent:fileName];
    image = [UIImage makeArrowImageWithSize:imageSize image:image isSender:isSender];
    [self.imageCacheMe setObject:image forKey:fileName];
    NSData *imageData = UIImagePNGRepresentation(image);
    BOOL isSave = [imageData writeToFile:filePath atomically:NO];
    if (!isSave) {
        NSLog(@"保存失败");
    }
    return filePath;
}

- (void)saveImage:(UIImage *)image andFileName:(NSString *)iamgeName{
    dispatch_queue_t queue = dispatch_queue_create("saveImageQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        NSString *filePath = [[self creatFileAtPath:ArrowPicMe] stringByAppendingPathComponent:iamgeName];
        NSData *imageData = UIImagePNGRepresentation(image);
        BOOL isSave = [imageData writeToFile:filePath atomically:NO];
        if (!isSave) {
            NSLog(@"保存失败");
        }
    });
}


////创建文件
- (NSString *)creatFileAtPath:(NSString *)path{
    
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:path];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:filePath]) {
        BOOL isCreat = [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
        if (!isCreat) {
            NSLog(@"creat file faild");
            return nil;
        }
    }
    return filePath;
}
///// pricate
- (void)removeFileAtPath:(NSString *)path{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        BOOL isRemove = [fileManager removeItemAtPath:path error:nil];
        if (!isRemove) {
            NSLog(@"remove faild");
        }else{
            NSLog(@"remove success");
        }
    }
}
- (void)saveChatBegImage:(UIImage *)begImage withFileName:(NSString *)fileName  andScale:(CGFloat )scale andComplite:(void (^)(BOOL resukt))complite{
    NSString *filePath = [[self creatFileAtPath:MyPic] stringByAppendingPathComponent:fileName];
    dispatch_queue_t queue = dispatch_queue_create("saveQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        [self removeFileAtPath:filePath];
        if ([self.imageCacheOther objectForKey:fileName]) {
            [self.imageCacheOther removeObjectForKey:fileName];
        }
        UIImage *image = [UIImage needCompressImage:begImage size:begImage.size scale:scale];
        NSData *imageData = UIImagePNGRepresentation(image);
        BOOL isSave = [imageData writeToFile:filePath atomically:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complite) {
                complite(isSave);
            }
        });
    });
}
- (void)removeChatBegImageWith:(NSString *)fileName{
    dispatch_queue_t queue = dispatch_queue_create("removeBeg", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        NSString *filePath = [[self creatFileAtPath:MyPic] stringByAppendingPathComponent:fileName];
        [self removeFileAtPath:filePath];
    });
    
}
- (UIImage *)getChatBegImageWith:(NSString *)fileName{
    if (fileName == nil) {
        return nil;
    }
    NSString *filePath = [[self creatFileAtPath:MyPic] stringByAppendingPathComponent:fileName];
    if ([self.imageCacheOther objectForKey:fileName]) {
        return [self.imageCacheOther objectForKey:fileName];
    }
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    if (image) {
        [self.imageCacheOther setObject:image forKey:fileName];
    }else{
        image = nil;
    }
    return image;
}

- (UIImage *)compocessImageWithImage:(UIImage *)image andImageSize:(CGSize)imageSize andIsSender:(BOOL)IsSender{
//    image = [UIImage makeArrowImageWithSize:imageSize image:image isSender:IsSender];
    image = [UIImage needCompressImage:image size:imageSize scale:0.2];
    return image;
}

- (UIImage *)loadlocalGifImageWith:(NSString *)fileName andScal:(CGFloat)scal{
    NSString *path = [[NSBundle mainBundle]pathForResource:fileName ofType:@"gif"];
    NSData *data = [NSData dataWithContentsOfFile:path];
//    UIImage *image = [UIImage yy_imageWithSmallGIFData:data scale:2];
    return nil;
}
- (NSData *)loadLocalGifImageDataWith:(NSString *)fileName{
    NSString *path = [[NSBundle mainBundle]pathForResource:fileName ofType:@"gif"];
    return [NSData dataWithContentsOfFile:path];
}
- (void)clearImageCacheOriginImageWhenBroswerFinishWith:(NSArray <HQBroswerModel *>*)models{
    dispatch_queue_t queue = dispatch_queue_create("removeQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        [self.imageCacheMe removeAllObjects];
        [self clearImageCache];
        for (HQBroswerModel *model in models) {
            if (model.speakerId == [HQPublicManager shareManagerInstance].userinfoModel.userId) {
                [self.imageCacheMe removeObjectForKey:model.fileName];
            }else{
                [self.imageCacheOther removeObjectForKey:model.fileName];
            }
        }
    });
}

// 缩放，临时的方法
- (CGSize)handleImage:(CGSize)retSize{
    CGFloat scaleH = 0.22;
    CGFloat scaleW = 0.38;
    CGFloat height = 0;
    CGFloat width = 0;
    if (retSize.height / APP_Frame_Height + 0.16 > retSize.width / App_Frame_Width) {
        height = APP_Frame_Height * scaleH;
        width = retSize.width / retSize.height * height;
    } else {
        width = App_Frame_Width * scaleW;
        height = retSize.height / retSize.width * width;
    }
    return CGSizeMake(width*5, height*5);
}

- (NSCache *)vidioImageCache{
    if (_vidioImageCache == nil) {
        _vidioImageCache = [[NSCache alloc] init];
    }
    return _vidioImageCache;
}
- (NSCache *)imageCacheMe{
    if (_imageCacheMe == nil) {
        _imageCacheMe = [[NSCache alloc] init];
    }
    return _imageCacheMe;
}
- (NSCache *)imageCacheOther{
    if (_imageCacheOther == nil) {
        _imageCacheOther = [[NSCache alloc] init];
    }
    return _imageCacheOther;
}
@end
