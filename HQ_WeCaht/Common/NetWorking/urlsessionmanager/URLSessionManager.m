//
//  URLSessionManager.m
//  AFDemo
//
//  Created by hqz on 2018/11/8.
//  Copyright © 2018年 8km. All rights reserved.
//

#import "URLSessionManager.h"
#import <objc/runtime.h>

#ifndef NSFoundationVersionNumber_iOS_8_0
#define NSFoundationVersionNumber_With_Fixed_5871104061079552_bug 1140.11
#else
#define NSFoundationVersionNumber_With_Fixed_5871104061079552_bug NSFoundationVersionNumber_iOS_8_0
#endif

static dispatch_queue_t url_session_manager_creation_queue() {
    static dispatch_queue_t url_session_manager_creation_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        url_session_manager_creation_queue = dispatch_queue_create("com.alamofire.networking.session.manager.creation", DISPATCH_QUEUE_SERIAL);
    });
    return url_session_manager_creation_queue;
}
static void url_session_manager_create_task_safely(dispatch_block_t block) {
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_With_Fixed_5871104061079552_bug) {
        // Fix of bug
        // Open Radar:http://openradar.appspot.com/radar?id=5871104061079552 (status: Fixed in iOS8)
        // Issue about:https://github.com/AFNetworking/AFNetworking/issues/2093
        dispatch_sync(url_session_manager_creation_queue(), block);
    } else {
        block();
    }
}
static dispatch_queue_t url_session_manager_processing_queue() {
    static dispatch_queue_t url_session_manager_processing_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        url_session_manager_processing_queue = dispatch_queue_create("com.alamofire.networking.session.manager.processing", DISPATCH_QUEUE_CONCURRENT);
    });
    
    return url_session_manager_processing_queue;
}

static dispatch_group_t url_session_manager_completion_group() {
    static dispatch_group_t url_session_manager_completion_group;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        url_session_manager_completion_group = dispatch_group_create();
    });
    
    return url_session_manager_completion_group;
}
/// networking 的某个 task 重置
NSString * const NetworkingTaskDidResumeNotification = @"com.alamofire.networking.task.resume";
/// networking 的某个 task 已完成
NSString * const NetworkingTaskDidCompleteNotification = @"com.alamofire.networking.task.complete";
///networking 的某个 task 已暂停
NSString * const NetworkingTaskDidSuspendNotification = @"com.alamofire.networking.task.suspend";
/// task 已无效
NSString * const URLSessionDidInvalidateNotification = @"com.alamofire.networking.session.invalidate";
/// 下载失败
NSString * const URLSessionDownloadTaskDidFailToMoveFileNotification = @"com.alamofire.networking.session.download.file-manager-error";
/// 序列化响应已完成info Key
NSString * const NetworkingTaskDidCompleteSerializedResponseKey = @"com.alamofire.networking.task.complete.serializedresponse";
NSString * const NetworkingTaskDidCompleteResponseSerializerKey = @"com.alamofire.networking.task.complete.responseserializer";

NSString * const NetworkingTaskDidCompleteResponseDataKey = @"com.alamofire.networking.complete.finish.responsedata";
NSString * const NetworkingTaskDidCompleteErrorKey = @"com.alamofire.networking.task.complete.error";
NSString * const NetworkingTaskDidCompleteAssetPathKey = @"com.alamofire.networking.task.complete.assetpath";

static NSString * const URLSessionManagerLockName = @"com.alamofire.networking.session.manager.lock";

///尝试重新创建uploadTask 的次数
static NSUInteger const MaximumNumberOfAttemptsToRecreateBackgroundSessionUploadTask = 3;
///task 改变的 context
static void * TaskStateChangedContext = &TaskStateChangedContext;

///session 变成 无效的回调
typedef void (^URLSessionDidBecomeInvalidBlock)(NSURLSession *session, NSError *error);

///收到证书认证回调
typedef NSURLSessionAuthChallengeDisposition (^URLSessionDidReceiveAuthenticationChallengeBlock)(NSURLSession *session, NSURLAuthenticationChallenge *challenge, NSURLCredential * __autoreleasing *credential);
///task 将要重定向回调
typedef NSURLRequest * (^URLSessionTaskWillPerformHTTPRedirectionBlock)(NSURLSession *session, NSURLSessionTask *task, NSURLResponse *response, NSURLRequest *request);
///session task已经证书认证回调
typedef NSURLSessionAuthChallengeDisposition (^URLSessionTaskDidReceiveAuthenticationChallengeBlock)(NSURLSession *session, NSURLSessionTask *task, NSURLAuthenticationChallenge *challenge, NSURLCredential * __autoreleasing *credential);
////session 已经完成后台任务回调
typedef void (^URLSessionDidFinishEventsForBackgroundURLSessionBlock)(NSURLSession *session);
///task 需要添加新的body stream
typedef NSInputStream * (^URLSessionTaskNeedNewBodyStreamBlock)(NSURLSession *session, NSURLSessionTask *task);
///task 已经发送data 回调
typedef void (^URLSessionTaskDidSendBodyDataBlock)(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend);
///task 已经完成
typedef void (^URLSessionTaskDidCompleteBlock)(NSURLSession *session, NSURLSessionTask *task, NSError *error);

///task 已经收到响应
typedef NSURLSessionResponseDisposition (^URLSessionDataTaskDidReceiveResponseBlock)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLResponse *response);
///task 已经变为downLoad task
typedef void (^URLSessionDataTaskDidBecomeDownloadTaskBlock)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLSessionDownloadTask *downloadTask);

