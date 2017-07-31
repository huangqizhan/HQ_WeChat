//
//  HQCFunction.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/5/23.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#ifndef HQCFunction_h
#define HQCFunction_h
#import <CommonCrypto/CommonDigest.h>

/**
 创建文件下载 文件夹路径  documnet 下
 
 @return 路径
 */
static NSString *cacheFolder(){
    NSFileManager *fileManager = [NSFileManager defaultManager];
    static NSString *cacherFolder;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!cacherFolder) {
            NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).firstObject;
            cacherFolder = [cacheDir stringByAppendingPathComponent:HQDownLoadFileCache];
        }
        NSError *error;
        if (![fileManager createDirectoryAtPath:cacherFolder withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"creatr file %@ faild",cacherFolder);
            cacherFolder = nil;
        }
    });
    return cacherFolder;
}

/**
 解归档文件路径
 
 @return 路径
 */
static NSString *localReceiptPath(){
    return  [cacheFolder() stringByAppendingPathComponent:@"receipt.data"];
}

/**
 获取文件大小
 
 @param filePath 文件路径
 @return 文件大小
 */
static unsigned long long fileSizeForPath(NSString *filePath){
    unsigned long long fileSize = 0;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSError *error;
        NSDictionary *attrubute = [fileManager attributesOfItemAtPath:filePath error:&error];
        fileSize = [attrubute fileSize];
    }
    return fileSize;
}

/**
 MD5加密
 
 @param contentStr 数据源
 @return 加密结果
 */

static NSString * getMd5String(NSString *contentStr){
    
    if(contentStr == nil) return nil;
    const char *cstring = [contentStr UTF8String];
    unsigned char bytes [CC_MD5_DIGEST_LENGTH];
    CC_MD5(cstring, (CC_LONG)strlen(cstring), bytes);
    NSMutableString *resultStr = [NSMutableString new];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [resultStr appendFormat:@"%02x",bytes[i]];
    }
    return resultStr;
}



#endif /* HQCFunction_h */
