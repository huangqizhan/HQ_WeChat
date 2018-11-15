//
//  NetWorkingOperationManager.m
//  HQ_WeChat
//
//  Created by 黄麒展  QQ 757618403 on 2018/11/14.
//  Copyright © 2018年 8km. All rights reserved.
//

#import "NetWorkingOperationManager.h"


@interface NetWorkingOperationManager ()

@property (readwrite,nonatomic,strong) NSMutableDictionary *operationsDictionary;

@property (readwrite, nonatomic, strong) NSLock *lock;

@end



@implementation NetWorkingOperationManager

+ (instancetype)shareManager{
    static NetWorkingOperationManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [NetWorkingOperationManager new];
        manager.operationsDictionary = [NSMutableDictionary new];
        manager.lock = [[NSLock alloc] init];
    });
    return manager;
}

+ (void)addChatTextOperation:(NetworkingBaseOperation *)operation complition:(ChatTetxOpeationComplitionBlock)complition{
    if (! operation )return;
    NSUInteger identifier = [operation startChatTextRequestWith:^(NetworkingOperationStatus status, NSURLSessionTask *task, id result) {
        [[NetWorkingOperationManager shareManager] removeOperationWithIdentifer:task.taskIdentifier];
        if(complition) complition(status, result);
    }];
    if (identifier > 0) {
        [[NetWorkingOperationManager shareManager] setOperationWithOperation:operation identifer:identifier];
    }
}

- (void)setOperationWithOperation:(NetworkingBaseOperation *)operation identifer:(NSUInteger)identifier{
    if (!operation )return;
    [_lock lock];
    if (identifier > 0) {
        [NetWorkingOperationManager shareManager].operationsDictionary[@(identifier)] = operation;
    }
    [_lock unlock];
}
- (void)removeOperationWithIdentifer:(NSUInteger)identifier{
    if (identifier <= 0) return;
    [_lock lock];
    [[NetWorkingOperationManager shareManager].operationsDictionary removeObjectForKey:@(identifier)];
    [_lock unlock];
}




@end