///data task 已经收到data
typedef void (^URLSessionDataTaskDidReceiveDataBlock)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSData *data);

///data task 将要缓存response
typedef NSCachedURLResponse * (^URLSessionDataTaskWillCacheResponseBlock)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSCachedURLResponse *proposedResponse);
///download task 已经下载完成
typedef NSURL * (^URLSessionDownloadTaskDidFinishDownloadingBlock)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, NSURL *location);

///download task 已经写入数据
typedef void (^URLSessionDownloadTaskDidWriteDataBlock)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite);
///download task 重置
typedef void (^URLSessionDownloadTaskDidResumeBlock)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t fileOffset, int64_t expectedTotalBytes);
///task process 回调
typedef void (^URLSessionTaskProgressBlock)(NSProgress *);
/// task 完成回调
typedef void (^URLSessionTaskCompletionHandler)(NSURLResponse *response, id responseObject, NSError *error);

/*
urlSesstion 创建的每一个task 都会绑定一个URLSessionManagerTaskDelegate  来处理task 的回调
*/
@interface URLSessionManagerTaskDelegate : NSObject<NSURLSessionTaskDelegate, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic, weak) URLSessionManager *manager;
@property (nonatomic, strong) NSMutableData *mutableData;
@property (nonatomic, strong) NSProgress *uploadProgress;
@property (nonatomic, strong) NSProgress *downloadProgress;
@property (nonatomic, copy) NSURL *downloadFileURL;
@property (nonatomic, copy) URLSessionDownloadTaskDidFinishDownloadingBlock downloadTaskDidFinishDownloading;
@property (nonatomic, copy) URLSessionTaskProgressBlock uploadProgressBlock;
@property (nonatomic, copy) URLSessionTaskProgressBlock downloadProgressBlock;
@property (nonatomic, copy) URLSessionTaskCompletionHandler completionHandler;

@end

@implementation URLSessionManagerTaskDelegate
- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.mutableData = [NSMutableData data];
    self.uploadProgress = [[NSProgress alloc] initWithParent:nil userInfo:nil];
    self.uploadProgress.totalUnitCount = NSURLSessionTransferSizeUnknown;
    
    self.downloadProgress = [[NSProgress alloc] initWithParent:nil userInfo:nil];
    self.downloadProgress.totalUnitCount = NSURLSessionTransferSizeUnknown;
    return self;
}
- (void)setupProgressForTask:(NSURLSessionTask *)task{
    __weak typeof(task) weakTask = task;
    self.uploadProgress.totalUnitCount = task.countOfBytesExpectedToSend;
    self.downloadProgress.totalUnitCount = task.countOfBytesExpectedToReceive;
    ///设置可以取消
    [self.uploadProgress setCancellable:YES];
    /// 取消回调
    [self.uploadProgress setCancellationHandler:^{
        __strong typeof(weakTask) strongTask = weakTask;
        [strongTask cancel];
    }];
    ///设置可以暂停
    [self.uploadProgress setPausable:YES];
    [self.uploadProgress setPausingHandler:^{
        __strong typeof(weakTask) strongTask = weakTask;
        [strongTask suspend];
    }];
    
    ///设置可以重置
    if ([self.uploadProgress respondsToSelector:@selector(setResumingHandler:)]) {
        [self.uploadProgress setResumingHandler:^{
            __strong typeof(weakTask) strongTask = weakTask;
            [strongTask resume];
        }];
    }
    ///设置可以取消
    [self.downloadProgress setCancellable:YES];
    /// 取消回调
    [self.downloadProgress setCancellationHandler:^{
        __strong typeof(weakTask) strongTask = weakTask;
        [strongTask cancel];
    }];
    ///设置可以暂停
    [self.downloadProgress setPausable:YES];
    [self.downloadProgress setPausingHandler:^{
        __strong typeof(weakTask) strongTask = weakTask;
        [strongTask suspend];
    }];
    
    ///设置可以重置
    if ([self.downloadProgress respondsToSelector:@selector(setResumingHandler:)]) {
        [self.downloadProgress setResumingHandler:^{
            __strong typeof(weakTask) strongTask = weakTask;
            [strongTask resume];
        }];
    }
    ///task 添加观察
    [task addObserver:self
           forKeyPath:NSStringFromSelector(@selector(countOfBytesReceived))
              options:NSKeyValueObservingOptionNew
              context:NULL];
    [task addObserver:self
           forKeyPath:NSStringFromSelector(@selector(countOfBytesExpectedToReceive))
              options:NSKeyValueObservingOptionNew
              context:NULL];
    
    [task addObserver:self
           forKeyPath:NSStringFromSelector(@selector(countOfBytesSent))
              options:NSKeyValueObservingOptionNew
              context:NULL];
    [task addObserver:self
           forKeyPath:NSStringFromSelector(@selector(countOfBytesExpectedToSend))
              options:NSKeyValueObservingOptionNew
              context:NULL];
    
    [self.downloadProgress addObserver:self
                            forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                               options:NSKeyValueObservingOptionNew
                               context:NULL];
    [self.uploadProgress addObserver:self
                          forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                             options:NSKeyValueObservingOptionNew
                             context:NULL];
}
///移除观察
- (void)cleanUpProgressForTask:(NSURLSessionTask *)task {
    [task removeObserver:self forKeyPath:NSStringFromSelector(@selector(countOfBytesReceived))];
    [task removeObserver:self forKeyPath:NSStringFromSelector(@selector(countOfBytesExpectedToReceive))];
    [task removeObserver:self forKeyPath:NSStringFromSelector(@selector(countOfBytesSent))];
    [task removeObserver:self forKeyPath:NSStringFromSelector(@selector(countOfBytesExpectedToSend))];
    [self.downloadProgress removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
    [self.uploadProgress removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
}
///观察处理
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([object isKindOfClass:[NSURLSessionTask class]] || [object isKindOfClass:[NSURLSessionDownloadTask class]]) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(countOfBytesReceived))]) {
            self.downloadProgress.completedUnitCount = [change[NSKeyValueChangeNewKey] longLongValue];
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(countOfBytesExpectedToReceive))]) {
            self.downloadProgress.totalUnitCount = [change[NSKeyValueChangeNewKey] longLongValue];
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(countOfBytesSent))]) {
            self.uploadProgress.completedUnitCount = [change[NSKeyValueChangeNewKey] longLongValue];
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(countOfBytesExpectedToSend))]) {
            self.uploadProgress.totalUnitCount = [change[NSKeyValueChangeNewKey] longLongValue];
        }
    }
    else if ([object isEqual:self.downloadProgress]) {
        if (self.downloadProgressBlock) {
            self.downloadProgressBlock(object);
        }
    }
    else if ([object isEqual:self.uploadProgress]) {
        if (self.uploadProgressBlock) {
            self.uploadProgressBlock(object);
        }
    }
}
#pragma mark ----- NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
    __strong URLSessionManager *manager = self.manager;
    
    __block id responseObject = nil;
    __block NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[NetworkingTaskDidCompleteResponseSerializerKey] = manager.responseSerializer;
    
    //Performance Improvement from #2672
    NSData *data = nil;
    if (self.mutableData) {
        data = [self.mutableData copy];
        //We no longer need the reference, so nil it out to gain back some memory.
        self.mutableData = nil;
    }
    
    if (self.downloadFileURL) {
        userInfo[NetworkingTaskDidCompleteAssetPathKey] = self.downloadFileURL;
    } else if (data) {
        userInfo[NetworkingTaskDidCompleteResponseDataKey] = data;
    }
    if (error) {
        userInfo[NetworkingTaskDidCompleteErrorKey] = error;
        
        dispatch_group_async(manager.completionGroup ?: url_session_manager_completion_group(), manager.completionQueue ?: dispatch_get_main_queue(), ^{
            if (self.completionHandler) {
                self.completionHandler(task.response, responseObject, error);
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:NetworkingTaskDidCompleteNotification object:task userInfo:userInfo];
            });
        });
    } else {
        dispatch_async(url_session_manager_processing_queue(), ^{
            NSError *serializationError = nil;
            responseObject = [manager.responseSerializer responseObjectForResponse:task.response data:data error:&serializationError];
            
            if (self.downloadFileURL) {
                responseObject = self.downloadFileURL;
            }
            
            if (responseObject) {
                userInfo[NetworkingTaskDidCompleteSerializedResponseKey] = responseObject;
            }
            
            if (serializationError) {
                userInfo[NetworkingTaskDidCompleteErrorKey] = serializationError;
            }
            
            dispatch_group_async(manager.completionGroup ?: url_session_manager_completion_group(), manager.completionQueue ?: dispatch_get_main_queue(), ^{
                if (self.completionHandler) {
                    self.completionHandler(task.response, responseObject, serializationError);
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:NetworkingTaskDidCompleteNotification object:task userInfo:userInfo];
                });
            });
        });
    }
