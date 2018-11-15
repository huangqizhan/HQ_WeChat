//
//  HTTPURLSessionManager.h
//  AFDemo
//
//  Created by hqz on 2018/11/9.
//  Copyright © 2018年 8km. All rights reserved.
//

#import "URLSessionManager.h"
#import "URLRequestSerialization.h"
#import "URLResponseSerialization.h"

NS_ASSUME_NONNULL_BEGIN

@interface HTTPURLSessionManager : URLSessionManager

/// request 序列化 
@property (nonatomic, strong) HttpRequestSerializer <URLRequestSerialization> * requestSerializer;

/// response 序列化 
@property (nonatomic, strong) HTTPResponseSerializer <URLResponseSerialization> * responseSerializer;

///创建实例
+ (instancetype)shareChatSession;

+ (instancetype)manager;
- (instancetype)initWithBaseURL:(nullable NSURL *)url;
- (instancetype)initWithBaseURL:(nullable NSURL *)url
           sessionConfiguration:(nullable NSURLSessionConfiguration *)configuration NS_DESIGNATED_INITIALIZER;
/**
 简单GET 请求

 @param URLString url
 @param parameters 参数 序列化的时候回拼接到URL后面
 @param success success
 @param failure failure
 @return dataTask
 */
- (nullable NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(nullable id)parameters
                      success:(nullable void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(nullable void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 GET 下载

 @param URLString url
 @param destination 下载完成后回调 获取文件路径
 @param downloadProgress progress
 @param completionHandler comlition
 @return downLoadTask
 */
- (nullable NSURLSessionDownloadTask *)GET:(NSString *)URLString
                               destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                  progress:(nullable void (^)(NSProgress * _Nonnull))downloadProgress
                         completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler;
///HEAD
- (nullable NSURLSessionDataTask *)HEAD:(NSString *)URLString
                    parameters:(nullable id)parameters
                       success:(nullable void (^)(NSURLSessionDataTask *task))success
                       failure:(nullable void (^)(NSURLSessionDataTask *task, NSError *error))failure;
///POST 没有process 只有完成失败回调
- (nullable NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(nullable id)parameters
                       success:(nullable void (^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(nullable void (^)(NSURLSessionDataTask *task, NSError *error))failure;
///POST 有process 失败成功回调
- (nullable NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(nullable id)parameters
                      progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress
                       success:(nullable void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success
                       failure:(nullable void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure;
///PUT 
- (nullable NSURLSessionDataTask *)PUT:(NSString *)URLString
                   parameters:(nullable id)parameters
                      success:(nullable void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(nullable void (^)(NSURLSessionDataTask *task, NSError *error))failure;
///POST 有添加文件 stream 没有process
- (nullable NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(nullable id)parameters
     constructingBodyWithBlock:(nullable void (^)(id<MultipartFormData> _Nonnull))block
                       success:(nullable void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success
                       failure:(nullable void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure;
///可以添加文件 stream 有 process
- (nullable NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(nullable id)parameters
     constructingBodyWithBlock:(nullable void (^)(id <MultipartFormData> formData))block
                      progress:(nullable nullable void (^)(NSProgress * _Nonnull))uploadProgress
                       success:(nullable void (^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(nullable void (^)(NSURLSessionDataTask *task, NSError *error))failure;
//// PATCH 
- (nullable NSURLSessionDataTask *)PATCH:(NSString *)URLString
                     parameters:(nullable id)parameters
                        success:(nullable void (^)(NSURLSessionDataTask *task, id responseObject))success
                        failure:(nullable void (^)(NSURLSessionDataTask *task, NSError *error))failure;
/// DELETE 
- (nullable NSURLSessionDataTask *)DELETE:(NSString *)URLString
                      parameters:(nullable id)parameters
                         success:(nullable void (^)(NSURLSessionDataTask *task, id responseObject))success
                         failure:(nullable void (^)(NSURLSessionDataTask *task, NSError *error))failure;

@end


NS_ASSUME_NONNULL_END
