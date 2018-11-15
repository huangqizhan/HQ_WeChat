//
//  HQFileTools.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/30.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HQFileTools : NSObject

//// 路径  library/cache
+ (NSString *)cacheDirectory;


////创建 library/cache 下 的子路径
+ (NSString *)creatSubDirectoryWith:(NSString *)subDirectory;

////// 删除 文件
+ (BOOL)removeFileAtFilePath:(NSString *)filePath;

/////文件路径
+ (NSString *)filePathWithFileName:(NSString *)fileKey
                           orgName:(NSString *)name
                              type:(NSString *)type;
/////文件主路径
+ (NSString *)fileMainPath;

/////返回字节数
+ (CGFloat)fileSizeAtFilePath:(NSString *)filePath;

/////清除所有的NSUserDefault
+ (void)clearUserDefault;

/////复制文件
+ (BOOL)copyFromPath:(NSString *)fromPath toPath:(NSString *)toPath;

+ (NSString *)homeDirectory;

+ (NSString *)documentDirectory;


+ (NSString *)tmpDirectory;

+ (UIStoryboard *)mainStoryboard;

+ (NSURL *)createFolderWithName:(NSString *)folderName inDirectory:(NSString *)directory;

+ (NSString *)dataPath;

+ (void)removeFileAtPath:(NSString *)path;

+ (void)writeImageAtPath:(NSString *)path image:(UIImage *)image;

/**
 *  返回文件大小，单位为字节
 */
+ (unsigned long long)getFileSize:(NSString *)path;

+ (void)SetUserDefault:(id)value forKey:(NSString *)key;
+ (id)GetUserDefaultWithKey:(NSString *)key;



@end
