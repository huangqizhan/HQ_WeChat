//
//  DiskCache.m
//  YYStudy
//
//  Created by hqz on 2018/5/24.
//  Copyright © 2018年 hqz. All rights reserved.
//

#import "DiskCache.h"
#import "KVStorage.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <CommonCrypto/CommonCrypto.h>


#define Lock() dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER)
#define Unlock() dispatch_semaphore_signal(self->_lock)

static const int extended_data_key;

///磁盘剩余空间的大小 bytes
static int64_t diskSpaceFree(){
    NSError *error = nil;
    NSDictionary *fileAtt = [[NSFileManager defaultManager] attributesOfItemAtPath:NSHomeDirectory() error:&error];
    if (error) return - 1;
    int64_t space = [[fileAtt objectForKey:NSFileSystemFreeSize] longLongValue];
    if (space < 0) {
        return -1;
    }
    return space;
}
/// String's md5 hash.
static NSString *_YYNSStringMD5(NSString *string) {
    if (!string) return nil;
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (CC_LONG)data.length, result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0],  result[1],  result[2],  result[3],
            result[4],  result[5],  result[6],  result[7],
            result[8],  result[9],  result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

///mapTable  对所有的value 弱引用
static NSMapTable *_globslInstances;
static dispatch_semaphore_t _globalInstanceLock;

static void diskCacheInitGlobal(){
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _globalInstanceLock = dispatch_semaphore_create(1);
        _globslInstances = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory capacity:0];
    });
}

static DiskCache * diskCacheGetGlobal(NSString *path){
    if (path.length == 0) return nil;
    diskCacheInitGlobal();
    dispatch_semaphore_wait(_globalInstanceLock, DISPATCH_TIME_FOREVER);
    id cache = [_globslInstances objectForKey:path];
    dispatch_semaphore_signal(_globalInstanceLock);
    return cache;
}

static void diskCacheSetGlobal(DiskCache *cache){
    if (cache.path.length == 0) return;
    diskCacheInitGlobal();
    dispatch_semaphore_wait(_globalInstanceLock, DISPATCH_TIME_FOREVER);
    [_globslInstances setObject:cache forKey:cache.path];
    dispatch_semaphore_signal(_globalInstanceLock);
}

@implementation DiskCache {
    KVStorage *_kv;
    dispatch_semaphore_t _lock;
    dispatch_queue_t _queue;
}
- (void)_trimRecursively {
    __weak typeof(self) _self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_autoTrimInterval * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        __strong typeof(_self) self = _self;
        if (!self) return;
        [self _trimInBackground];
        [self _trimRecursively];
    });

}

- (void)_trimInBackground {
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) self = _self;
        if (!self) return;
        Lock();
        [self _trimToCost:self.costLimit];
        [self _trimToCount:self.countLimit];
        [self _trimToAge:self.ageLimit];
        [self _trimToFreeDiskSpace:self.freeDiskSpaceLimit];
        Unlock();
    });
}

- (void)_trimToCost:(NSUInteger)costLimit {
    if (costLimit >= INT_MAX) return;
    [_kv removeItemsToFitSize:(int)costLimit];
    
}

- (void)_trimToCount:(NSUInteger)countLimit {
    if (countLimit >= INT_MAX) return;
    [_kv removeItemsToFitCount:(int)countLimit];
}
- (void)_trimToAge:(NSTimeInterval)ageLimit {
    if (ageLimit <= 0) {
        [_kv removeAllItems];
        return;
    }
    long timestamp = time(NULL);
    if (timestamp <= ageLimit) return;
    long age = timestamp - ageLimit;
    if (age >= INT_MAX) return;
    [_kv removeItemsEarlierThanTime:(int)age];
}

- (void)_trimToFreeDiskSpace:(NSUInteger)targetFreeDiskSpace {
    if (targetFreeDiskSpace == 0) return;
    int64_t totalBytes = [_kv getItemsSize];
    if (totalBytes <= 0) return;
    int64_t diskFreeBytes = diskSpaceFree();
    if (diskFreeBytes < 0) return;
    int64_t needTrimBytes = targetFreeDiskSpace - diskFreeBytes;
    if (needTrimBytes <= 0) return;
    int64_t costLimit = totalBytes - needTrimBytes;
    if (costLimit < 0) costLimit = 0;
    [self _trimToCost:(int)costLimit];
}
- (void)_appWillBeTerminated {
    Lock();
    _kv = nil;
    Unlock();
}
- (NSString *)filenameForKey:(NSString *)key {
    NSString *filename = nil;
    if (_customFileNameBlock) filename = _customFileNameBlock(key);
    if (!filename) filename = _YYNSStringMD5(key);
        //.md5String;
    return filename;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"YYDiskCache init error" reason:@"YYDiskCache must be initialized with a path. Use 'initWithPath:' or 'initWithPath:inlineThreshold:' instead." userInfo:nil];
    return [self initWithPath:@"" inlineThreshold:0];
}

