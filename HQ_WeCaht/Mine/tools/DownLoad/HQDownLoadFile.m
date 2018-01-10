//
//  HQDownLoadFile.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/5/19.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQDownLoadFile.h"
#import <CommonCrypto/CommonDigest.h>
#import "HQCFunction.h"
#import "HQDownLoadTempModel.h"

NSString *const HQDownLoadFileCache = @"HQDownLoadFileCache";

@interface HQDownLoadFile ()<NSURLSessionDataDelegate>

/////安全队列     保证指定的任务都会在一个队列里面执行    防止线程死锁
//// 比如一个queue A，将任务T sync至queue B，而任务T中又将一个子任务 S sync至queue A中，这将必然导致A和B都锁死
@property (nonatomic,strong) dispatch_queue_t synchronizationQueue;
////会话
@property (nonatomic,strong) NSURLSession *session;
////允许最大的下载个数
@property (nonatomic, assign) NSInteger maximumActiveDownloads;
////当前正在下载的请求个数
@property (nonatomic, assign) NSInteger activeRequestCount;
////任务键值对
@property (nonatomic,strong,nullable) HQDownLoadDictionary *tasksDic;
///队列里面的所有任务
@property (nonatomic,strong,nullable) HQDownLoadTaskArray *queueTasks;
///所有的receipt键值对
@property (nonatomic,strong,nullable) HQDownLoadReceiptDictionary *allDownloadReceipts;
////进入后台的identifer
@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundTaskId;


@end

@implementation HQDownLoadFile

+ (NSURLSessionConfiguration *)defaultURLSessionConfiguration{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.HTTPShouldSetCookies = YES;
    ////是否顺序下载
    configuration.HTTPShouldUsePipelining = NO;
    ///缓存策略
    configuration.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    ////属性指定是否允许使用蜂窝连接
    configuration.allowsCellularAccess = YES;
    ///属性为YES时表示当程序在后台运作时由系统自己选择最佳的网络连接配置，该属性可以节省通过蜂窝连接的带宽
    configuration.discretionary = YES;
    ////加载时间限制
    configuration.timeoutIntervalForRequest = 60;
    ////最大链接数
    configuration.HTTPMaximumConnectionsPerHost = 10;
    return configuration;
}
- (instancetype)init{
    NSURLSessionConfiguration *configeration = [self.class defaultURLSessionConfiguration];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    NSURLSession *sesstion = [NSURLSession sessionWithConfiguration:configeration delegate:self delegateQueue:queue];
    return [self initWithSession:sesstion downloadPrioritization:HQDownLoadPriorizationLIFO maximumActiveDownloads:3];
}

