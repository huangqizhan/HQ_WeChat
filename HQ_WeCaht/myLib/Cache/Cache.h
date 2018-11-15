//
//  Cache.h
//  YYStudy
//
//  Created by hqz  QQ 757618403 on 2018/5/24.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DiskCache.h"
#import "MemoryCache.h"

NS_ASSUME_NONNULL_BEGIN

@class DiskCache;
@interface Cache : NSObject

@property (nonatomic,strong)DiskCache *diskCache;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithPath:(NSString *)path NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithName:(NSString *)name;


+ (instancetype)cacheWithName:(NSString *)name;
+ (instancetype)cacheWithPath:(NSString *)path;



@end


NS_ASSUME_NONNULL_END