#pragma clang diagnostic pop
}
#pragma mark - NSURLSessionDataTaskDelegate
- (void)URLSession:(__unused NSURLSession *)session
          dataTask:(__unused NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data{
    [self.mutableData appendData:data];
}
#pragma mark - NSURLSessionDownloadTaskDelegate
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location{
    NSError *fileManagerError = nil;
    self.downloadFileURL = nil;
    if (self.downloadTaskDidFinishDownloading) {
        self.downloadFileURL = self.downloadTaskDidFinishDownloading(session, downloadTask, location);
        if (self.downloadFileURL) {
            [[NSFileManager defaultManager] moveItemAtURL:location toURL:self.downloadFileURL error:&fileManagerError];
            
            if (fileManagerError) {
                [[NSNotificationCenter defaultCenter] postNotificationName:URLSessionDownloadTaskDidFailToMoveFileNotification object:downloadTask userInfo:fileManagerError.userInfo];
            }
        }
    }
}

@end


#pragma mark ------ iOS7 NSURLSessionTask 的 resume 方法不能监听 state属性  故替换原有的resume
///替换方法
static inline void swizzleSelector(Class class,SEL originalSelector,SEL swizzSelector){
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzMethod = class_getInstanceMethod(class, swizzSelector);
    method_exchangeImplementations(originalMethod, swizzMethod);
}
///给sessionTask  添加方法
static inline BOOL addMethod(Class class,SEL selector,Method method){
    return class_addMethod(class, selector, method_getImplementation(method), method_getTypeEncoding(method));
}
///sesstionTask 重置
static NSString * const NSURLSessionTaskDidResumeNotification  = @"com.alamofire.networking.nsurlsessiontask.resume";
///sesstionTask 暂停
static NSString * const NSURLSessionTaskDidSuspendNotification = @"com.alamofire.networking.nsurlsessiontask.suspend";
@interface _SessionTaskSwizzling : NSObject

@end

@implementation _SessionTaskSwizzling

///iOS7 NSURLSessionTask 的 resume 方法不能监听 state属性  故替换原有的resume
+ (void)load{
    if (NSClassFromString(@"NSURLSessionTask")) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession * session = [NSURLSession sessionWithConfiguration:configuration];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
        NSURLSessionDataTask *localDataTask = [session dataTaskWithURL:nil];
#pragma clang diagnostic pop
        IMP originalAFResumeIMP = method_getImplementation(class_getInstanceMethod([self class], @selector(af_resume)));
        Class currentClass = [localDataTask class];
        ///替换所有的resume
        while (class_getInstanceMethod(currentClass, @selector(resume))) {
            Class superClass = [currentClass superclass];
            IMP classResumeIMP = method_getImplementation(class_getInstanceMethod(currentClass, @selector(resume)));
            IMP superclassResumeIMP = method_getImplementation(class_getInstanceMethod(superClass, @selector(resume)));
            if (classResumeIMP != superclassResumeIMP &&
                originalAFResumeIMP != classResumeIMP) {
                [self swizzleResumeAndSuspendMethodForClass:currentClass];
            }
            currentClass = [currentClass superclass];
        }
        [localDataTask cancel];
        [session finishTasksAndInvalidate];
    }
}
////给class 添加方法  并且替换原来的方法
+ (void)swizzleResumeAndSuspendMethodForClass:(Class )class{
    Method resumeMethod = class_getInstanceMethod(self, @selector(af_resume));
    Method suspendMethod = class_getInstanceMethod(self, @selector(af_suspend));
    if (addMethod(class, @selector(af_resume), resumeMethod)) {
        swizzleSelector(class, @selector(resume), @selector(af_resume));
    }
    if (addMethod(class, @selector(af_suspend), suspendMethod)) {
        swizzleSelector(class, @selector(suspend), @selector(af_suspend));
    }
}
- (NSURLSessionTaskState)state {
    NSAssert(NO, @"State method should never be called in the actual dummy class");
    return NSURLSessionTaskStateCanceling;
}
////一下是模拟sesstionTask 的方法 是task 要调用的方法
- (void)af_resume {
    //此方法里面的self是sesstionTask
    NSAssert([self respondsToSelector:@selector(state)], @"Does not respond to state");
    NSURLSessionTaskState state = [self state];
    /// 调用方法 af_resume 实际上是调用 resume
    [self af_resume];
    
    if (state != NSURLSessionTaskStateRunning) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NSURLSessionTaskDidResumeNotification object:self];
    }
}
- (void)af_suspend {
    //此方法里面的self是sesstionTask
    NSAssert([self respondsToSelector:@selector(state)], @"Does not respond to state");
    NSURLSessionTaskState state = [self state];
    /// 调用方法 af_suspend 实际上是调用 suspend
    [self af_suspend];
    if (state != NSURLSessionTaskStateSuspended) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NSURLSessionTaskDidSuspendNotification object:self];
    }
}
@end

