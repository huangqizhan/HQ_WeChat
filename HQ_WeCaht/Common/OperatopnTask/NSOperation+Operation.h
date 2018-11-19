//
//  HQBaseOperation+Operation.h
//  LunchOPeration
//
//  Created by hjb_mac_mini on 2018/10/15.
//  Copyright © 2018年 8km. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSOperation (Operation)

/**
 主线程
 */
- (void)syncStart;

/**
 并行异步执行
 */
- (void)asyncStartConcurrent;

/**
 在一个常驻线程异步执行
 (因为在一个线程中执行 所以所有的操作都是串行的)
 (UI 操作不能在此线程中执行)
 */
- (void)asyncStartPersistent;


/**
 添加依赖有序执行

 @param operation operation
 */
- (void)startAfterOperations:(NSOperation *)operation,...;


@end




@interface NSOperationQueue (Operation)

///在主线程中开启任务
+ (void)syncOnMainStartOperations:(NSOperation *)operation , ... ;

///异步开启并行任务（可添加依赖保证operation的执行顺序）
+ (void)asyncConCurrentStartOperations:(NSOperation *)operation, ... ;

///在常驻线程 开启任务(因为只有一个线程  只能是串行)
+ (void)asyncOnPersistentStartOperations:(NSOperation *)operation,...;

@end

