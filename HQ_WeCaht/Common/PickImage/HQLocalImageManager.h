//
//  HQLocalImageManager.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/22.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ArrowPicMe @"Chat/ArrowMe"

#define ArrowPicOther @"Chat/ArrowOther"

#define MyPic @"Chat/MyPic"

#define VodioPic @"Chat/VodioPic"


#import "HQBroswerModel.h"



@interface HQLocalImageManager : NSObject

+ (instancetype)shareImageManager;



/**
 保存图片到沙盒 library Chat/MyPic
 
 @param image  保存的图片
 @param fileName  图片名称
 @return 路径
 */
- (NSString *)saveArrowOtherToSandBox:(UIImage *)image
                         withFileName:(NSString *)fileName
                         andImageSize:(CGSize)imageSize
                          andIsSender:(BOOL)isSender;


/**
 保存我的图片
 
 @param image 图片
 @param fileName 图片名
 @return 图片保存路径
 */
- (NSString *)saveArrowMeToSandBox:(UIImage *)image
                      withFileName:(NSString *)fileName
                      andImageSize:(CGSize)imageSize
                       andIsSender:(BOOL)isSender;


/**
 保存图片

 @param image 图片
 @param iamgeName 图片名
 */
- (void) saveImage:(UIImage *)image andFileName:(NSString *)iamgeName;
/**
 获取我的尖头图片
 
 @param imageName 图片名
 
 */
- (void)getArrowMeImageName:(NSString *)imageName complite:(void (^)(UIImage *image))complite;

/**
 获取他人尖头图片
 
 @param imageName 图片名
 @return 图片
 */
- (UIImage *)getArrowOtherImageName:(NSString *)imageName;



/**
 聊天界面压缩后的图片我的   界面显示

 @param imageName 图片名
 @param imageSize 图片尺寸
 
 */
- (void )getChatMineMessageImageWtihImageName:(NSString *)imageName withImageSize:(CGSize)imageSize andComplite:(void (^)(UIImage *))complite;


- (UIImage * )getChatMineMessageImageWtihImageName:(NSString *)imageName withImageSize:(CGSize)imageSize;
/**
 聊天界面压缩后的图片他人   界面显示

 @param imageName 图片名
 @param imageSize 压缩的尺寸
 @return 图片
 */
- (UIImage *)getChatOtherMessageImageWtihImageName:(NSString *)imageName withImageSize:(CGSize)imageSize;
/**
 删除我的尖头图片
 
 @param imageName 图片名
 */
- (void)removoeMeImageFromSandBoxWith:(NSString *)imageName;


/**
 删除他的尖头图片
 
 @param imageName 图片名
 */
- (void)removoeOtherImageFromSandBoxWith:(NSString *)imageName;

/////清除缓存
- (void)clearImageCache;

- (UIImage *)compocessImageWithImage:(UIImage *)image andImageSize:(CGSize)imageSize andIsSender:(BOOL)IsSender;


/**
 获取本地GIF文件
 
 @param fileName 文件名
 @param scal 你弄
 */
- (UIImage *)loadlocalGifImageWith:(NSString *)fileName andScal:(CGFloat)scal ;



/**
 获取GIFdata
 
 @param fileName 文件名
 @return data
 */
- (NSData *)loadLocalGifImageDataWith:(NSString *)fileName;


//保存聊天背景图片
- (void)saveChatBegImage:(UIImage *)begImage withFileName:(NSString *)fileName  andScale:(CGFloat )scale andComplite:(void (^)(BOOL result))complite;


///获取聊天背景图片
- (UIImage *)getChatBegImageWith:(NSString *)fileName;

///移除聊天背景
- (void)removeChatBegImageWith:(NSString *)fileName;

/**
 浏览大图结束之后 清除大图
 */
- (void)clearImageCacheOriginImageWhenBroswerFinishWith:(NSArray <HQBroswerModel *>*)models;

@end
