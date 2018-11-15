//
//  NSObject+SubClass.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/8/1.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (SubClass)

+ (NSArray*)subclassesOfClass:(Class)parentClass;

@end
