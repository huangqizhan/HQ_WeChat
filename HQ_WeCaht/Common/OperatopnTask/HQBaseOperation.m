//
//  HQBaseOperation.m
//  LunchOPeration
//
//  Created by hjb_mac_mini on 2018/10/15.
//  Copyright © 2018年 8km. All rights reserved.
//

#import "HQBaseOperation.h"
#import <pthread/pthread.h>


HQOperationQueueType const HQOperationQueueSerialQueueType = @"HQOperationQueueSerialQueueType";

HQOperationQueueType const HQOperationQueueConcurrentType = @"HQOperationQueueSerialQueueType";


static NSOperationQueue *_operationQueueWithType(HQOperationQueueType type){
    static NSMutableDictionary *queues = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queues = [NSMutableDictionary dictionary];
    });
    NSOperationQueue *queue = queues[type];
    if (queue == nil) {
        queue = [NSOperationQueue new];
        queue.name = type;
        queues[type] = queue;
    }
    return queue;
}

@implementation HQBaseOperation
@synthesize finished = _finished;
@synthesize executing = _executing;

+ (NSOperationQueue *)_queueForOperation:(NSOperation *)newOperation
{
    HQOperationQueueType operationType = [self _queueType];
    NSOperationQueue *queue = _operationQueueWithType(operationType);
    
    if (operationType == HQOperationQueueConcurrentType){
        NSArray *ops = [queue operations];
        for (NSOperation *operation in ops){
            if ([operation isMemberOfClass:self]){
                queue = nil;
                break;
            }
        }
    }else if (operationType == HQOperationQueueSerialQueueType){
        [queue.operations enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([obj isMemberOfClass:self])
            {
                [newOperation addDependency:(NSOperation *)obj];
                *stop = YES;
            }
        }];
    }
    
    return queue;
}
+ (void)_execThreadMain:(id)object {
    @autoreleasepool {
        [[NSThread currentThread] setName:@"hqpersistentoperationqueue"];
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runLoop run];
    }
}

+ (NSThread *)_execPersistentThread {
    static NSThread *thread = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        thread = [[NSThread alloc] initWithTarget:self selector:@selector(_execThreadMain:) object:nil];
        if ([thread respondsToSelector:@selector(setQualityOfService:)]) {
            thread.qualityOfService = NSQualityOfServiceBackground;
        }
        [thread start];
    });
    return thread;
}
#pragma mark  ----- override -----

/**
 如果operation 添加到到队列之后 就会异步执行start
 */
- (void)start{
    if ([self isCancelled]) {
        [self done];
        return;
    }
    BOOL ismain = [self _execIsOnMain];
    ///主线程
    if (ismain) {
        if (pthread_main_np()) {
            [self _execOnMain];
            return;
        }        dispatch_async(dispatch_get_main_queue(), ^{
            [self _execOnMain];
        });
    }else{
        BOOL isPersistent = [self _isOnPersistentThread];
        ///常驻的单线程
        if (isPersistent) {
            [self performSelector:@selector(_execOnAsync) onThread:[self.class _execPersistentThread] withObject:nil waitUntilDone:NO];
        }else{
            ///多线程
            [self _execOnAsync];
        }
    }
}
- (void)cancel{
    [super cancel];
    [self done];
}
#pragma mark ----- private  ----
+ (HQOperationQueueType)_queueType{
    return nil;
}
- (BOOL)_execIsOnMain{
    return NO;
}
- (BOOL)_isOnPersistentThread{
    return NO;
}
- (void)_execOnMain{
}
- (void)_execOnAsync{
}
- (void)done{
    self.finished = YES;
    self.executing = NO;
}
#pragma mark ------ setter  -----
- (void)setFinished:(BOOL)finished{
    [self willChangeValueForKey:@"finished"];
    _finished = finished;
    [self didChangeValueForKey:@"finished"];
}
- (void)setExecuting:(BOOL)executing{
    [self willChangeValueForKey:@"executing"];
    _executing = executing;
    [self didChangeValueForKey:@"executing"];
}



@end
