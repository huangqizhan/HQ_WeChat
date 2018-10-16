//
//  TextTransaction.m
//  YYStudyDemo
//
//  Created by hqz on 2018/9/4.
//  Copyright © 2018年 hqz. All rights reserved.
//

#import "TextTransaction.h"
@interface TextTransaction ()

@property (nonatomic,strong) id target;
@property (nonatomic,assign) SEL selector;

@end

static NSMutableSet *transactionSet;

////ruloop的observe 回调
static void RunloopObserveCallBack(CFRunLoopObserverRef observe, CFRunLoopActivity activity,void *info){
    if(transactionSet.count == 0) return;
    NSSet *currentSet = transactionSet;
    transactionSet = [NSMutableSet new];
    [currentSet enumerateObjectsUsingBlock:^(TextTransaction * target, BOOL * _Nonnull stop) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [target.target performSelector:target.selector];
#pragma clang diagnostic pop
    }];
}

static void TextTransactionSetUp(){
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        transactionSet = [NSMutableSet new];
        ///主线程的run loop
        CFRunLoopRef runloop = CFRunLoopGetMain();
        ///创建 observe(在线程等待 或者线程结束的时候)
        CFRunLoopObserverRef observe;
        observe = CFRunLoopObserverCreate(CFAllocatorGetDefault(), kCFRunLoopBeforeWaiting | kCFRunLoopExit, true, 0xFFFFFF, &RunloopObserveCallBack, NULL);
        ////主线程添加observe
        CFRunLoopAddObserver(runloop, observe, kCFRunLoopCommonModes);
        CFRelease(observe);
    });
}

@implementation TextTransaction

+ (TextTransaction *)transactionWithTarget:(id)target selector:(SEL)selector{
    if (target == nil || selector == nil) return nil;
    TextTransaction *transaction = [TextTransaction new];
    transaction.target = target;
    transaction.selector = selector;
    return transaction;
}

- (void)commit{
    if (_target == nil || _selector == nil) {
        return;
    }
    TextTransactionSetUp();
    [transactionSet addObject:self];
}

- (NSUInteger)hash {
    long v1 = (long)((void *)_selector);
    long v2 = (long)_target;
    return v1 ^ v2;
}

- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    if (![object isMemberOfClass:self.class]) return NO;
    TextTransaction *other = object;
    return other.selector == _selector && other.target == _target;
}

@end
