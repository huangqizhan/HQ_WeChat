//
//  MemoryCache.h
//  YYStudy
//
//  Created by hqz on 2018/5/24.
//  Copyright © 2018年 hqz. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MemoryCache : NSObject
///进入后台是否删除
@property BOOL shouldRemoveAllObjectsWhenEnteringBackground;

///收到内存警告是否自动删除
@property (nonatomic,assign) BOOL shouldRemoveAllObjectsOnMemoryWarning;
////收到内存警告回调
@property (nonatomic,copy) void (^memeryWarningBlcok)(MemoryCache *cache);

@property (nonatomic,copy) void (^enterBackGroundBlcok)(MemoryCache *cache);

/** The name of the cache. Default is nil. */
@property (nullable, copy) NSString *name;

/** The number of objects in the cache (read-only) */
@property (readonly) NSUInteger totalCount;

/** The total cost of objects in the cache (read-only). */
@property (readonly) NSUInteger totalCost;

#pragma mark - Limit
///=============================================================================
/// @name Limit
///=============================================================================

/**
 The maximum number of objects the cache should hold.
 
 @discussion The default value is NSUIntegerMax, which means no limit.
 This is not a strict limit—if the cache goes over the limit, some objects in the
 cache could be evicted later in backgound thread.
 */
@property NSUInteger countLimit;

/**
 The maximum total cost that the cache can hold before it starts evicting objects.
 
 @discussion The default value is NSUIntegerMax, which means no limit.
 This is not a strict limit—if the cache goes over the limit, some objects in the
 cache could be evicted later in backgound thread.
 */
@property NSUInteger costLimit;

/**
 The maximum expiry time of objects in cache.
 
 @discussion The default value is DBL_MAX, which means no limit.
 This is not a strict limit—if an object goes over the limit, the object could
 be evicted later in backgound thread.
 */
@property NSTimeInterval ageLimit;


///自动清除内存缓存的时间间隔
@property NSTimeInterval autoTrimInterval;
/**
 A block to be executed when the app receives a memory warning.
 The default value is nil.
 */
@property (nullable, copy) void(^didReceiveMemoryWarningBlock)(MemoryCache *cache);

/**
 A block to be executed when the app enter background.
 The default value is nil.
 */
@property (nullable, copy) void(^didEnterBackgroundBlock)(MemoryCache *cache);

/**
 If `YES`, the key-value pair will be released on main thread, otherwise on
 background thread. Default is NO.
 
 @discussion You may set this value to `YES` if the key-value object contains
 the instance which should be released in main thread (such as UIView/CALayer).
 */
@property BOOL releaseOnMainThread;

/**
 If `YES`, the key-value pair will be released asynchronously to avoid blocking
 the access methods, otherwise it will be released in the access method
 (such as removeObjectForKey:). Default is YES.
 */
@property BOOL releaseAsynchronously;


#pragma mark - Access Methods
///=============================================================================
/// @name Access Methods
///=============================================================================

/**
 Returns a Boolean value that indicates whether a given key is in cache.
 
 @param key An object identifying the value. If nil, just return `NO`.
 @return Whether the key is in cache.
 */
- (BOOL)containsObjectForKey:(id)key;

/**
 Returns the value associated with a given key.
 
 @param key An object identifying the value. If nil, just return nil.
 @return The value associated with key, or nil if no value is associated with key.
 */
- (nullable id)objectForKey:(id)key;

/**
 Sets the value of the specified key in the cache (0 cost).
 
 @param object The object to be stored in the cache. If nil, it calls `removeObjectForKey:`.
 @param key    The key with which to associate the value. If nil, this method has no effect.
 @discussion Unlike an NSMutableDictionary object, a cache does not copy the key
 objects that are put into it.
 */
- (void)setObject:(nullable id)object forKey:(id)key;

/**
 Sets the value of the specified key in the cache, and associates the key-value
 pair with the specified cost.
 
 @param object The object to store in the cache. If nil, it calls `removeObjectForKey`.
 @param key    The key with which to associate the value. If nil, this method has no effect.
 @param cost   The cost with which to associate the key-value pair.
 @discussion Unlike an NSMutableDictionary object, a cache does not copy the key
 objects that are put into it.
 */
- (void)setObject:(nullable id)object forKey:(id)key withCost:(NSUInteger)cost;

/**
 Removes the value of the specified key in the cache.
 
 @param key The key identifying the value to be removed. If nil, this method has no effect.
 */
- (void)removeObjectForKey:(id)key;

/**
 Empties the cache immediately.
 */
- (void)removeAllObjects;


#pragma mark - Trim
///=============================================================================
/// @name Trim
///=============================================================================

/**
 Removes objects from the cache with LRU, until the `totalCount` is below or equal to
 the specified value.
 @param count  The total count allowed to remain after the cache has been trimmed.
 */
- (void)trimToCount:(NSUInteger)count;

/**
 Removes objects from the cache with LRU, until the `totalCost` is or equal to
 the specified value.
 @param cost The total cost allowed to remain after the cache has been trimmed.
 */
- (void)trimToCost:(NSUInteger)cost;

/**
 Removes objects from the cache with LRU, until all expiry objects removed by the
 specified value.
 @param age  The maximum age (in seconds) of objects.
 */
- (void)trimToAge:(NSTimeInterval)age;


+ (void)dispatchTest;

@end
