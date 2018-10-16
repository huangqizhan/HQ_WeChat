//
//  KVStorage.h
//  YYStudy
//
//  Created by hqz on 2018/5/24.
//  Copyright © 2018年 hqz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface KVStorageItem : NSObject
@property (nonatomic, strong) NSString *key;                ///< key
@property (nonatomic, strong) NSData *value;                ///< value
@property (nullable, nonatomic, strong) NSString *filename; ///< filename (nil if inline)
@property (nonatomic) int size;                             ///< value's size in bytes
@property (nonatomic) int modTime;                          ///< modification unix timestamp
@property (nonatomic) int accessTime;                       ///< last access unix timestamp
@property (nullable, nonatomic, strong) NSData *extendedData; ///< extended data (nil if no extended data)
@end



typedef NS_ENUM(NSUInteger, KVStorageType) {
    
    /// The `value` is stored as a file in file system.
    KVStorageTypeFile = 0,
    
    /// The `value` is stored in sqlite with blob type.
    KVStorageTypeSQLite = 1,
    
    /// The `value` is stored in file system or sqlite based on your choice.
    KVStorageTypeMixed = 2,
};



@interface KVStorage : NSObject

@property (nonatomic,copy,readonly) NSString *path;

@property (nonatomic,readonly) KVStorageType type;


///排除初始化方法
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

///初始化
- (nullable instancetype)initWithPath:(NSString *)path type:(KVStorageType)type NS_DESIGNATED_INITIALIZER;

- (BOOL)saveItem:(KVStorageItem *)item;
- (BOOL)saveItemWithKey:(NSString *)key value:(NSData *)value;

- (BOOL)saveItemWithKey:(NSString *)key
                  value:(NSData *)value
               filename:(nullable NSString *)filename
           extendedData:(nullable NSData *)extendedData;
- (BOOL)removeItemForKey:(NSString *)key;
- (BOOL)removeItemForKeys:(NSArray *)keys;
- (BOOL)removeItemsLargerThanSize:(int)size;
- (BOOL)removeItemsEarlierThanTime:(int)time;
- (BOOL)removeItemsToFitSize:(int)maxSize;
- (BOOL)removeItemsToFitCount:(int)maxCount;

///删除所有的item
- (void)removeAllItemsWithProcessBlock:(void (^)(int removeCount , int totalCount))processBlock endBlock:(void (^)(BOOL success))endBlock;
- (BOOL)removeAllItems;

///可以对应的item
- (KVStorageItem *)getItemInfoForKey:(NSString *)key;
- (KVStorageItem *)getItemForKey:(NSString *)key;
//key 对应的item 有value值
- (NSData *)getItemValueForKey:(NSString *)key;
////key 对应的item 有value
- (NSArray *)getItemForKeys:(NSArray *)keys;
////key 对应的item  没有value
- (NSArray *)getItemInfoForKeys:(NSArray *)keys;
////key 对应的item 
- (NSDictionary *)getItemValueForKeys:(NSArray *)keys;
///key 所对应的item 是否存在
- (BOOL)itemExistsForKey:(NSString *)key ;
///所有item的数量
- (int)getItemsCount;
////所有value 的总size
- (int)getItemsSize;
@end



NS_ASSUME_NONNULL_END
