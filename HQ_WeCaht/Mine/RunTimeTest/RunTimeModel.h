//
//  RunTimeModel.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/12/18.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <Foundation/Foundation.h>


/*
 运行时Runtime的一切都围绕这两个中心：类的动态配置 和 消息传递。
 1). 动态的添加对象的成员变量和方法
 2). 动态交换两个方法的实现
 3). 实现分类也可以添加属性
 4). 实现NSCoding的自动归档和解档
 5). 实现字典转模型的自动转换
 
 */


@interface RunTimeModel : NSObject
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *address;


-(NSString *)firstSay;
-(NSString *)secondSay;

@end
