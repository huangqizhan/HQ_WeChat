//
//  DiskCache.h
//  YYStudy
//
//  Created by hqz on 2018/5/24.
//  Copyright © 2018年 hqz. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DiskCache : NSObject
///文件的路径
@property (readonly) NSString *path;
////文件大小的阈值
@property (readonly) NSUInteger inlineThreshold;
////数量的上线
@property NSUInteger countLimit;
////总共文件的容量
@property NSUInteger costLimit;
///存储的文件最长的时间限制
@property NSTimeInterval ageLimit;
////手机系统的剩余容量
@property NSUInteger freeDiskSpaceLimit;
////每隔相应的时间 自动清理文件 到指定的限制
@property NSTimeInterval autoTrimInterval;
///根据key可自定义fileName
@property (nullable, copy) NSString *(^customFileNameBlock)(NSString *key);
///如果object 实现了NSCoding 可根据data返回自定义的object
@property (nullable, copy) id (^customUnarchiveBlock)(NSData *data);
///如果object 实现了NSCoding 可根据object自定义返回归档 data
@property (nullable, copy) NSData *(^customArchiveBlock)(id object);


///初始化
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithPath:(NSString *)path;
///最终实现初始化
- (instancetype)initWithPath:(NSString *)path
             inlineThreshold:(NSUInteger)threshold NS_DESIGNATED_INITIALIZER;

#pragma mark  public

//是否有key所对应的值
- (BOOL)containsObjectForKey:(NSString *)key;
- (void)containsObjectForKey:(NSString *)key withBlock:(void(^)(NSString *key, BOOL contains))block;

///key 所对应的值
- (id<NSCoding>)objectForKey:(NSString *)key;
- (void)objectForKey:(NSString *)key withBlock:(void(^)(NSString *key, id<NSCoding> object))block;

///保存key 对应的值
- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key;
- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key withBlock:(void (^)(void))block;

///删除key 对应的值
- (void)removeObjectForKey:(NSString *)key;
- (void)removeObjectForKey:(NSString *)key withBlock:(void(^)(NSString *))block;

///删除所有
- (void)removeAllObjects;
- (void)removeAllObjectsWithProgressBlock:(void(^)(int removedCount, int totalCount))progress endBlock:(void(^)(BOOL error))end;
///总的存储数量
- (NSInteger)totalCount;
- (void)totalCountWithBlock:(void(^)(NSInteger totalCount))block ;
///总容量
- (NSInteger)totalCost;
- (void)totalCostWithBlock:(void(^)(NSInteger totalCost))block;

///如果超出限制的数量值 删除直到相应的数量
- (void)trimToCount:(NSUInteger)count;
- (void)trimToCount:(NSUInteger)count withBlock:(void(^)(void))block;

///如果超出限制的总容量 删除直到相应的容量
- (void)trimToCost:(NSUInteger)cost;
- (void)trimToCost:(NSUInteger)cost withBlock:(void(^)(void))block;

///如果超出限制的时间限制 删除直到相应的时间限制
- (void)trimToAge:(NSTimeInterval)age;
- (void)trimToAge:(NSTimeInterval)age withBlock:(void(^)(void))block;

//// 获取object 相关联的 extendData
+ (NSData *)getExtendedDataFromObject:(id)object;
/// 关联 object 和 extendData
+ (void)setExtendedData:(NSData *)extendedData toObject:(id)object;

@end