@interface URLSessionManager ()

@property (readwrite, nonatomic, strong) NSURLSessionConfiguration *sessionConfiguration;
@property (readwrite, nonatomic, strong) NSOperationQueue *operationQueue;
@property (readwrite, nonatomic, strong) NSURLSession *session;
///task delegates
@property (readwrite, nonatomic, strong) NSMutableDictionary *mutableTaskDelegatesKeyedByTaskIdentifier;
///标记在当前session下 重启或暂停的 task
@property (readonly, nonatomic, copy) NSString *taskDescriptionForSessionTasks;
@property (readwrite, nonatomic, strong) NSLock *lock;
///sesstion 已经失效
@property (readwrite, nonatomic, copy) URLSessionDidBecomeInvalidBlock sessionDidBecomeInvalid;
///sesstion 收到证书认证
@property (readwrite, nonatomic, copy) URLSessionDidReceiveAuthenticationChallengeBlock sessionDidReceiveAuthenticationChallenge;
///session 已经完成后台任务
@property (readwrite, nonatomic, copy) URLSessionDidFinishEventsForBackgroundURLSessionBlock didFinishEventsForBackgroundURLSession;
///task 将要重定向
@property (readwrite, nonatomic, copy) URLSessionTaskWillPerformHTTPRedirectionBlock taskWillPerformHTTPRedirection;
///task 收到证书认证
@property (readwrite, nonatomic, copy) URLSessionTaskDidReceiveAuthenticationChallengeBlock taskDidReceiveAuthenticationChallenge;
///task 需要添加body stream
@property (readwrite, nonatomic, copy) URLSessionTaskNeedNewBodyStreamBlock taskNeedNewBodyStream;
///task 已经发送body data
@property (readwrite, nonatomic, copy) URLSessionTaskDidSendBodyDataBlock taskDidSendBodyData;
///task 已经完成
@property (readwrite, nonatomic, copy) URLSessionTaskDidCompleteBlock taskDidComplete;
///data task 已经收到response
@property (readwrite, nonatomic, copy) URLSessionDataTaskDidReceiveResponseBlock dataTaskDidReceiveResponse;
///data task 已经变为下载task
@property (readwrite, nonatomic, copy) URLSessionDataTaskDidBecomeDownloadTaskBlock dataTaskDidBecomeDownloadTask;
///data task 已经收到data
@property (readwrite, nonatomic, copy) URLSessionDataTaskDidReceiveDataBlock dataTaskDidReceiveData;
///data task 将要缓存response
@property (readwrite, nonatomic, copy) URLSessionDataTaskWillCacheResponseBlock dataTaskWillCacheResponse;
///downLoad task 已经完成下载
@property (readwrite, nonatomic, copy) URLSessionDownloadTaskDidFinishDownloadingBlock downloadTaskDidFinishDownloading;
///download task 已经写入数据
@property (readwrite, nonatomic, copy) URLSessionDownloadTaskDidWriteDataBlock downloadTaskDidWriteData;
///download task 已经重置
@property (readwrite, nonatomic, copy) URLSessionDownloadTaskDidResumeBlock downloadTaskDidResume;

