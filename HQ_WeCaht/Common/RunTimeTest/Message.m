//
//  Message.m
//  RunTime
//
//  Created by GoodSrc on 2017/10/31.
//  Copyright © 2017年 GoodSrc. All rights reserved.
//

#import "Message.h"
#import "MessageForwarding.h"
#import <objc/runtime.h>


@implementation Message
//
//- (void)sendMessage:(NSString *)word{
//    NSLog(@"send Message:%@",word);
//}
/**
  先从自身类中寻找  如果没有在从父类中查找  如果方法没有找到 可以在此方法里面添加处理  给自身类添加方法
////只适用于在当前类中代替掉。
 @param sel 调用的方法
 @return 未知
 */
+ (BOOL)resolveInstanceMethod:(SEL)sel{
    if (sel == @selector(sendMessage:)) {
        class_addMethod([self class], sel, imp_implementationWithBlock(^(id self, NSString *word) {
            NSLog(@" the function whitch is added    with args = %@", word);
        }), "v@*");
    }
    return YES ;
}

/**
 如果方法没有找到  而且resolveInstanceMethod方法没有重写  就会调用此方法
可以将消息处理转发给其他对象，使用范围更广，不只是限于原来的对象
 @param aSelector 调用的方法
 @return 调用此方法的实例
 */
- (id)forwardingTargetForSelector:(SEL)aSelector{
    if (aSelector == @selector(sendMessage:)) {
        return [MessageForwarding new];
    }
    return nil;
}






#pragma  mark   ------ 以下两个方法会连着使用  -- ------
/**
 如果被调用的方法没有找到 方法 resolveInstanceMethod 和方法 forwardingTargetForSelector 都没有实现   就会调用此方法  返回创建的方法签名 然后调用  forwardInvocation  方法
 
  跟第二种方法一样   但它能通过NSInvocation对象获取更多消息发送的信息，例如：target、selector、arguments和返回值等信息
 @param aSelector 调用的方法
 @return 方法签名
 */



- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *methodSignature = [super methodSignatureForSelector:aSelector];

    if (!methodSignature) {
        methodSignature = [NSMethodSignature signatureWithObjCTypes:"v@:*"];
    }

    return methodSignature;
}


/**
   methodSignatureForSelector 方法调用完之后  就会调用此方法   在这个方法里面处理要调用的方法

   @param anInvocation 调用的方法   （封装后的对象）
 */
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    MessageForwarding *messageForwarding = [MessageForwarding new];
    NSLog(@"sel = %@",NSStringFromSelector(anInvocation.selector));
    if ([messageForwarding respondsToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:messageForwarding];
    }
}



@end
