//
//  HQDownLoadTempModel.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/5/23.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQDownLoadTempModel.h"
#import "HQCFunction.h"


@implementation HQDownLoadTempModel

- (instancetype)init{
    self = [super init];
    if (self) {
        _status = HQDownLoadFileStatusNone;
        _totalBytesExpectedToWrite = 1;
    }
    return self;
}

- (NSOutputStream *)stream{
    if (_stream == nil) {
        _stream = [NSOutputStream outputStreamToFileAtPath:self.filePath append:YES];
    }
    return _stream;
}
- (NSString *)filePath{
    NSString *path = [cacheFolder() stringByAppendingPathComponent:self.fileName];
    if (![path isEqualToString:_filePath] ) {
        if (_filePath && ![[NSFileManager defaultManager] fileExistsAtPath:_filePath]) {
            NSString *dir = [_filePath stringByDeletingLastPathComponent];
            [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        _filePath = path;
    }
    return _filePath;
}
- (NSString *)fileName{
    if (_fileName == nil) {
        NSString *pathExtern = self.urlStr.pathExtension;
        if (pathExtern.length) {
            _fileName = [NSString stringWithFormat:@"%@.%@",getMd5String(self.urlStr),pathExtern];
        }else{
            _fileName = getMd5String(self.urlStr);
        }
    }
    return _fileName;
}
- (NSString *)trueName{
    if (_trueName == nil) {
        _trueName = self.urlStr.lastPathComponent;
    }
    return _trueName;
}
- (NSProgress *)progress{
    if (_progress == nil) {
        _progress = [[NSProgress alloc] initWithParent:nil userInfo:nil];
    }
    @try {
        _progress.totalUnitCount = self.totalBytesExpectedToWrite;
        _progress.completedUnitCount = self.totalBytesWritten;
    } @catch (NSException *exception) {
        
    }
    return _progress;
}
- (long long )totalBytesWritten{
    return fileSizeForPath(self.filePath);
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.urlStr = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(urlStr))];
        self.filePath = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(filePath))];
        self.fileName = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(fileName))];
        self.status = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(status))] unsignedIntegerValue];
        self.totalBytesWritten = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(totalBytesWritten))] unsignedIntegerValue];
        self.totalBytesExpectedToWrite = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(totalBytesExpectedToWrite))] unsignedIntegerValue];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.urlStr forKey:NSStringFromSelector(@selector(urlStr))];
    [aCoder encodeObject:self.fileName forKey:NSStringFromSelector(@selector(fileName))];
    [aCoder encodeObject:self.filePath forKey:NSStringFromSelector(@selector(filePath))];
    [aCoder encodeObject:@(self.status) forKey:NSStringFromSelector(@selector(status))];
    [aCoder encodeObject:@(self.totalBytesExpectedToWrite) forKey:NSStringFromSelector(@selector(totalBytesExpectedToWrite))];
    [aCoder encodeObject:@(self.totalBytesWritten) forKey:NSStringFromSelector(@selector(totalBytesWritten))];
}

+ (nonnull NSMutableDictionary * )allDownloadReceipts{
    @synchronized (@" ") {
        NSMutableDictionary *dictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:localReceiptPath()];
        return dictionary;
    }
}
+ (void)saveModels:(NSMutableDictionary *)dic{
    @synchronized (@" ") {
        BOOL result = [NSKeyedArchiver archiveRootObject:dic toFile:localReceiptPath()];
        if (result) {
            NSLog(@"保存成功");
        }else{
            NSLog(@"保存失败");
        }
    }
}
+ (void)UpdateModel:(NSMutableDictionary *)diction andComlite:(void (^)(BOOL result))complite{
    @synchronized (@" ") {
        NSMutableDictionary *dic = [HQDownLoadTempModel allDownloadReceipts];
        for (NSString *urlStr in diction.allKeys) {
            HQDownLoadTempModel *model = [diction objectForKey:urlStr];
            [dic setObject:model forKey:urlStr];
        }
        BOOL result = [NSKeyedArchiver archiveRootObject:dic toFile:localReceiptPath()];
        if (result) {
            if (complite) complite(YES);
        }else{
            if (complite) complite(NO);
        }
    }
}
+ (void)DeleteModel:(HQDownLoadTempModel * _Nonnull )model andComplite:(void (^ _Nullable) (BOOL result))complite{
    @synchronized (@" ") {
        dispatch_queue_t queue = dispatch_queue_create("delete", DISPATCH_QUEUE_CONCURRENT);
        dispatch_async(queue, ^{
            NSMutableDictionary *dic = [HQDownLoadTempModel allDownloadReceipts];
            HQDownLoadTempModel *mo = [dic objectForKey:model.urlStr];
            if (mo == nil) return;
            [dic removeObjectForKey:model.urlStr];
            BOOL result = [NSKeyedArchiver archiveRootObject:dic toFile:localReceiptPath()];
            [[NSFileManager defaultManager] removeItemAtPath:mo.filePath error:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (result) {
                    if (complite) complite(YES);
                }else{
                    if (complite) complite(NO);
                }
            });
        });
    }
}

@end