@end

@implementation URLSessionManager

- (instancetype)init{
    return [self initWithSessionConfiguration:nil];
}
- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration{
    self = [super init];
    if (!self) {
        return nil;
    }
    if (!configuration) {
        configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    }
    self.sessionConfiguration = configuration;
    self.operationQueue = [[NSOperationQueue alloc] init];
    self.operationQueue.maxConcurrentOperationCount = 1;
    self.session = [NSURLSession sessionWithConfiguration:self.sessionConfiguration delegate:self delegateQueue:self.operationQueue];
    self.responseSerializer = [JSONResponseSerializer serializer];
    self.reachabilityManager = [ReachabilityManager sharedManager];
    self.securityPolicy = [SecurityPolicy defaultPolicy];
    self.mutableTaskDelegatesKeyedByTaskIdentifier = [NSMutableDictionary new];
    self.lock = [[NSLock alloc] init];
    self.lock.name = URLSessionManagerLockName;
    
    [self.session getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
        
    }];
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (NSString *)taskDescriptionForSessionTasks{
    return [NSString stringWithFormat:@"%p",self];
}
///处理重启的task
- (void)taskDidResume:(NSNotification *)notification {
    NSURLSessionTask *task = notification.object;
    if ([task respondsToSelector:@selector(taskDescription)]) {
        if ([task.taskDescription isEqualToString:self.taskDescriptionForSessionTasks]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:NetworkingTaskDidResumeNotification object:task];
            });
        }
    }
}
///处理暂停的task
- (void)taskDidSuspend:(NSNotification *)notification{
    NSURLSessionTask *task = notification.object;
    if ([task respondsToSelector:@selector(taskDescription)]) {
        if ([task.taskDescription isEqualToString:self.taskDescriptionForSessionTasks]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:NetworkingTaskDidSuspendNotification object:task];
            });
        }
    }
}
///每一个task 对应一个TaskDelegate
- (URLSessionManagerTaskDelegate *)delegateForTask:(NSURLSessionTask *)task{
    NSParameterAssert(task);
    URLSessionManagerTaskDelegate *delegate = nil;
    [self.lock lock];
    delegate = self.mutableTaskDelegatesKeyedByTaskIdentifier[@(task.taskIdentifier)];
    [self.lock unlock];
    return delegate;
}
- (void)setDelegate:(URLSessionManagerTaskDelegate *)delegate
            forTask:(NSURLSessionTask *)task{
    NSParameterAssert(delegate);
    NSParameterAssert(task);
    [self.lock lock];
    self.mutableTaskDelegatesKeyedByTaskIdentifier[@(task.taskIdentifier)] = delegate;
    [delegate setupProgressForTask:task];
    [self addNotificationObserverForTask:task];
    [self.lock unlock];
}

////添加dataTask
- (void)addDelegateForDataTask:(NSURLSessionDataTask *)dataTask
                uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgressBlock
              downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgressBlock
             completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler{
    URLSessionManagerTaskDelegate *delegate = [[URLSessionManagerTaskDelegate alloc] init];
    delegate.manager = self;
    delegate.completionHandler = completionHandler;
    
    dataTask.taskDescription = self.taskDescriptionForSessionTasks;
    [self setDelegate:delegate forTask:dataTask];
    
    delegate.uploadProgressBlock = uploadProgressBlock;
    delegate.downloadProgressBlock = downloadProgressBlock;
}
///添加上传task
- (void)addDelegateForUploadTask:(NSURLSessionUploadTask *)uploadTask
                        progress:(void (^)(NSProgress *uploadProgress)) uploadProgressBlock
               completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler{
    URLSessionManagerTaskDelegate *delegate = [[URLSessionManagerTaskDelegate alloc] init];
    delegate.manager = self;
    delegate.completionHandler = completionHandler;
    
    uploadTask.taskDescription = self.taskDescriptionForSessionTasks;
    
    [self setDelegate:delegate forTask:uploadTask];
    
    delegate.uploadProgressBlock = uploadProgressBlock;
}
///添加downloadTask
- (void)addDelegateForDownloadTask:(NSURLSessionDownloadTask *)downloadTask
                          progress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                       destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                 completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler{
    URLSessionManagerTaskDelegate *delegate = [[URLSessionManagerTaskDelegate alloc] init];
    delegate.manager = self;
    delegate.completionHandler = completionHandler;
    
    if (destination) {
        delegate.downloadTaskDidFinishDownloading = ^NSURL * (NSURLSession * __unused session, NSURLSessionDownloadTask *task, NSURL *location) {
            return destination(location, task.response);
        };
    }
    
    downloadTask.taskDescription = self.taskDescriptionForSessionTasks;
    
    [self setDelegate:delegate forTask:downloadTask];
    
    delegate.downloadProgressBlock = downloadProgressBlock;
}
- (void)removeDelegateForTask:(NSURLSessionTask *)task {
    NSParameterAssert(task);
    
    URLSessionManagerTaskDelegate *delegate = [self delegateForTask:task];
    [self.lock lock];
    [delegate cleanUpProgressForTask:task];
    [self removeNotificationObserverForTask:task];
    [self.mutableTaskDelegatesKeyedByTaskIdentifier removeObjectForKey:@(task.taskIdentifier)];
    [self.lock unlock];
}

#pragma mark - get tasks ---

