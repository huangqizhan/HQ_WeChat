//
//  DispatchQueuePool.m
//  YYStudyDemo
//
//  Created by hqz  QQ 757618403 on 2018/5/29.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//

#import "DispatchQueuePool.h"
#import <UIKit/UIKit.h>
#import <libkern/OSAtomic.h>

#define MAX_QUEUE_COUNT 32

static inline dispatch_queue_priority_t NSQualityOfServiceToDispatchPriority(NSQualityOfService qos) {
    switch (qos) {
        case NSQualityOfServiceUserInteractive: return DISPATCH_QUEUE_PRIORITY_HIGH;
        case NSQualityOfServiceUserInitiated: return DISPATCH_QUEUE_PRIORITY_HIGH;
        case NSQualityOfServiceUtility: return DISPATCH_QUEUE_PRIORITY_LOW;
        case NSQualityOfServiceBackground: return DISPATCH_QUEUE_PRIORITY_BACKGROUND;
        case NSQualityOfServiceDefault: return DISPATCH_QUEUE_PRIORITY_DEFAULT;
        default: return DISPATCH_QUEUE_PRIORITY_DEFAULT;
    }
}

static inline qos_class_t NSQualityOfServiceToQOSClass(NSQualityOfService qos) {
    switch (qos) {
        case NSQualityOfServiceUserInteractive: return QOS_CLASS_USER_INTERACTIVE;
        case NSQualityOfServiceUserInitiated: return QOS_CLASS_USER_INITIATED;
        case NSQualityOfServiceUtility: return QOS_CLASS_UTILITY;
        case NSQualityOfServiceBackground: return QOS_CLASS_BACKGROUND;
        case NSQualityOfServiceDefault: return QOS_CLASS_DEFAULT;
        default: return QOS_CLASS_UNSPECIFIED;
    }
}

typedef struct {
    const char *name;
    ///二维指针
    void **queues;
    int32_t queueCount;
    int32_t counter;
}DispatchContext;
///创建 DispatchContext 
static DispatchContext *dispatchContextCreate(const char *name,int32_t queueCount ,NSQualityOfService qos){
    DispatchContext *context = calloc(1, sizeof(DispatchContext));
    if (!context) return NULL;
    ///queue 的第一位指针
    context->queues = calloc(queueCount, sizeof(void *));
    if ([UIDevice currentDevice].systemName.doubleValue >= 80.) {
        dispatch_qos_class_t qosClass = NSQualityOfServiceToQOSClass(qos);
        for (int i = 0 ; i < queueCount; i++) {
            ///对列属性
            dispatch_queue_attr_t  queueAtt = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, qosClass,0);
             dispatch_queue_t qu = dispatch_queue_create(name, queueAtt);
            ///queue的第二位指针
            context->queues[i] = (__bridge_retained void *)qu;
        }
    }else{
        long identifer = NSQualityOfServiceToDispatchPriority(qos);
        for (int i = 0; i < queueCount; i++) {
            dispatch_queue_t queue = dispatch_queue_create(name, DISPATCH_QUEUE_SERIAL);
            dispatch_set_target_queue(queue, dispatch_get_global_queue(identifer, 0));
            context->queues[i] = (__bridge_retained void *)queue;
        }
    }
    context->queueCount = queueCount;
    if (name) {
        ////deep copy
        context->name = strdup(name);
    }
    return context;
}
////release  disoatchContext
static void dispathContextRelease(DispatchContext *context){
    if (!context) return;
    if (context->queues) {
        for (int i = 0; i < context->queueCount; i++) {
            void *queuePoint = context->queues[i];
            dispatch_queue_t que = (__bridge_transfer dispatch_queue_t)queuePoint;
            const char *name = dispatch_queue_get_label(que);
            if (name) strlen(name);  ///NO
            que = nil;
        }
        free(context->queues);
        context->queues = NULL;
    }
    if (context->name) free((void *)context->name);
}
static dispatch_queue_t dispatchContextGetQueue(DispatchContext *context){
    uint32_t counter = OSAtomicIncrement32(&context->counter);
    void *queue = context->queues[counter % context->queueCount];
    return (__bridge dispatch_queue_t)queue;
}
static DispatchContext *dispatchContextGetForQos(NSQualityOfService qos){
    static DispatchContext *context[5] = {0};
    switch (qos) {
        case NSQualityOfServiceUserInteractive:{
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                ////进程所在系统的激活的处理器数量
                int count = (int) [NSProcessInfo processInfo].activeProcessorCount;
                count = count < 1 ? 1 : count >  MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : count;
                context[0] = dispatchContextCreate("Interactive", count, qos);
            });
            return context[0];
        }
            break;
        case NSQualityOfServiceUserInitiated:{
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                int count = (int) [NSProcessInfo processInfo].activeProcessorCount;
                count = count < 1 ? 1 : count >  MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : count;
                context[1] = dispatchContextCreate("Initiated", count, qos);
            });
            return context[1];
        }
            break;
        case NSQualityOfServiceUtility:{
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                int count = (int) [NSProcessInfo processInfo].activeProcessorCount;
                count = count < 1 ? 1 : count >  MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : count;
                context[2] = dispatchContextCreate("Utility", count, qos);
            });
            return context[2];
        }
            break;
        case NSQualityOfServiceBackground:{
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                int count = (int) [NSProcessInfo processInfo].activeProcessorCount;
                count = count < 1 ? 1 : count >  MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : count;
                context[3] = dispatchContextCreate("Background", count, qos);
            });
            return context[3];
        }
            break;
            case NSQualityOfServiceDefault:
        default:{
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                int count = (int) [NSProcessInfo processInfo].activeProcessorCount;
                count = count < 1 ? 1 : count >  MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : count;
                context[4] = dispatchContextCreate("Default", count, qos);
            });
            return context[4];
            break;
        }
    }
}
@implementation DispatchQueuePool{
    DispatchContext *_context;
}
- (instancetype)initWith:(DispatchContext *)context{
    self = [super init];
    self->_context = context;
    _name = context->name ? [NSString stringWithUTF8String:context->name] : nil;
    return self;
}
- (instancetype)initWithName:(NSString *)name queueCount:(NSUInteger)queueCount qos:(NSQualityOfService)qos{
    if (queueCount <= 0 || queueCount > MAX_QUEUE_COUNT) return nil;
    self = [super init];
    _context = dispatchContextCreate(name.UTF8String, (int32_t)queueCount, qos);
    if (!_context) return nil;
    _name = name;
    return self;
}
- (dispatch_queue_t)queue{
    return dispatchContextGetQueue(_context);
}
+ (instancetype)defaultPoolForQOS:(NSQualityOfService)qos {
    switch (qos) {
        case NSQualityOfServiceUserInteractive:{
            static DispatchQueuePool *pool;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                pool = [[DispatchQueuePool alloc] initWith:dispatchContextGetForQos(qos)];
            });
            return pool;
        }
            break;
        case NSQualityOfServiceUserInitiated:{
            static DispatchQueuePool *pool;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                pool = [[DispatchQueuePool alloc] initWith:dispatchContextGetForQos(qos)];
            });
            return pool;
        }
            break;
        case NSQualityOfServiceUtility:{
            static DispatchQueuePool *pool;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                pool = [[DispatchQueuePool alloc] initWith:dispatchContextGetForQos(qos)];
            });
            return pool;
        }
            break;
        case NSQualityOfServiceBackground:{
            static DispatchQueuePool *pool;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                pool = [[DispatchQueuePool alloc] initWith:dispatchContextGetForQos(qos)];
            });
            return pool;
        }
            break;
        case NSQualityOfServiceDefault:
        default:{
            static DispatchQueuePool *pool;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                pool = [[DispatchQueuePool alloc] initWith:dispatchContextGetForQos(qos)];
            });
            return pool;
        }
            break;
    }
}
- (void)dealloc{
    if (_context) {
        dispathContextRelease(_context);
        _context = NULL;
    }
}
@end

