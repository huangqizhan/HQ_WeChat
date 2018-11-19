//
//  HQBaseOperation+Operation.m
//  LunchOPeration
//
//  Created by hjb_mac_mini on 2018/10/15.
//  Copyright © 2018年 8km. All rights reserved.
//

#import "NSOperation+Operation.h"

static dispatch_queue_t OperationDispatchManagerSerialQueue(void){
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.WBOpationManager.NSOperationManagerSerialQueue", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

@interface NSOperation (Template)
+ (void)_asyncStartOperation:(NSOperation *)operation;
@end


@implementation NSOperation (Template)

+ (void)_asyncStartOperation:(NSOperation *)newOperation{
    // 检测newOperation是否已被处理
    if (![self _operationDidHandle:newOperation]){
        NSOperationQueue *queue = [self _queueForOperation:newOperation];
        queue ? [queue addOperation:newOperation] : [newOperation cancel];
    }
}
///临时方法 可在自定义类中实现
+ (BOOL)_operationDidHandle:(NSOperation *)newOperation{
    return NO;
}
+ (NSOperationQueue *)_queueForOperation:(NSOperation *)newOperation{
    return nil;
}
@end

@implementation NSOperation (Operation)
- (void)syncStart{
    [NSOperationQueue syncOnMainStartOperations:self,nil];
}
- (void)asyncStartConcurrent{
    [NSOperationQueue asyncConCurrentStartOperations:self,nil];
}
- (void)asyncStartPersistent{
    [NSOperationQueue asyncOnPersistentStartOperations:self,nil];
}
- (void)startAfterOperations:(NSOperation *)operation,...{
    if (operation) {
        NSMutableArray *argList = [NSMutableArray new];
        [argList addObject:operation];
        va_list args;
        va_start(args, operation);
        NSOperation *eachOp = nil;
        while ((eachOp = va_arg(args, NSOperation *))) {
            [argList addObject:eachOp];
        }
        va_end(args);
        for (NSOperation *op in argList) {
            [self addDependency:op];
        }
    }
}
@end




@implementation NSOperationQueue (Operation)
///在主线程中开启任务
+ (void)syncOnMainStartOperations:(NSOperation *)operation , ... {
    if (operation) {
        [operation start];
        va_list argument;
        va_start(argument, operation);
        NSOperation *eachOperation = nil;
        while ((eachOperation = va_arg(argument, NSOperation *))) {
            [eachOperation start];
        }
        va_end(argument);
    }
}
///异步开启并行任务
+ (void)asyncConCurrentStartOperations:(NSOperation *)operation, ... {
    if (operation) {
        NSMutableArray *ops = [NSMutableArray new];
        [ops addObject:operation];
        va_list argList;
        va_start(argList, operation);
        NSOperation *eachOp = nil;
        while ((eachOp = va_arg(argList, NSOperation *))) {
            [ops addObject:eachOp];
        }
        va_end(argList);
    dispatch_async(OperationDispatchManagerSerialQueue(), ^{
            for (NSOperation *op in ops) {
                [op.class _asyncStartOperation:(op)];
            }
        });
    }
}
///在常驻线程 开启任务(串行)
+ (void)asyncOnPersistentStartOperations:(NSOperation *)operation,...{
    if (operation) {
        [operation start];
        va_list argument;
        va_start(argument, operation);
        NSOperation *eachOperation = nil;
        while ((eachOperation = va_arg(argument, NSOperation *))) {
            [eachOperation start];
        }
        va_end(argument);
    }
}
@end
       
