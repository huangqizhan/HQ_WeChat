//
//  HQFileTools.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/30.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQFileTools.h"

#define ChildPath @"Chat/File"

@implementation HQFileTools

+ (NSString *)cacheDirectory{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString *)creatSubDirectoryWith:(NSString *)subDirectory{
    NSString *path = [[self cacheDirectory] stringByAppendingPathComponent:subDirectory];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExit = [fileManager fileExistsAtPath:path];
    if (!isExit) {
       BOOL isCreat = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if (!isCreat) {
            NSLog(@"creat file faild");
        }
    }
    return path;
}
- (BOOL)fileExitAtFilePath:(NSString *)filePath{
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

+ (BOOL)removeFileAtFilePath:(NSString *)filePath{
    return [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}

+ (NSString *)filePathWithFileName:(NSString *)fileKey
                           orgName:(NSString *)name
                              type:(NSString *)type{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:ChildPath];
    BOOL isExit = [[NSFileManager defaultManager] fileExistsAtPath:path];
    if (!isExit) {
        BOOL isCreat = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if (!isCreat) {
            NSLog(@"create file faild");
            return nil;
        }
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.%@",fileKey,name,type]];
    return path;
}
+ (NSString *)fileMainPath{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:ChildPath];
    BOOL isExit = [[NSFileManager defaultManager] fileExistsAtPath:path];
    if (!isExit) {
        BOOL isCreat = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if (!isCreat) {
            NSLog(@"create file faild");
            return nil;
        }
    }
    return path;
}
/////返回字节数
+ (CGFloat)fileSizeAtFilePath:(NSString *)filePath{
    NSDictionary *attrubutes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    return [attrubutes fileSize]/1024;
}
//// 小于1024 显示 显示KB 大于1024 显示BM
+ (NSString *)fileSize:(NSString *)path{
    CGFloat fileSize = [self fileSizeAtFilePath:path];
    if (fileSize < 1024) {
        return [NSString stringWithFormat:@"%fKB",fileSize];
    }else{
        return [NSString stringWithFormat:@"%fMB",fileSize/1024];
    }
}

+ (void)clearUserDefault{
    NSDictionary *diction = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    NSArray *allKeys  = [diction allKeys];
    for (NSString *key in allKeys) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
////copy   File
+ (BOOL)copyFromPath:(NSString *)fromPath toPath:(NSString *)toPath{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager copyItemAtPath:fromPath toPath:toPath error:nil];
    if (!result) {
        NSLog(@"copy file Faild");
    }
    return result;
}


+ (NSString *)homeDirectory {
    return NSHomeDirectory();
}

+ (NSString *)documentDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    
    return docDir;
}

+ (NSString *)cacheDirectory1 {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDir = [paths objectAtIndex:0];
    
    return cachesDir;
}

+ (NSString *)tmpDirectory {
    NSString *tmpDir = NSTemporaryDirectory();
    return tmpDir;
}


+ (UIStoryboard *)mainStoryboard {
    static UIStoryboard *mainStoyboard;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //        NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
        //        NSString *mainName = infoDic[@"UIMainStoryboardFile"];
        
        NSString *mainName = @"Main";
        
        mainStoyboard = [UIStoryboard storyboardWithName:mainName bundle:nil];
    });
    
    return mainStoyboard;
}

+ (NSURL *)createFolderWithName:(NSString *)folderName inDirectory:(NSString *)directory {
    NSString *path = [directory stringByAppendingPathComponent:folderName];
    NSURL *folderURL = [NSURL URLWithString:path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:path]) {
        NSError *error;
        [fileManager createDirectoryAtPath:path
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&error];
        if (!error) {
            return folderURL;
        }else {
            NSLog(@"创建文件失败 %@", error.localizedFailureReason);
            return nil;
        }
        
    }
    return folderURL;
}


+ (NSString*)dataPath {
    static NSString *_dataPath;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dataPath = [NSString stringWithFormat:@"%@/audioFile", [self tmpDirectory]];
    });
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:_dataPath]){
        [fm createDirectoryAtPath:_dataPath
      withIntermediateDirectories:YES
                       attributes:nil
                            error:nil];
    }
    
    return _dataPath;
}


+ (void)removeFileAtPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        [fileManager removeItemAtPath:path error:&error];
        if (error) {
            NSLog(@"failed to remove file, error:%@.", error);
        }
    }
}

+ (void)writeImageAtPath:(NSString *)path image:(UIImage *)image {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createFileAtPath:path contents:UIImageJPEGRepresentation(image, 1) attributes:nil];
}


+ (unsigned long long)getFileSize:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    unsigned long long fileSize = 0;
    if ([fileManager fileExistsAtPath:path]) {
        NSDictionary *fileDic = [fileManager attributesOfItemAtPath:path error:nil];//获取文件的属性
        fileSize = [[fileDic objectForKey:NSFileSize] longLongValue];
    }
    return fileSize;
}


@end
