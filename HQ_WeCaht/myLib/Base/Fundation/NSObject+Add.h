//
//  NSObject+Add.h
//  YYKitStudy
//
//  Created by GoodSrc on 2017/11/23.
//  Copyright © 2017年 GoodSrc. All rights reserved.
//

#import <Foundation/Foundation.h>

///如果需要每个属性或每个方法都去指定nonnull和nullable，是一件非常繁琐的事。苹果为了减轻我们的工作量，专门提供了两个宏：NS_ASSUME_NONNULL_BEGIN和NS_ASSUME_NONNULL_END。在这两个宏之间的代码，所有简单指针对象都被假定为nonnull，因此我们只需要去指定那些nullable的指针

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Add)

/**
  1，如果有方法没有在.h文件中公开  可用此方法调用
  2， 可用此方法替换原来的方法

 @param sel 方法的调用者
 @return 方法的返回值
 */
- (id)performSelectorWithArgs:(SEL)sel, ...;



- (void)performSelectorWithArgs:(SEL)sel afterDelay:(NSTimeInterval)delay, ...;



///交换两个实例方法
+ (BOOL)swizzleInstanceMethod:(SEL)originalSel with:(SEL)newSel;

///交换两个类方法
+ (BOOL)swizzleClassMethod:(SEL)originalSel with:(SEL)newSel;

///添加强类型属性
- (void)setAssociateValue:(nullable id)value withKey:(void *)key;

///添加弱类型属性
- (void)setAssociateWeakValue:(nullable id)value withKey:(void *)key;

///删除关联的值
- (void)removeAssociatedValues;

////获取所对应的属性的值
- (nullable id)getAssociatedValueForKey:(void *)key;

+ (NSString *)className;

- (NSString *)className;

///深拷贝自己
- (nullable id)deepCopy;



@end


NS_ASSUME_NONNULL_END
