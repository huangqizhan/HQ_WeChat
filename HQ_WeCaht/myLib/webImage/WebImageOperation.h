//
//  WebImageOperation.h
//  YYStudyDemo
//
//  Created by hqz on 2018/7/10.
//  Copyright © 2018年 hqz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebImageCache.h"
#import "WebImageManager.h"

/*
 property 对应两个关键字 @synthesize @dynamic
 ' property (nonatomic,copy) NSString *title '
 编译器默认会 添加@synthesize name = _name 给属性name 添加成员变量_name  也可以手动添加@synthesize 生成自己定义的 成员变量 , 而且编辑器会给属性name 添加 setter getter 方法
 
 @dynamic 属性名  编辑器不会默认添加setter getter  可手动添加getter setter 方法  若没有实现 则会去父类里寻找
 
 */


NS_ASSUME_NONNULL_BEGIN

@interface WebImageOperation : NSOperation

@property (nonatomic, strong, readonly)           NSURLRequest      *request;  ///< The image URL request.
@property (nullable, nonatomic, strong, readonly) NSURLResponse     *response; ///< The response for request.
@property (nullable, nonatomic,strong,readonly) WebImageCache *cache;
@property (nonatomic, strong, readonly)           NSString          *cacheKey; ///< The image cache key.
@property (nonatomic, readonly)                   YYWebImageOptions options;   ///< The operation's option.

/**
 Whether the URL connection should consult the credential storage for authenticating
 the connection. Default is YES.
 
 @discussion This is the value that is returned in the `NSURLConnectionDelegate`
 method `-connectionShouldUseCredentialStorage:`.
 */
@property (nonatomic) BOOL shouldUseCredentialStorage;


/**
 The credential used for authentication challenges in `-connection:didReceiveAuthenticationChallenge:`.
 
 @discussion This will be overridden by any shared credentials that exist for the
 username or password of the request URL, if present.
 */
@property (nullable, nonatomic, strong) NSURLCredential *credential;


- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;


- (instancetype)initWithRequest:(NSURLRequest *)request
                        options:(YYWebImageOptions)options
                          cache:(nullable WebImageCache *)cache
                       cacheKey:(nullable NSString *)cacheKey
                       progress:(nullable YYWebImageProgressBlock)progress
                      transform:(nullable YYWebImageTransformBlock)transform
                     completion:(nullable YYWebImageCompletionBlock)completion NS_DESIGNATED_INITIALIZER;

@end


NS_ASSUME_NONNULL_END 