- (NSArray *)tasksForKeyPath:(NSString *)keyPath {
    __block NSArray *tasks = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(dataTasks))]) {
            tasks = dataTasks;
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(uploadTasks))]) {
            tasks = uploadTasks;
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(downloadTasks))]) {
            tasks = downloadTasks;
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(tasks))]) {
            tasks = [@[dataTasks, uploadTasks, downloadTasks] valueForKeyPath:@"@unionOfArrays.self"];
        }
        
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return tasks;
}
- (NSArray *)tasks {
    return [self tasksForKeyPath:NSStringFromSelector(_cmd)];
}

- (NSArray *)dataTasks {
    return [self tasksForKeyPath:NSStringFromSelector(_cmd)];
}

- (NSArray *)uploadTasks {
    return [self tasksForKeyPath:NSStringFromSelector(_cmd)];
}

- (NSArray *)downloadTasks {
    return [self tasksForKeyPath:NSStringFromSelector(_cmd)];
}

- (void)invalidateSessionCancelingTasks:(BOOL)cancelPendingTasks {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (cancelPendingTasks) {
            [self.session invalidateAndCancel];
        } else {
            [self.session finishTasksAndInvalidate];
        }
    });
}
- (void)setResponseSerializer:(id <URLResponseSerialization>)responseSerializer {
    NSParameterAssert(responseSerializer);
    
    _responseSerializer = responseSerializer;
}
#pragma mark -  注册通知
- (void)addNotificationObserverForTask:(NSURLSessionTask *)task {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskDidResume:) name:NSURLSessionTaskDidResumeNotification object:task];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskDidSuspend:) name:NSURLSessionTaskDidSuspendNotification object:task];
}

- (void)removeNotificationObserverForTask:(NSURLSessionTask *)task {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSURLSessionTaskDidSuspendNotification object:task];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSURLSessionTaskDidResumeNotification object:task];
}


#pragma mark ------- 请求 request
/// data task
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                            completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler{
    return [self dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:completionHandler];
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                               uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgressBlock
                             downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                            completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))completionHandler {
    __block NSURLSessionDataTask *task = nil;
    url_session_manager_create_task_safely(^{
        task = [self.session dataTaskWithRequest:request];
    });
    [self addDelegateForDataTask:task uploadProgress:uploadProgressBlock downloadProgress:downloadProgressBlock completionHandler:completionHandler];
    return task;
}
///uploadTask (文件路径)
- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         fromFile:(NSURL *)fileURL
                                         progress:(void (^)(NSProgress *uploadProgress)) uploadProgressBlock
                                completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler{
    __block NSURLSessionUploadTask *uploadTask = nil;
    url_session_manager_create_task_safely(^{
        uploadTask = [self.session uploadTaskWithRequest:request fromFile:fileURL];
    });
    if (!uploadTask && self.attemptsToRecreateUploadTasksForBackgroundSessions && self.session.configuration.identifier) {
        for (NSUInteger attempts = 0; !uploadTask && attempts < MaximumNumberOfAttemptsToRecreateBackgroundSessionUploadTask; attempts++) {
            uploadTask = [self.session uploadTaskWithRequest:request fromFile:fileURL];
        }
    }
    [self addDelegateForUploadTask:uploadTask progress:uploadProgressBlock completionHandler:completionHandler];
    return uploadTask;
}
///创建uploadTask (数据流)
- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         fromData:(NSData *)bodyData
                                         progress:(void (^)(NSProgress *uploadProgress)) uploadProgressBlock
                                completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler{
    __block NSURLSessionUploadTask *uploadTask = nil;
    url_session_manager_create_task_safely(^{
        uploadTask = [self.session uploadTaskWithRequest:request fromData:bodyData];
    });
    [self addDelegateForUploadTask:uploadTask progress:uploadProgressBlock completionHandler:completionHandler];
    return uploadTask;
}
///创建uploadTask （Stream）
- (NSURLSessionUploadTask *)uploadTaskWithStreamedRequest:(NSURLRequest *)request
                                                 progress:(void (^)(NSProgress *uploadProgress)) uploadProgressBlock
                                        completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler{
    __block NSURLSessionUploadTask *uploadTask = nil;
    url_session_manager_create_task_safely(^{
        uploadTask = [self.session uploadTaskWithStreamedRequest:request];
    });
    [self addDelegateForUploadTask:uploadTask progress:uploadProgressBlock completionHandler:completionHandler];
    return uploadTask;
}
///downLoadTask
- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
                                             progress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                                          destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                    completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler{
    __block NSURLSessionDownloadTask *downLoadTask = nil;
    url_session_manager_create_task_safely(^{
        downLoadTask = [self.session downloadTaskWithRequest:request];
    });
    [self addDelegateForDownloadTask:downLoadTask progress:downloadProgressBlock destination:destination completionHandler:completionHandler];
    return downLoadTask;
}
/// 断点 下载
- (NSURLSessionDownloadTask *)downloadTaskWithResumeData:(NSData *)resumeData
                                                progress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                                             destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                       completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler{
    __block NSURLSessionDownloadTask *downLoadTask = nil;
    url_session_manager_create_task_safely(^{
        [self.session downloadTaskWithResumeData:resumeData];
    });
    [self addDelegateForDownloadTask:downLoadTask progress:downloadProgressBlock destination:destination completionHandler:completionHandler];
    return downLoadTask;
}


- (NSProgress *)uploadProgressForTask:(NSURLSessionTask *)task {
    return [[self delegateForTask:task] uploadProgress];
}

