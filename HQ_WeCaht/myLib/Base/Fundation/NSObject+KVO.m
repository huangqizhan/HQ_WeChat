//
//  NSObject+KVO.m
//  YYKitStudy
//
//  Created by GoodSrc on 2017/11/27.
//  Copyright © 2017年 GoodSrc. All rights reserved.
//

#import "NSObject+KVO.h"
#import "Global.h"
#import <objc/runtime.h>


YYSSSYNTH_DUMMY_CLASS(NSObject_KVO)

static const NSString *block_Key;

/**
 所有添加的KVO都添加到此类上
 */
@interface KVOObserveObj :NSObject

///值改变之后调用此block
@property (nonatomic,copy) void (^block)(__weak id object,id newValue,id oldValue);

- (instancetype)initWithBlock:(void (^) (__weak id object,id newValue,id oldValue))block;

@end


@implementation KVOObserveObj

- (instancetype)initWithBlock:(void (^)(__weak id, id, id))block{
    self = [super init];
    if (self) {
        self.block = block;
    }
    return self;
}

////  KVO的触动 方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (!self.block)  return;
    ///此键只返回旧值
    BOOL isPrior = [[change objectForKey:NSKeyValueChangeNotificationIsPriorKey] boolValue];
    if (isPrior) return;
    NSKeyValueChange changeKind = [[change objectForKey:NSKeyValueChangeKindKey] integerValue];
    if (changeKind != NSKeyValueChangeSetting) return;
    if (changeKind != NSKeyValueChangeSetting) return;
    
    id oldVal = [change objectForKey:NSKeyValueChangeOldKey];
    if (oldVal == [NSNull null]) oldVal = nil;
    
    id newVal = [change objectForKey:NSKeyValueChangeNewKey];
    if (newVal == [NSNull null]) newVal = nil;
    
    self.block(object, oldVal, newVal);
    
}
@end



@implementation NSObject (KVO)

- (void)addObserverBlockForKeyPath:(NSString*)keyPath block:(void (^)(id _Nonnull obj, _Nullable id oldVal, _Nullable id newVal))block{
    KVOObserveObj *observeObj = [[KVOObserveObj alloc] initWithBlock:block];
    NSMutableDictionary *args =  [self SetAssociateArgs];
    KVOObserveObj *target  = [args objectForKey:keyPath];
    if (!target) {
        args[keyPath] = target;
    }
    [self addObserver:observeObj forKeyPath:keyPath options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:NULL];
}

- (void)removeObserverBlocksForKeyPath:(NSString *)keyPath {
    NSMutableDictionary *args =  [self SetAssociateArgs];
    [args enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([keyPath isEqualToString:keyPath]) {
            [self removeObserver:obj forKeyPath:keyPath];
            [args removeObjectForKey:keyPath];
        }
    }];
}

- (void)removeObserverBlocks {
    NSMutableDictionary *dic = [self SetAssociateArgs];
    [dic enumerateKeysAndObjectsUsingBlock: ^(NSString *key, NSArray *arr, BOOL *stop) {
        [arr enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
            [self removeObserver:obj forKeyPath:key];
        }];
    }];
    [dic removeAllObjects];
}
- (NSMutableDictionary *)SetAssociateArgs{
    NSMutableDictionary *dic = objc_getAssociatedObject(self, &block_Key);
    if (!dic) {
        dic = [NSMutableDictionary new];
        objc_setAssociatedObject(self, &block_Key, dic, OBJC_ASSOCIATION_RETAIN);
    }
    return dic;
}
@end