- (instancetype)initWithSession:(NSURLSession *)session
         downloadPrioritization:(HQDownLoadPriorization)downloadPrioritization
         maximumActiveDownloads:(NSInteger)maximumActiveDownloads{
    self = [super init];
    if (self) {
        self.session = session;
        self.priorization = downloadPrioritization;
        self.maximumActiveDownloads = maximumActiveDownloads;
        self.tasksDic = [[HQDownLoadDictionary alloc] init];
        self.queueTasks = [[HQDownLoadTaskArray alloc] init];
        self.allDownloadReceipts = [[HQDownLoadReceiptDictionary alloc] init];
        self.activeRequestCount = 0;
        NSString *name = [NSString stringWithFormat:@"hqdownLoad_%@",[[NSUUID UUID] UUIDString]];
        self.synchronizationQueue = dispatch_queue_create([name cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_SERIAL);
        ///APP将要关闭
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
        ////APP收到内存警告
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        ///APP将要失去活跃状态
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        ///APP将要变为活跃状态
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

+ (nonnull instancetype)DefaultManager{
    static HQDownLoadFile *loadFile;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        loadFile = [[HQDownLoadFile alloc] init];
    });
    return loadFile;
}
///归档
- (void)saveReceipt:(HQDownLoadReceiptDictionary *)allReceipt{
    [HQDownLoadTempModel UpdateModel:allReceipt andComlite:^(BOOL result) {
        NSLog(@"result = %d",result);
    }];
}
- (void)downLoadWithUrl:(nullable HQDownLoadTempModel *)model
                                       process:(_Nullable HQDownLoadProcessBlok)processBlock
                                       success:(_Nullable HQDownLoadSuccessBlock)successBlock
                                       failure:(_Nullable HQDownLoadFaildBlock)failureBlock{
    
    [self checkTempModel:model];
    ///queue 添加 2
    dispatch_sync(self.synchronizationQueue, ^{
        NSString *ulrIdentifier = model.urlStr;
        if (ulrIdentifier == nil) {
            if (failureBlock) {
                NSError *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:NSURLErrorBadURL userInfo:nil];
                failureBlock(nil,nil,error);
            }
            return ;
        }
        model.processBlok = processBlock;
        model.successBlock = successBlock;
        model.faildBlock = failureBlock;
        
        if (model.status == HQDownLoadFileStatusComplite && model.totalBytesWritten == model.totalBytesExpectedToWrite) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (model.successBlock) {
                    model.successBlock(nil,nil,[NSURL URLWithString:model.urlStr]);
                }
                return ;
            });
        }
        if (model.status == HQDownLoadFileStatusLoading && model.totalBytesExpectedToWrite != model.totalBytesWritten) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (model.processBlok) {
                    model.processBlok(model.progress,model);
                }
                return ;
            });
        }
        NSURLSessionDataTask *task = [self.tasksDic objectForKey:model.urlStr];
        if (!task || (task.state != NSURLSessionTaskStateRunning && task.state != NSURLSessionTaskStateSuspended)) {
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:model.urlStr]];
            ////接着上一次的下载的地方继续下载
            NSString *range = [NSString stringWithFormat:@"bytes=%zd-",model.totalBytesWritten];
            ///设置请求头
            [request setValue:range forHTTPHeaderField:@"Range"];
            task = [self.session dataTaskWithRequest:request];
            task.taskDescription = model.urlStr;
            self.tasksDic[model.urlStr] = task;
            [self.queueTasks addObject:task];
        }
        [self sesstionResumeWithReceipt:model];
    });
}
#pragma mark -  NSNotification
- (void)applicationWillTerminate:(NSNotification *)not {
    [self suspendAll];
}
- (void)applicationDidReceiveMemoryWarning:(NSNotification *)not {
    [self suspendAll];
}
- (void)applicationDidBecomeActive:(NSNotification *)not{
    Class applicationCalss = NSClassFromString(@"UIApplication");
    if (applicationCalss == nil || ![applicationCalss respondsToSelector:@selector(sharedApplication)]) {
        return;
    }
    if (self.backgroundTaskId != UIBackgroundTaskInvalid) {
        UIApplication * app = [UIApplication performSelector:@selector(sharedApplication)];
        [app endBackgroundTask:self.backgroundTaskId];
        self.backgroundTaskId = UIBackgroundTaskInvalid;
    }
}
- (void)applicationWillResignActive:(NSNotification *)not{
    /// 捕获到失去激活状态后
    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    BOOL hasApplication = UIApplicationClass && [UIApplicationClass respondsToSelector:@selector(sharedApplication)];
    if (hasApplication ) {
        __weak __typeof__ (self) wself = self;
        UIApplication * app = [UIApplicationClass performSelector:@selector(sharedApplication)];
        self.backgroundTaskId = [app beginBackgroundTaskWithExpirationHandler:^{
            __strong __typeof (wself) sself = wself;
            
            if (sself) {
                [sself suspendAll];
                
                [app endBackgroundTask:sself.backgroundTaskId];
                sself.backgroundTaskId = UIBackgroundTaskInvalid;
            }
        }];
    }
}
- (void)checkTempModel:(HQDownLoadTempModel *)model{
    if (model == nil) {
        return;
    }
    HQDownLoadTempModel *receipt = [self.allDownloadReceipts objectForKey:model.urlStr];
    if (receipt == nil) {
        ///queue 添加 1
        dispatch_sync(self.synchronizationQueue, ^{
            [self.allDownloadReceipts setObject:model forKey:model.urlStr];
        });

    }
}
- (HQDownLoadTempModel *)downLoadReceiptForUr:(NSString *)url{
    if (!url) return nil;
    HQDownLoadTempModel *receipt = [self.allDownloadReceipts objectForKey:url];
//    if (receipt) return receipt;
//    receipt = [[HQDownLoadTempModel alloc] init];
//    receipt.status = HQDownLoadFileStatusNone;
//    receipt.totalBytesExpectedToWrite = 1;
//    ///queue 添加 1
//    dispatch_sync(self.synchronizationQueue, ^{
//        [self.allDownloadReceipts setObject:receipt forKey:url];
//        [self saveReceipt:self.allDownloadReceipts];
//    });
    return receipt;
}
- (NSURLSessionDataTask *)dequeueTask {
    NSURLSessionDataTask *task = nil;
    task = [self.queueTasks firstObject];
    [self.queueTasks removeObject:task];
    return task;
}