- (NSProgress *)downloadProgressForTask:(NSURLSessionTask *)task {
    return [[self delegateForTask:task] downloadProgress];
}
- (void)setSessionDidBecomeInvalidBlock:(void (^)(NSURLSession *session, NSError *error))block {
    self.sessionDidBecomeInvalid = block;
}
- (void)setSessionDidReceiveAuthenticationChallengeBlock:(NSURLSessionAuthChallengeDisposition (^)(NSURLSession *session, NSURLAuthenticationChallenge *challenge, NSURLCredential * __autoreleasing *credential))block {
    self.sessionDidReceiveAuthenticationChallenge = block;
}
- (void)setDidFinishEventsForBackgroundURLSessionBlock:(void (^)(NSURLSession *session))block {
    self.didFinishEventsForBackgroundURLSession = block;
}

- (void)setTaskNeedNewBodyStreamBlock:(NSInputStream * (^)(NSURLSession *session, NSURLSessionTask *task))block {
    self.taskNeedNewBodyStream = block;
}

- (void)setTaskWillPerformHTTPRedirectionBlock:(NSURLRequest * (^)(NSURLSession *session, NSURLSessionTask *task, NSURLResponse *response, NSURLRequest *request))block {
    self.taskWillPerformHTTPRedirection = block;
}

- (void)setTaskDidReceiveAuthenticationChallengeBlock:(NSURLSessionAuthChallengeDisposition (^)(NSURLSession *session, NSURLSessionTask *task, NSURLAuthenticationChallenge *challenge, NSURLCredential * __autoreleasing *credential))block {
    self.taskDidReceiveAuthenticationChallenge = block;
}

- (void)setTaskDidSendBodyDataBlock:(void (^)(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend))block {
    self.taskDidSendBodyData = block;
}

- (void)setTaskDidCompleteBlock:(void (^)(NSURLSession *session, NSURLSessionTask *task, NSError *error))block {
    self.taskDidComplete = block;
}

#pragma mark -

- (void)setDataTaskDidReceiveResponseBlock:(NSURLSessionResponseDisposition (^)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLResponse *response))block {
    self.dataTaskDidReceiveResponse = block;
}

- (void)setDataTaskDidBecomeDownloadTaskBlock:(void (^)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLSessionDownloadTask *downloadTask))block {
    self.dataTaskDidBecomeDownloadTask = block;
}

- (void)setDataTaskDidReceiveDataBlock:(void (^)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSData *data))block {
    self.dataTaskDidReceiveData = block;
}

- (void)setDataTaskWillCacheResponseBlock:(NSCachedURLResponse * (^)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSCachedURLResponse *proposedResponse))block {
    self.dataTaskWillCacheResponse = block;
}

#pragma mark -

- (void)setDownloadTaskDidFinishDownloadingBlock:(NSURL * (^)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, NSURL *location))block {
    self.downloadTaskDidFinishDownloading = block;
}

- (void)setDownloadTaskDidWriteDataBlock:(void (^)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite))block {
    self.downloadTaskDidWriteData = block;
}

- (void)setDownloadTaskDidResumeBlock:(void (^)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t fileOffset, int64_t expectedTotalBytes))block {
    self.downloadTaskDidResume = block;
}
- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, session: %@, operationQueue: %@>", NSStringFromClass([self class]), self, self.session, self.operationQueue];
}
- (BOOL)respondsToSelector:(SEL)selector {
    if (selector == @selector(URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler:)) {
        return self.taskWillPerformHTTPRedirection != nil;
    } else if (selector == @selector(URLSession:dataTask:didReceiveResponse:completionHandler:)) {
        return self.dataTaskDidReceiveResponse != nil;
    } else if (selector == @selector(URLSession:dataTask:willCacheResponse:completionHandler:)) {
        return self.dataTaskWillCacheResponse != nil;
    } else if (selector == @selector(URLSessionDidFinishEventsForBackgroundURLSession:)) {
        return self.didFinishEventsForBackgroundURLSession != nil;
    }
    
    return [[self class] instancesRespondToSelector:selector];
}

#pragma mark - NSURLSessionDelegate
/// 回话失败
- (void)URLSession:(NSURLSession *)session
didBecomeInvalidWithError:(NSError *)error
{
    if (self.sessionDidBecomeInvalid) {
        self.sessionDidBecomeInvalid(session, error);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:URLSessionDidInvalidateNotification object:session];
}
/*
 1,客户端认证服务端发过来的公钥 NSURLAuthenticationMethodServerTrust 是认证服务端的公钥是否合法
 
 2,NSURLAuthenticationMethodClientCertificate 客户端发送自己的公钥 让服务端验证 (双向认证才有)
 
 单项认证 1
 双向认证 1 , 2
 一般情况下都是单向认证
 
 默认认证
 NSURLSessionAuthChallengePerformDefaultHandling
 使用Credential 认证
 NSURLSessionAuthChallengeUseCredential
 取消链接 NSURLSessionAuthChallengeCancelAuthenticationChallenge
 
 */