- (instancetype)initWithPath:(NSString *)path {
    return [self initWithPath:path inlineThreshold:1024 * 20]; // 20KB
}
- (instancetype)initWithPath:(NSString *)path
             inlineThreshold:(NSUInteger)threshold {
    self = [super init];
    if (!self) return nil;
    
    DiskCache *globalCache = diskCacheGetGlobal(path);
    if (globalCache) return globalCache;
    
    KVStorageType type;
    if (threshold == 0) {
        type = KVStorageTypeFile;
    } else if (threshold == NSUIntegerMax) {
        type = KVStorageTypeSQLite;
    } else {
        type = KVStorageTypeMixed;
    }
    
    KVStorage *kv = [[KVStorage alloc] initWithPath:path type:type];
    if (!kv) return nil;
    
    _kv = kv;
    _path = path;
    _lock = dispatch_semaphore_create(1);
    _queue = dispatch_queue_create("com.ibireme.cache.disk", DISPATCH_QUEUE_CONCURRENT);
    _inlineThreshold = threshold;
    _countLimit = NSUIntegerMax;
    _costLimit = NSUIntegerMax;
    _ageLimit = DBL_MAX;
    _autoTrimInterval = 60;
    
    [self _trimRecursively];
    diskCacheSetGlobal(self);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_appWillBeTerminated) name:UIApplicationWillTerminateNotification object:nil];
    return self;
}
- (BOOL)containsObjectForKey:(NSString *)key {
    if (!key) return NO;
    Lock();
    BOOL contains = [_kv itemExistsForKey:key];
    Unlock();
    return contains;
}
- (void)containsObjectForKey:(NSString *)key withBlock:(void(^)(NSString *key, BOOL contains))block {
    if (!block) return;
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) self = _self;
        BOOL contains = [self containsObjectForKey:key];
        block(key, contains);
    });
}
- (id<NSCoding>)objectForKey:(NSString *)key{
    if (key.length == 0) return nil;
    Lock();
    KVStorageItem *item = [_kv getItemForKey:key];
    Unlock();
    if (!item.value) return nil;
    id object = nil;
    if (_customUnarchiveBlock) {
        object = _customUnarchiveBlock(item.value);
    }else{
        @try {
            object = [NSKeyedUnarchiver unarchiveObjectWithData:item.value];
        } @catch (NSException *exception) {
            ////No
        }
    }
    if (object && item.extendedData) {
        [self.class setExtendedData:item.extendedData toObject:object];
    }
     return object;
}
- (void)objectForKey:(NSString *)key withBlock:(void(^)(NSString *key, id<NSCoding> object))block{
    if (!block || !key) return;
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof (_self) self = _self;
        id <NSCoding> object = [self objectForKey:key];
        if (object) {
            block(key,object);
        }
    });
}
- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key{
    if(!object || key.length == 0) return;
    NSData *extendData = [self.class getExtendedDataFromObject:object];
    NSData *value = nil;
    if (_customArchiveBlock) {
        value = _customArchiveBlock(object);
    }else{
        @try {
            value = [NSKeyedArchiver archivedDataWithRootObject:object];
        } @catch (NSException *exception) {
            ///NO
        }
    }
    if (!value) return;
    NSString *fileName = nil;
    if (_kv.type != KVStorageTypeSQLite) {
        if (value.length > _inlineThreshold) {
            fileName = [self filenameForKey:key];
        }
    }
    Lock();
    [_kv saveItemWithKey:key value:value filename:fileName extendedData:extendData];
    Unlock();
}
- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key withBlock:(void (^)(void))block{
    if(!block || key.length == 0 || !object) return;
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) self = _self;
        [self setObject:object forKey:key];
        block();
    });
}
- (void)removeObjectForKey:(NSString *)key{
    if (!key) return;
    Lock();
    [_kv removeItemForKey:key];
    Unlock();
}
- (void)removeObjectForKey:(NSString *)key withBlock:(void(^)(NSString *))block{
    if (!block || key.length == 0) return;
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) self = _self;
        [self removeObjectForKey:key];
        block(key);
    });
}
- (void)removeAllObjects{
    Lock();
    [_kv removeAllItems];
    Unlock();
}
- (void)removeAllObjectsWithProgressBlock:(void(^)(int removedCount, int totalCount))progress endBlock:(void(^)(BOOL error))end{
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) self = _self;
        if (!self) {
            end(YES);
            return ;
        }
        Lock();
        [_kv removeAllItemsWithProcessBlock:progress endBlock:end];
        Unlock();
    });
}
- (NSInteger)totalCount{
    Lock();
    int count = [_kv getItemsCount];
    Unlock();
    return count;
}
- (void)totalCountWithBlock:(void(^)(NSInteger totalCount))block {
    if (!block) return;
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) self = _self;
        NSInteger totalCount = [self totalCount];
        block(totalCount);
    });
}
- (NSInteger)totalCost {
    Lock();
    int count = [_kv getItemsSize];
    Unlock();
    return count;
}

- (void)totalCostWithBlock:(void(^)(NSInteger totalCost))block {
    if (!block) return;
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) self = _self;
        NSInteger totalCost = [self totalCost];
        block(totalCost);
    });
}
- (void)trimToCount:(NSUInteger)count {
    Lock();
    [self _trimToCount:count];
    Unlock();
}

- (void)trimToCount:(NSUInteger)count withBlock:(void(^)(void))block {
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) self = _self;
        [self trimToCount:count];
        if (block) block();
    });
}
- (void)trimToCost:(NSUInteger)cost {
    Lock();
    [self _trimToCost:cost];
    Unlock();
}

- (void)trimToCost:(NSUInteger)cost withBlock:(void(^)(void))block {
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) self = _self;
        [self trimToCost:cost];
        if (block) block();
    });
}
- (void)trimToAge:(NSTimeInterval)age {
    Lock();
    [self _trimToAge:age];
    Unlock();
}

- (void)trimToAge:(NSTimeInterval)age withBlock:(void(^)(void))block {
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) self = _self;
        [self trimToAge:age];
        if (block) block();
    });
}

+ (NSData *)getExtendedDataFromObject:(id)object{
    if (!object) return nil;
    return (NSData *)objc_getAssociatedObject(object, &extended_data_key);
}
+ (void)setExtendedData:(NSData *)extendedData toObject:(id)object{
    if (!extendedData || !object) return;
    objc_setAssociatedObject(object, &extended_data_key, extendedData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSString *)description {
  return [NSString stringWithFormat:@"<%@: %p> (%@)", self.class, self, _path];
}

@end
