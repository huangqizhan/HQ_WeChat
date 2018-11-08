//
//  WebImageCache.m
//  YYStudyDemo
//
//  Created by hqz on 2018/7/10.
//  Copyright © 2018年 hqz. All rights reserved.
//

#import "WebImageCache.h"
#import "MyImage.h"
#import "UIImage+YYWebImage.h"
#import "Cache.h"


static inline dispatch_queue_t YYImageCacheIOQueue() {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}

static inline dispatch_queue_t YYImageCacheDecodeQueue() {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
}

@interface WebImageCache ()
- (NSUInteger)imageCost:(UIImage *)image;
- (UIImage *)imageFromData:(NSData *)data;
@end

@implementation WebImageCache
- (NSUInteger)imageCost:(UIImage *)image {
    CGImageRef cgImage = image.CGImage;
    if (!cgImage) return 1;
    CGFloat height = CGImageGetHeight(cgImage);
    size_t bytesPerRow = CGImageGetBytesPerRow(cgImage);
    NSUInteger cost = bytesPerRow * height;
    if (cost == 0) cost = 1;
    return cost;
}
- (UIImage *)imageFromData:(NSData *)data{
    NSData *scaleData = [DiskCache getExtendedDataFromObject:data];
    CGFloat scale = 0;
    if (scaleData) {
        scale = ((NSNumber *)[NSKeyedUnarchiver unarchiveObjectWithData:scaleData]).doubleValue;
    }
    if (scale <= 0) scale = [UIScreen mainScreen].scale;
    UIImage *image;
    if (_allowAnimatedImage) {
        image = [[MyImage alloc] initWithData:data scale:scale];
        if (_decodeForDisplay) image = [image imageByDecoded];
    } else {
        ImageDeCode *decoder = [ImageDeCode decoderWithData:data scale:scale];
        image = [decoder frameAtIndex:0 decodeForDisplay:_decodeForDisplay].image;
    }
    return image;
}
#pragma mark Public

+ (instancetype)sharedCache {
    static WebImageCache *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                                   NSUserDomainMask, YES) firstObject];
        cachePath = [cachePath stringByAppendingPathComponent:@"com.ibireme.yykit"];
        cachePath = [cachePath stringByAppendingPathComponent:@"images"];
        cache = [[self alloc] initWithPath:cachePath];
    });
    return cache;
}
- (instancetype)init {
    @throw [NSException exceptionWithName:@"YYImageCache init error" reason:@"YYImageCache must be initialized with a path. Use 'initWithPath:' instead." userInfo:nil];
    return [self initWithPath:@""];
}
- (instancetype)initWithPath:(NSString *)path {
    MemoryCache *memoryCache = [MemoryCache new];
    memoryCache.shouldRemoveAllObjectsOnMemoryWarning = YES;
    memoryCache.shouldRemoveAllObjectsWhenEnteringBackground = YES;
    memoryCache.countLimit = NSUIntegerMax;
    memoryCache.costLimit = NSUIntegerMax;
    memoryCache.ageLimit = 12 * 60 * 60;
    
    DiskCache *diskCache = [[DiskCache alloc] initWithPath:path];
    diskCache.customArchiveBlock = ^(id object) { return (NSData *)object; };
    diskCache.customUnarchiveBlock = ^(NSData *data) { return (id)data; };
    if (!memoryCache || !diskCache) return nil;
    
    self = [super init];
    _memoryCache = memoryCache;
    _diskCache = diskCache;
    _allowAnimatedImage = YES;
    _decodeForDisplay = YES;
    return self;
}
- (void)setImage:(UIImage *)image forKey:(NSString *)key {
    [self setImage:image imageData:nil forKey:key withType:YYImageCacheTypeAll];
}
- (void)setImage:(UIImage *)image imageData:(NSData *)imageData forKey:(NSString *)key withType:(YYImageCacheType)type {
    if (!key || (image == nil && imageData.length == 0)) return;
    
    __weak typeof(self) _self = self;
    if (type & YYImageCacheTypeMemory) { // add to memory cache
        if (image) {
            if (image.isDecodedForDisplay) {
                [_memoryCache setObject:image forKey:key withCost:[_self imageCost:image]];
            } else {
                dispatch_async(YYImageCacheDecodeQueue(), ^{
                    __strong typeof(_self) self = _self;
                    if (!self) return;
                    [self.memoryCache setObject:[image  imageByDecoded] forKey:key withCost:[self imageCost:image]];
                });
            }
        } else if (imageData) {
            dispatch_async(YYImageCacheDecodeQueue(), ^{
                __strong typeof(_self) self = _self;
                if (!self) return;
                UIImage *newImage = [self imageFromData:imageData];
                [self.memoryCache setObject:newImage forKey:key withCost:[self imageCost:newImage]];
            });
        }
    }
    if (type & YYImageCacheTypeDisk) { // add to disk cache
        if (imageData) {
            dispatch_async(YYImageCacheIOQueue(), ^{
                if (image) {
                    [DiskCache setExtendedData:[NSKeyedArchiver archivedDataWithRootObject:@(image.scale)] toObject:imageData];
                }
                [_diskCache setObject:imageData forKey:key];
            });
        } else if (image) {
            dispatch_async(YYImageCacheIOQueue(), ^{
                __strong typeof(_self) self = _self;
                if (!self) return;
                NSData *data = [image imageDataRepresentation];
                [DiskCache setExtendedData:[NSKeyedArchiver archivedDataWithRootObject:@(image.scale)] toObject:data];
                [self.diskCache setObject:data forKey:key];
            });
        }
    }
}
- (void)removeImageForKey:(NSString *)key {
    [self removeImageForKey:key withType:YYImageCacheTypeAll];
}

