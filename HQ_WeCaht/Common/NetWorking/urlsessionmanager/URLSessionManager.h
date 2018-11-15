//
//  URLSessionManager.h
//  AFDemo
//
//  Created by hqz on 2018/11/8.
//  Copyright © 2018年 8km. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "URLRequestSerialization.h"
#import "URLResponseSerialization.h"
#import "ReachabilityManager.h"
#import "SecurityPolicy.h"
#import "ReachabilityManager.h"


NS_ASSUME_NONNULL_BEGIN

/*
 
 NSURLSession 底层仍然使用的是NSURLConnection 每一个task都会是一个operaiton(里面是一个connection)
 NSURLSession 类似与一个 SD里面的OperationMananger

 
 每一个 task 都会绑定一个 URLSessionManagerTaskDelegate  来单独处理代理回调
 */

///某task 重置
FOUNDATION_EXPORT NSString * const NetworkingTaskDidResumeNotification;
///某task 已完成
FOUNDATION_EXPORT NSString * const NetworkingTaskDidCompleteNotification;
///某task 已暂停
FOUNDATION_EXPORT NSString * const NetworkingTaskDidSuspendNotification;
///某task 已无效
FOUNDATION_EXPORT NSString * const URLSessionDidInvalidateNotification;
/// 某task 下载移除文件失败
FOUNDATION_EXPORT NSString * const URLSessionDownloadTaskDidFailToMoveFileNotification;
/// 序列化响应已完成
FOUNDATION_EXPORT NSString * const NetworkingTaskDidCompleteSerializedResponseKey;
FOUNDATION_EXPORT NSString * const NetworkingTaskDidCompleteResponseSerializerKey;
///序列化后数据的key
FOUNDATION_EXPORT NSString * const NetworkingTaskDidCompleteResponseDataKey;
///
FOUNDATION_EXPORT NSString * const NetworkingTaskDidCompleteErrorKey;
FOUNDATION_EXPORT NSString * const NetworkingTaskDidCompleteAssetPathKey;

@interface URLSessionManager : NSObject<NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate, NSSecureCoding, NSCopying>

///session
@property (readonly, nonatomic, strong) NSURLSession *session;
///operationQueue
@property (readonly, nonatomic, strong) NSOperationQueue *operationQueue;

///response 序列化
@property (nonatomic, strong) id <URLResponseSerialization> responseSerializer;
///安全策略
@property (nonatomic, strong) SecurityPolicy *securityPolicy;
///网络监听 
@property (readwrite, nonatomic, strong) ReachabilityManager *reachabilityManager;
///当前session 所有的task
@property (readonly, nonatomic, strong) NSArray <NSURLSessionTask *> *tasks;
///当前session  所有的data task
@property (readonly, nonatomic, strong) NSArray <NSURLSessionDataTask *> *dataTasks;
///当前session 所有的upload task
@property (readonly, nonatomic, strong) NSArray <NSURLSessionUploadTask *> *uploadTasks;
///当前session 所有的download task
@property (readonly, nonatomic, strong) NSArray <NSURLSessionDownloadTask *> *downloadTasks;
///完成回调的队列
@property (nonatomic, strong, nullable) dispatch_queue_t completionQueue;
///完成回调的调度组
@property (nonatomic, strong, nullable) dispatch_group_t completionGroup;
///是否重新创建uploadTask（ios7 创建后台创建 uploadTask 时会为空）
@property (nonatomic, assign) BOOL attemptsToRecreateUploadTasksForBackgroundSessions;

- (instancetype)initWithSessionConfiguration:(nullable NSURLSessionConfiguration *)configuration NS_DESIGNATED_INITIALIZER;

///停止sesstion 
- (void)invalidateSessionCancelingTasks:(BOOL)cancelPendingTasks;


/// data task
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                            completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler;

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                               uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgressBlock
                             downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                            completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))completionHandler;

///uploadTask (文件路径)
- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         fromFile:(NSURL *)fileURL
                                         progress:(void (^)(NSProgress *uploadProgress)) uploadProgressBlock
                                completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler;
///创建uploadTask (数据流)
- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         fromData:(NSData *)bodyData
                                         progress:(void (^)(NSProgress *uploadProgress)) uploadProgressBlock
                                completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler;


///创建uploadTask （Stream）
- (NSURLSessionUploadTask *)uploadTaskWithStreamedRequest:(NSURLRequest *)request
                                                 progress:(void (^)(NSProgress *uploadProgress)) uploadProgressBlock
                                        completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler;
///downLoadTask
- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
                                             progress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                                          destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                    completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler;
/// 断点 下载
- (NSURLSessionDownloadTask *)downloadTaskWithResumeData:(NSData *)resumeData
                                                progress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                                             destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                       completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler;

///updatatask progress
- (nullable NSProgress *)uploadProgressForTask:(NSURLSessionTask *)task;

///download progress
- (nullable NSProgress *)downloadProgressForTask:(NSURLSessionTask *)task;

///sesstion 变为无效的回调
- (void)setSessionDidBecomeInvalidBlock:(nullable void (^)(NSURLSession *session, NSError *error))block;
///收到证书认证的回调
- (void)setSessionDidReceiveAuthenticationChallengeBlock:(nullable NSURLSessionAuthChallengeDisposition (^)(NSURLSession *session, NSURLAuthenticationChallenge *challenge, NSURLCredential * _Nullable __autoreleasing * _Nullable credential))block;
///后台任务完成回调
- (void)setDidFinishEventsForBackgroundURLSessionBlock:(void (^)(NSURLSession *session))block ;
///需要添加bodyStream 回调
- (void)setTaskNeedNewBodyStreamBlock:(NSInputStream * (^)(NSURLSession *session, NSURLSessionTask *task))block;
///将要重定向
- (void)setTaskWillPerformHTTPRedirectionBlock:(NSURLRequest * (^)(NSURLSession *session, NSURLSessionTask *task, NSURLResponse *response, NSURLRequest *request))block;
///task 收到证书认证
- (void)setTaskDidReceiveAuthenticationChallengeBlock:(NSURLSessionAuthChallengeDisposition (^)(NSURLSession *session, NSURLSessionTask *task, NSURLAuthenticationChallenge *challenge, NSURLCredential * __autoreleasing *credential))block;
///task 已经发送bodyData
- (void)setTaskDidSendBodyDataBlock:(void (^)(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend))block ;

///task 已经完成
- (void)setTaskDidCompleteBlock:(void (^)(NSURLSession *session, NSURLSessionTask *task, NSError *error))block;
///task 已经收到响应
- (void)setDataTaskDidReceiveResponseBlock:(NSURLSessionResponseDisposition (^)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLResponse *response))block;
///data Task 变为downloadTask 
- (void)setDataTaskDidBecomeDownloadTaskBlock:(void (^)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLSessionDownloadTask *downloadTask))block;
///data task 已经收到data 
- (void)setDataTaskDidReceiveDataBlock:(void (^)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSData *data))block;
///data task 将要缓存response
- (void)setDataTaskWillCacheResponseBlock:(NSCachedURLResponse * (^)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSCachedURLResponse *proposedResponse))block;
///download task 已经下载完成
- (void)setDownloadTaskDidFinishDownloadingBlock:(NSURL * (^)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, NSURL *location))block;
///downlaod 开始写入数据
- (void)setDownloadTaskDidWriteDataBlock:(void (^)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite))block;
//// 开始断点下载 
- (void)setDownloadTaskDidResumeBlock:(void (^)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t fileOffset, int64_t expectedTotalBytes))block;
@end

NS_ASSUME_NONNULL_END