dispatch_queue_t DispatchGetQueueForQos(NSQualityOfService qos){
    DispatchContext *con = dispatchContextGetForQos(qos);
   return dispatchContextGetQueue(con);
}

/*
 队列里面任务的优先级
 
 NSQualityOfServiceUserInteractive：最高优先级，主要用于提供交互UI的操作，比如处理点击事件，绘制图像到屏幕上
 NSQualityOfServiceUserInitiated：次高优先级，主要用于执行需要立即返回的任务
 NSQualityOfServiceDefault：默认优先级，当没有设置优先级的时候，线程默认优先级
 NSQualityOfServiceUtility：普通优先级，主要用于不需要立即返回的任务
 NSQualityOfServiceBackground：后台优先级，用于完全不紧急的任务
 
 五个异步任务  五个队列 要想这几个任务有顺序的进行 可用 dispatch_set_target_queue 指向一个新的串行队列
 
 //    dispatch_queue_t targetQueue = dispatch_queue_create("test.target.queue", DISPATCH_QUEUE_SERIAL);
 //
 //    dispatch_queue_t queue1 = dispatch_queue_create(DISPATCH_QUEUE_SERIAL, 0);
 //    dispatch_set_target_queue(queue1, targetQueue);
 //
 //    dispatch_queue_t queue2 = dispatch_queue_create(DISPATCH_QUEUE_SERIAL, 0);
 //    dispatch_set_target_queue(queue2, targetQueue);
 //
 //    dispatch_queue_t queue3 = dispatch_queue_create(DISPATCH_QUEUE_SERIAL, 0);
 //    dispatch_set_target_queue(queue3, targetQueue);
 //
 //    dispatch_queue_t queue4 = dispatch_queue_create(DISPATCH_QUEUE_SERIAL, 0);
 //    dispatch_set_target_queue(queue4, targetQueue);
 //
 //    dispatch_queue_t queue5 = dispatch_queue_create(DISPATCH_QUEUE_SERIAL, 0);
 //    dispatch_set_target_queue(queue5, targetQueue);
 //
 //
 //    dispatch_async(queue1, ^{
 //        for (int i = 0; i < 100; i++) {
 //            NSLog(@"1");
 //            if (i == 99) {
 //                NSLog(@"1 结束");
 //            }
 //        }
 //    });
 //
 //    dispatch_async(queue2, ^{
 //        for (int i = 0; i < 100; i++) {
 //            NSLog(@"2");
 //            if (i == 99) {
 //                NSLog(@"2 结束");
 //            }
 //        }
 //    });
 //
 //
 //    dispatch_async(queue3, ^{
 //        for (int i = 0; i < 100; i++) {
 //            NSLog(@"3");
 //            if (i == 99) {
 //                NSLog(@"3 结束");
 //            }
 //        }
 //    });
 //
 //    dispatch_async(queue4, ^{
 //        for (int i = 0; i < 100; i++) {
 //            NSLog(@"4");
 //            if (i == 99) {
 //                NSLog(@"4 结束");
 //            }
 //        }
 //    });
 //
 //    dispatch_async(queue5, ^{
 //        for (int i = 0; i < 100; i++) {
 //            NSLog(@"5");
 //            if (i == 99) {
 //                NSLog(@"5 结束");
 //            }
 //        }
 //    });
 
 //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
 //
 //    });
 
 
 */
