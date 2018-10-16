//
//  Cache.h
//  YYStudy
//
//  Created by hqz on 2018/5/24.
//  Copyright © 2018年 hqz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DiskCache.h"
#import "MemoryCache.h"

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