- (void)URLSession:(NSURLSession *)session
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler{
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;
    ///自定义创建 NSURLCredential
    if (self.sessionDidReceiveAuthenticationChallenge) {
        self.sessionDidReceiveAuthenticationChallenge(session,challenge,&credential);
    }else{
        ///系统认证
        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            if ([self.securityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:challenge.protectionSpace.host]) {
                credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
                if (credential) {
                    disposition = NSURLSessionAuthChallengeUseCredential;
                } else {
                    disposition = NSURLSessionAuthChallengePerformDefaultHandling;
                }
            }else{
                disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
            }
        }else{
            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        }
    }
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}
#pragma mark - NSURLSessionTaskDelegate
///task被重定向
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest *))completionHandler{
    NSURLRequest *redirectRequest = request;
    
    if (self.taskWillPerformHTTPRedirection) {
        redirectRequest = self.taskWillPerformHTTPRedirection(session, task, response, request);
    }
    
    if (completionHandler) {
        completionHandler(redirectRequest);
    }
}
///task 收到证书认证
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler{
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;
    
    if (self.taskDidReceiveAuthenticationChallenge) {
        disposition = self.taskDidReceiveAuthenticationChallenge(session, task, challenge, &credential);
    } else {
        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            if ([self.securityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:challenge.protectionSpace.host]) {
                disposition = NSURLSessionAuthChallengeUseCredential;
                credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            } else {
                disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
            }
        } else {
            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        }
    }
    
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}
///添加新的body stream
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
 needNewBodyStream:(void (^)(NSInputStream *bodyStream))completionHandler{
    NSInputStream *inputStream = nil;
    
    if (self.taskNeedNewBodyStream) {
        inputStream = self.taskNeedNewBodyStream(session, task);
    } else if (task.originalRequest.HTTPBodyStream && [task.originalRequest.HTTPBodyStream conformsToProtocol:@protocol(NSCopying)]) {
        inputStream = [task.originalRequest.HTTPBodyStream copy];
    }
    
    if (completionHandler) {
        completionHandler(inputStream);
    }
}
///task 已经发送bytes
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
    
    int64_t totalUnitCount = totalBytesExpectedToSend;
    if(totalUnitCount == NSURLSessionTransferSizeUnknown) {
        NSString *contentLength = [task.originalRequest valueForHTTPHeaderField:@"Content-Length"];
        if(contentLength) {
            totalUnitCount = (int64_t) [contentLength longLongValue];
        }
    }
    
    if (self.taskDidSendBodyData) {
        self.taskDidSendBodyData(session, task, bytesSent, totalBytesSent, totalUnitCount);
    }
}
///task 已经完成
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error{
    URLSessionManagerTaskDelegate *delegate = [self delegateForTask:task];
    
    // delegate may be nil when completing a task in the background
    if (delegate) {
        [delegate URLSession:session task:task didCompleteWithError:error];
        
        [self removeDelegateForTask:task];
    }
    
    if (self.taskDidComplete) {
        self.taskDidComplete(session, task, error);
    }
}
#pragma mark - NSURLSessionDataDelegate
///dataTask 已经收到response
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler{
    NSURLSessionResponseDisposition disposition = NSURLSessionResponseAllow;
    if (self.dataTaskDidReceiveResponse) {
        disposition = self.dataTaskDidReceiveResponse(session, dataTask, response);
    }
    if (completionHandler) {
        completionHandler(disposition);
    }
}
///dataTask 变为downloadTask
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask
{
    URLSessionManagerTaskDelegate *delegate = [self delegateForTask:dataTask];
    if (delegate) {
        [self removeDelegateForTask:dataTask];
        [self setDelegate:delegate forTask:downloadTask];
    }
    
    if (self.dataTaskDidBecomeDownloadTask) {
        self.dataTaskDidBecomeDownloadTask(session, dataTask, downloadTask);
    }
}
///dataTask 收到数据
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data{
    
    URLSessionManagerTaskDelegate *delegate = [self delegateForTask:dataTask];
    [delegate URLSession:session dataTask:dataTask didReceiveData:data];
    
    if (self.dataTaskDidReceiveData) {
        self.dataTaskDidReceiveData(session, dataTask, data);
    }
}
///缓存dataTask response
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler{
    NSCachedURLResponse *cachedResponse = proposedResponse;
    
    if (self.dataTaskWillCacheResponse) {
        cachedResponse = self.dataTaskWillCacheResponse(session, dataTask, proposedResponse);
    }
    
    if (completionHandler) {
        completionHandler(cachedResponse);
    }
}
///session 已经完成后台任务
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    if (self.didFinishEventsForBackgroundURLSession) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.didFinishEventsForBackgroundURLSession(session);
        });
    }
}

#pragma mark - NSURLSessionDownloadDelegate
////downloadTask 完成下载
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    URLSessionManagerTaskDelegate *delegate = [self delegateForTask:downloadTask];
    if (self.downloadTaskDidFinishDownloading) {
        NSURL *fileURL = self.downloadTaskDidFinishDownloading(session, downloadTask, location);
        if (fileURL) {
            delegate.downloadFileURL = fileURL;
            NSError *error = nil;
            [[NSFileManager defaultManager] moveItemAtURL:location toURL:fileURL error:&error];
            if (error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:URLSessionDownloadTaskDidFailToMoveFileNotification object:downloadTask userInfo:error.userInfo];
            }
            
            return;
        }
    }
    
    if (delegate) {
        [delegate URLSession:session downloadTask:downloadTask didFinishDownloadingToURL:location];
    }
}
////downloadTask 已经写入数据
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    if (self.downloadTaskDidWriteData) {
        self.downloadTaskDidWriteData(session, downloadTask, bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    }
}
///downloadTask 开始断点下载
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    if (self.downloadTaskDidResume) {
        self.downloadTaskDidResume(session, downloadTask, fileOffset, expectedTotalBytes);
    }
}
#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    NSURLSessionConfiguration *configuration = [decoder decodeObjectOfClass:[NSURLSessionConfiguration class] forKey:@"sessionConfiguration"];
    
    self = [self initWithSessionConfiguration:configuration];
    if (!self) {
        return nil;
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.session.configuration forKey:@"sessionConfiguration"];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    return [[[self class] allocWithZone:zone] initWithSessionConfiguration:self.session.configuration];
}
@end