///全部暂停
- (void)suspendAll{
    for (NSURLSessionDataTask *task in self.queueTasks) {
        HQDownLoadTempModel *receipt = [self downLoadReceiptForUr:task.taskDescription];
        receipt.status = HQDownLoadFileStatusFaild;
        [task suspend];
        [self safelyDecrementActiveTaskCount];
    }
    [self saveReceipt:self.allDownloadReceipts];
}
- (void)safelyDecrementActiveTaskCount{
    dispatch_sync(self.synchronizationQueue, ^{
        if (self.activeRequestCount > 0) {
            self.activeRequestCount -=1;
        }
    });
}
////开始下一个下载
- (void)safelyStartNextTaskIfNecessary{
    dispatch_sync(self.synchronizationQueue, ^{
        if ([self isActiveRequestCountBelowMaximumLimit]){
            while (self.queueTasks.count > 0) {
                NSURLSessionDataTask *task = [self dequeueTask];
                HQDownLoadTempModel *receipt = [self downLoadReceiptForUr:task.taskDescription];
                if (task.state == NSURLSessionTaskStateSuspended && receipt.status == HQDownLoadFileStatusWaiting) {
                    [self startReceipt:task];
                    break;
                }
            }
        }
    });
}
- (void)sesstionResumeWithReceipt:(HQDownLoadTempModel *)receipt{
    if ([self isActiveRequestCountBelowMaximumLimit]) {
        NSURLSessionDataTask *task = self.tasksDic[receipt.urlStr];
        if (!task || (task.state != NSURLSessionTaskStateRunning && task.state != NSURLSessionTaskStateSuspended)) {
            [self downLoadWithUrl:receipt process:receipt.processBlok success:receipt.successBlock failure:receipt.faildBlock];
        }else{
            [self startReceipt:self.tasksDic[receipt.urlStr]];
            receipt.date = [NSDate date];
        }
    }else{
        receipt.status = HQDownLoadFileStatusWaiting;
        [self saveReceipt:self.allDownloadReceipts];
        [self enqueueTask:self.tasksDic[receipt.urlStr]];
    }
}
- (void)enqueueTask:(NSURLSessionDataTask *)task{
    switch (self.priorization) {
        case HQDownLoadPriorizationFIFO:
            [self.queueTasks addObject:task];
            break;
        case HQDownLoadPriorizationLIFO:
            [self.queueTasks insertObject:task atIndex:0];
            break;
        default:
            break;
    }
}
- (void)startReceipt:(NSURLSessionDataTask *)task{
    [task resume];
    ++self.activeRequestCount;
    [self updateReceiptWithURL:task.taskDescription andState:HQDownLoadFileStatusLoading];
}
- (void)updateReceiptWithURL:(NSString *)url andState:(HQDownLoadFileStatus)state{
    HQDownLoadTempModel *recept = self.allDownloadReceipts[url];
    recept.status = state;
    [self saveReceipt:self.allDownloadReceipts];
}

- (BOOL)isActiveRequestCountBelowMaximumLimit {
    return self.activeRequestCount < self.maximumActiveDownloads;
}

#pragma mark --------- HQDownloadControlDelegate ------
- (void)suspendWithURL:(NSString * _Nonnull)url{
    if (!url) {
        return;
    }
    HQDownLoadTempModel *receipt = [self downLoadReceiptForUr:url];
    [self suspendWithDownloadReceipt:receipt];
}
- (void)suspendWithDownloadReceipt:(HQDownLoadTempModel * _Nonnull)receipt{
    ///跟新数据库
    [self updateReceiptWithURL:receipt.urlStr andState:HQDownLoadFileStatusSuspend];
    NSURLSessionDataTask *task = self.tasksDic[receipt.urlStr];
    if (task) {
        [task suspend];
        [self safelyDecrementActiveTaskCount];
        [self safelyStartNextTaskIfNecessary];
    }
}
- (void)removeWithURL:(NSString * _Nonnull)url{
    if (url == nil) {
        return;
    }
    HQDownLoadTempModel *receipt = [self downLoadReceiptForUr:url];
    [self removeWithDownloadReceipt:receipt];
}
- (void)removeWithDownloadReceipt:(HQDownLoadTempModel * _Nonnull)receipt{
    NSURLSessionDataTask *task = self.tasksDic[receipt.urlStr];
    if (task) {
        [task cancel];
    }
    [self.queueTasks removeObject:task];
    [self safelyRemoveTaskWithURLIdentifier:receipt.urlStr];
    dispatch_sync(self.synchronizationQueue, ^{
        [self.allDownloadReceipts removeObjectForKey:receipt.urlStr];
        [self saveReceipt:self.allDownloadReceipts];
    });
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:receipt.filePath error:nil];
}
- (void)removeCurrentDownLoadWhenCompliteWith:(HQDownLoadTempModel *)receipt{
    NSURLSessionDataTask *task = self.tasksDic[receipt.urlStr];
    if (task) {
        [task cancel];
    }
    [self.queueTasks removeObject:task];
    [self safelyRemoveTaskWithURLIdentifier:receipt.urlStr];
    dispatch_sync(self.synchronizationQueue, ^{
        [self.allDownloadReceipts removeObjectForKey:receipt.urlStr];
        [self saveReceipt:self.allDownloadReceipts];
    });
}
- (NSURLSessionDataTask*)safelyRemoveTaskWithURLIdentifier:(NSString *)URLIdentifier {
    __block NSURLSessionDataTask *task = nil;
    dispatch_sync(self.synchronizationQueue, ^{
        task = [self removeTaskWithURLIdentifier:URLIdentifier];
    });
    return task;
}

