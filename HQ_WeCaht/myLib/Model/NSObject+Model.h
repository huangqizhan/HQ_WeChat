//
//  NSObject+Model.h
//  YYStudy
//
//  Created by hqz  QQ 757618403 on 2018/5/2.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//

#import <Foundation/Foundation.h>

#define force_inline __inline__ __attribute__((always_inline))

/*
   propertyMeta  _mappedToKeyArray   _next  还没有搞
 
   接下来
 
   <Model> 里面的其他代理方法  的用处
 
 
 
 */

@interface NSObject (Model)

+ (instancetype)modelWithJSON:(id)json;


/**
 字典是否可以转化为模型
 */
- (BOOL)modelSetWithDictionary:(NSDictionary *)dic;

- (id)modelToJSONObject;

- (NSData *)modelToJSONData;

- (NSString *)modelToJSONString;

- (NSString *)modelDescription;

@end



@interface  NSArray (Model)

+ (NSArray *)modelArrayWithClass:(Class)cls json:(id)json;


@end




@interface  NSDictionary (Model)

+ (NSDictionary *)modelDictionaryWithClass:(Class)cls json:(id)json;


@end






@protocol  Model <NSObject>

@optional
/*
 模型中的代码
 
 @interface Model : NSObject
 @property NSString *name;
 @property NSInteger page;
 @property NSString *desc;
 @property NSString *bookID;
 @end
 
 @implementation Model
 + (NSDictionary *)modelCustomPropertyMapper {
     return @{@"name"  : @"n",
     @"page"  : @"p",
     @"desc"  : @"ext.desc",
     @"bookID": @[@"id", @"ID", @"book_id"]};
     }
 @end
 
 json
 {
     "n":"Harry Pottery",
     "p": 256,
     "ext" : {
         "desc" : "A book written by J.K.Rowling."
     },
     "ID" : 100010
 }
 */
///可自己定义json 跟 model 的对应字段表
+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper;

///model 对应的字段也是 model 
+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass;
///解析的时候 碰到一个字典 当前的解析类 可以根据字典返回一个类
+ (nullable Class)modelCustomClassForDictionary:(NSDictionary *)dictionary;
///黑名单
+ (nullable NSArray<NSString *> *)modelPropertyBlacklist;
///白名单
+ (nullable NSArray<NSString *> *)modelPropertyWhitelist;
/// 解析之前修改模型对应的字典
- (NSDictionary *)modelCustomWillTransformFromDictionary:(NSDictionary *)dic;
////json 转模型 如果此方法返回NO 该模型就会被忽略  ->  json 不会转成改模型
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic;
///模型转字典 转化后的字典是否需求
- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic;



@end
