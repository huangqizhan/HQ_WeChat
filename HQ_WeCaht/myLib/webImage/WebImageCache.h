//
//  WebImageCache.h
//  YYStudyDemo
//
//  Created by hqz on 2018/7/10.
//  Copyright © 2018年 hqz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


/// Image cache type
typedef NS_OPTIONS(NSUInteger, YYImageCacheType) {
    /// No value.
    YYImageCacheTypeNone   = 0,
    
    /// Get/store image with memory cache.
    YYImageCacheTypeMemory = 1 << 0,
    
    /// Get/store image with disk cache.
    YYImageCacheTypeDisk   = 1 << 1,
    
    /// Get/store image with both memory cache and disk cache.
    YYImageCacheTypeAll    = YYImageCacheTypeMemory | YYImageCacheTypeDisk,
};


@class MemoryCache, DiskCache;
@interface WebImageCache : NSObject


- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

/**
 The designated initializer. Multiple instances with the same path will make the
 cache unstable.
 
 @param path Full path of a directory in which the cache will write data.
 Once initialized you should not read and write to this directory.
 @result A new cache object, or nil if an error occurs.
 */
- (nullable instancetype)initWithPath:(NSString *)path NS_DESIGNATED_INITIALIZER;


/**
 Returns global shared image cache instance.
 @return  The singleton YYImageCache instance.
 */
+ (instancetype)sharedCache;
/** The name of the cache. Default is nil. */
@property (nullable, copy) NSString *name;

/** The underlying memory cache. see `MemoryCache` for more information.*/
@property (strong, readonly) MemoryCache *memoryCache;

/** The underlying disk cache. see `YYDiskCache` for more information.*/
@property (strong, readonly) DiskCache *diskCache;
/**
 Whether decode animated image when fetch image from disk cache. Default is YES.
 
 @discussion When fetch image from disk cache, it will use 'YYImage' to decode
 animated image such as WebP/APNG/GIF. Set to 'NO' to ignore animated image.
 */
@property BOOL allowAnimatedImage;

/**
 Whether decode the image to memory bitmap. Default is YES.
 
 @discussion If the value is YES, then the image will be decoded to memory bitmap
 for better display performance, but may cost more memory.
 */
@property BOOL decodeForDisplay;






/**
 Sets the image with the specified key in the cache (both memory and disk).
 This method returns immediately and executes the store operation in background.
 
 @param image The image to be stored in the cache. If nil, this method has no effect.
 @param key   The key with which to associate the image. If nil, this method has no effect.
 */
- (void)setImage:(UIImage *)image forKey:(NSString *)key;

/**
 Sets the image with the specified key in the cache.
 This method returns immediately and executes the store operation in background.
 
 @discussion If the `type` contain `YYImageCacheTypeMemory`, then the `image` will
 be stored in the memory cache; `imageData` will be used instead if `image` is nil.
 If the `type` contain `YYImageCacheTypeDisk`, then the `imageData` will
 be stored in the disk cache; `image` will be used instead if `imageData` is nil.
 
 @param image     The image to be stored in the cache.
 @param imageData The image data to be stored in the cache.
 @param key       The key with which to associate the image. If nil, this method has no effect.
 @param type      The cache type to store image.
 */
- (void)setImage:(nullable UIImage *)image
       imageData:(nullable NSData *)imageData
          forKey:(NSString *)key
        withType:(YYImageCacheType)type;

/**
 Removes the image of the specified key in the cache (both memory and disk).
 This method returns immediately and executes the remove operation in background.
 
 @param key The key identifying the image to be removed. If nil, this method has no effect.
 */
- (void)removeImageForKey:(NSString *)key;

/**
 Removes the image of the specified key in the cache.
 This method returns immediately and executes the remove operation in background.
 
 @param key  The key identifying the image to be removed. If nil, this method has no effect.
 @param type The cache type to remove image.
 */
- (void)removeImageForKey:(NSString *)key withType:(YYImageCacheType)type;

/**
 Returns a Boolean value that indicates whether a given key is in cache.
 If the image is not in memory, this method may blocks the calling thread until
 file read finished.
 
 @param key A string identifying the image. If nil, just return NO.
 @return Whether the image is in cache.
 */
- (BOOL)containsImageForKey:(NSString *)key;

/**
 Returns a Boolean value that indicates whether a given key is in cache.
 If the image is not in memory and the `type` contains `YYImageCacheTypeDisk`,
 this method may blocks the calling thread until file read finished.
 
 @param key  A string identifying the image. If nil, just return NO.
 @param type The cache type.
 @return Whether the image is in cache.
 */
- (BOOL)containsImageForKey:(NSString *)key withType:(YYImageCacheType)type;
/**
 Returns the image associated with a given key.
 If the image is not in memory, this method may blocks the calling thread until
 file read finished.
 
 @param key A string identifying the image. If nil, just return nil.
 @return The image associated with key, or nil if no image is associated with key.
 */
- (nullable UIImage *)getImageForKey:(NSString *)key;

/**
 Returns the image associated with a given key.
 If the image is not in memory and the `type` contains `YYImageCacheTypeDisk`,
 this method may blocks the calling thread until file read finished.
 
 @param key A string identifying the image. If nil, just return nil.
 @return The image associated with key, or nil if no image is associated with key.
 */
- (nullable UIImage *)getImageForKey:(NSString *)key withType:(YYImageCacheType)type;

/**
 Asynchronously get the image associated with a given key.
 
 @param key   A string identifying the image. If nil, just return nil.
 @param type  The cache type.
 @param block A completion block which will be called on main thread.
 */
- (void)getImageForKey:(NSString *)key
              withType:(YYImageCacheType)type
             withBlock:(void(^)(UIImage * _Nullable image, YYImageCacheType type))block;

/**
 Returns the image data associated with a given key.
 This method may blocks the calling thread until file read finished.
 
 @param key A string identifying the image. If nil, just return nil.
 @return The image data associated with key, or nil if no image is associated with key.
 */
- (nullable NSData *)getImageDataForKey:(NSString *)key;

/**
 Asynchronously get the image data associated with a given key.
 
 @param key   A string identifying the image. If nil, just return nil.
 @param block A completion block which will be called on main thread.
 */
- (void)getImageDataForKey:(NSString *)key
                 withBlock:(void(^)(NSData * _Nullable imageData))block;
@end

NS_ASSUME_NONNULL_END