//This method should only be called from safely within the synchronizationQueue
- (NSURLSessionDataTask *)removeTaskWithURLIdentifier:(NSString *)URLIdentifier {
    NSURLSessionDataTask *task = self.tasksDic[URLIdentifier];
    [self.tasksDic removeObjectForKey:URLIdentifier];
    return task;
}


#pragma mark --------- NSURLSessionDataDelegate---------
///收到http相应
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    HQDownLoadTempModel *receipt = [self downLoadReceiptForUr:dataTask.taskDescription];
    receipt.totalBytesExpectedToWrite = receipt.totalBytesWritten + dataTask.countOfBytesExpectedToReceive;
    receipt.status = HQDownLoadFileStatusLoading;
    [self saveReceipt:self.allDownloadReceipts];
    completionHandler(NSURLSessionResponseAllow);
}
//收到数据
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    dispatch_sync(self.synchronizationQueue, ^{
        __block NSError *error = nil;
        HQDownLoadTempModel *receipt = self.allDownloadReceipts[dataTask.taskDescription];
        ///speed
        receipt.totalRead += data.length;
        NSDate *currentDate = [NSDate date];
        if ([currentDate timeIntervalSinceDate:receipt.date] >= 1) {
            double timel = [currentDate timeIntervalSinceDate:receipt.date];
            long long  speed = receipt.totalRead/timel;
            receipt.speed = [self formatByteCount:speed];
            receipt.totalRead = 0.0;
            receipt.date = currentDate;
        }
        ////write data
        NSInputStream *inpuStream = [[NSInputStream alloc] initWithData:data];
        [inpuStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        NSOutputStream *outSreeam = [[NSOutputStream alloc] initWithURL:[NSURL fileURLWithPath:receipt.filePath] append:YES];
        [outSreeam scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [inpuStream open];
        [outSreeam open];
        
        ////如果达到1024   开始写入磁盘
        while ([inpuStream hasBytesAvailable] && [outSreeam hasSpaceAvailable]) {
            uint8_t  buffer [1024];
            NSInteger bytesRead = [inpuStream read:buffer maxLength:1024];
            if (inpuStream.streamError || bytesRead <0) {
                error = inpuStream.streamError;
                break;
            }
            NSInteger bytesWritten = [outSreeam write:buffer maxLength:(NSInteger)bytesRead];
            if (outSreeam.streamError || bytesWritten < 0) {
                error = outSreeam.streamError;
                break;
            }
            if (bytesWritten == 0 && bytesRead == 0) {
                break;
            }
        }
        [outSreeam close];
        [inpuStream close];
        receipt.progress.totalUnitCount = receipt.totalBytesExpectedToWrite;
        receipt.progress.completedUnitCount = receipt.totalBytesWritten;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (receipt.processBlok) {
                receipt.processBlok(receipt.progress,receipt);
            }
        });
    });
}
//请求结束
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    HQDownLoadTempModel *receipt = [self downLoadReceiptForUr:task.taskDescription];
    if (error) {
        receipt.status = HQDownLoadFileStatusFaild;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (receipt.faildBlock) {
                receipt.faildBlock(task.originalRequest,(NSHTTPURLResponse *)task.response,error);
            }
        });
    }else{
        receipt.status = HQDownLoadFileStatusComplite;
        [receipt.stream close];
        receipt.stream = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (receipt.successBlock) {
                receipt.successBlock(task.originalRequest,(NSHTTPURLResponse *)task.response,task.originalRequest.URL);
            }
        });
    }
//    [self updateReceiptWithURL:receipt.urlStr andState:receipt.status];
    [self saveReceipt:self.allDownloadReceipts];
    [self removeCurrentDownLoadWhenCompliteWith:receipt];
    [self safelyDecrementActiveTaskCount];
    [self safelyStartNextTaskIfNecessary];
}
- (NSString*)formatByteCount:(long long)size{
    return [NSByteCountFormatter stringFromByteCount:size countStyle:NSByteCountFormatterCountStyleFile];
}
@end

