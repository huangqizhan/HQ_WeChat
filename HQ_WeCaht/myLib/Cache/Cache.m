//
//  Cache.m
//  YYStudy
//
//  Created by hqz  QQ 757618403 on 2018/5/24.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//

#import "Cache.h"




@implementation Cache

- (instancetype) init {
    NSLog(@"Use \"initWithName\" or \"initWithPath\" to create YYCache instance.");
    return [self initWithPath:@""];
}
- (instancetype)initWithName:(NSString *)name{
    if (name.length <= 0 ) return nil;
    NSString *cacheFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [cacheFolder stringByAppendingPathComponent:name];
    return [self initWithPath:filePath];
}

+ (instancetype)cacheWithName:(NSString *)name{
    return [[self alloc] initWithName:name];
}
+ (instancetype)cacheWithPath:(NSString *)path{
    return [[self alloc] initWithPath:path];
}
- (instancetype)initWithPath:(NSString *)path {
    if (path.length == 0) return nil;
    DiskCache *diskCache = [[DiskCache alloc] initWithPath:path];
    if (!diskCache) return nil;
    NSString *name = [path lastPathComponent];
    MemoryCache *memoryCache = [MemoryCache new];
    memoryCache.name = name;
    
    _diskCache = diskCache;
    self = [super init];
    return self;
}
@end
