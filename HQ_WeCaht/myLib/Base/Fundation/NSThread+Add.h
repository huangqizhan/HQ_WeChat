//
//  NSThread+Add.h
//  YYKitStudy
//
//  Created by GoodSrc on 2017/12/12.
//  Copyright © 2017年 GoodSrc. All rights reserved.
//

#import <Foundation/Foundation.h>



/*
  1，给线程添加 RunLoop 是为了当前线程不会立即结束 而成为永驻线程 监听事件的分发事件
  2，子线程中默认不会开启RunLoop 也就不会创建自动释放池  所以需要手动创建
  3，线程内的对象在出了作用域之外 不会被立即释放 而是会放到最新创建的自动释放池中   当自动释放池被销毁
         之后会向所有的对象发送release 消息
  4，c语言创建对象不会自动释放  需要手动释放
 
 5， 内存泄漏的原因  C语言创建的对象没有手动释放   子线程没有创建自动释放池 创建的对象没有添加到自动释放池中；
 
 
 */


////为当前线程的runloop添加自动释放池

@interface NSThread (Add)

////给当前子线程添加自动释放池   （前提是开启NSRunLoop）

+ (void)addAutoreleasePoolToCurrentRunloop;

@end