- (void)removeImageForKey:(NSString *)key withType:(YYImageCacheType)type {
    if (type & YYImageCacheTypeMemory) [_memoryCache removeObjectForKey:key];
    if (type & YYImageCacheTypeDisk) [_diskCache removeObjectForKey:key];
}
- (BOOL)containsImageForKey:(NSString *)key {
    return [self containsImageForKey:key withType:YYImageCacheTypeAll];
}

- (BOOL)containsImageForKey:(NSString *)key withType:(YYImageCacheType)type {
    if (type & YYImageCacheTypeMemory) {
        if ([_memoryCache containsObjectForKey:key]) return YES;
    }
    if (type & YYImageCacheTypeDisk) {
        if ([_diskCache containsObjectForKey:key]) return YES;
    }
    return NO;
}
- (UIImage *)getImageForKey:(NSString *)key {
    return [self getImageForKey:key withType:YYImageCacheTypeAll];
}

- (UIImage *)getImageForKey:(NSString *)key withType:(YYImageCacheType)type {
    if (!key) return nil;
    if (type & YYImageCacheTypeMemory) {
        UIImage *image = [_memoryCache objectForKey:key];
        if (image) return image;
    }
    if (type & YYImageCacheTypeDisk) {
        NSData *data = (id)[_diskCache objectForKey:key];
        UIImage *image = [self imageFromData:data];
        if (image && (type & YYImageCacheTypeMemory)) {
            [_memoryCache setObject:image forKey:key withCost:[self imageCost:image]];
        }
        return image;
    }
    return nil;
}

- (void)getImageForKey:(NSString *)key withType:(YYImageCacheType)type withBlock:(void (^)(UIImage *image, YYImageCacheType type))block {
    if (!block) return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = nil;
        
        if (type & YYImageCacheTypeMemory) {
            image = [self->_memoryCache objectForKey:key];
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(image, YYImageCacheTypeMemory);
                });
                return;
            }
        }
        
        if (type & YYImageCacheTypeDisk) {
            NSData *data = (id)[self->_diskCache objectForKey:key];
            image = [self imageFromData:data];
            if (image) {
                [self->_memoryCache setObject:image forKey:key];
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(image, YYImageCacheTypeDisk);
                });
                return;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(nil, YYImageCacheTypeNone);
        });
    });
}
- (NSData *)getImageDataForKey:(NSString *)key {
    return (id)[_diskCache objectForKey:key];
}

- (void)getImageDataForKey:(NSString *)key withBlock:(void (^)(NSData *imageData))block {
    if (!block) return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = (id)[self->_diskCache objectForKey:key];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(data);
        });
    });
}
@end
