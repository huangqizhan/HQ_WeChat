//
//  DispatchQueuePool.h
//  YYStudyDemo
//
//  Created by hqz  QQ 757618403 on 2018/5/29.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//



#import <Foundation/Foundation.h>

#ifndef DispatchQueuePool_h
#define DispatchQueuePool_h

/**
 根据当前进程活跃的内核数量   来创建等数量的串行队列数量
 （串行队列的执行异步操作的话 只会开启一个线程 gcd自动调成）
 创建后的队列放入 静态数组中
 这样可以根据当前处理器情况 创建队列 而且一个队列只会对应一个线程
 这就类似于一个线程池(串行队列同一时间只有一个任务)
 */
@interface DispatchQueuePool : NSObject

////pool name
@property (nullable,nonatomic,readonly) NSString *name;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

///自己定义一个对列池
- (instancetype)initWithName:(NSString *)name queueCount:(NSUInteger)queueCount qos:(NSQualityOfService)qos;

///根据QOS  获取系统默认的
+ (instancetype)defaultPoolForQOS:(NSQualityOfService)qos;

///获取一个串行队列
- (dispatch_queue_t)queue;
@end

///C function get dispatchQueue
extern dispatch_queue_t DispatchGetQueueForQos(NSQualityOfService qos);



#endif

