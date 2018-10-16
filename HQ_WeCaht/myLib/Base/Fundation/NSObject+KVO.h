//
//  NSObject+KVO.h
//  YYKitStudy
//
//  Created by GoodSrc on 2017/11/27.
//  Copyright © 2017年 GoodSrc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (KVO)



///添加KVO可以用block 回调
- (void)addObserverBlockForKeyPath:(NSString*)keyPath block:(void (^)(id _Nonnull obj, _Nullable id oldVal, _Nullable id newVal))block;


////移除相应的KVO
- (void)removeObserverBlocksForKeyPath:(NSString *)keyPath;

////移除所有的KVO
- (void)removeObserverBlocks;


@end


NS_ASSUME_NONNULL_END
