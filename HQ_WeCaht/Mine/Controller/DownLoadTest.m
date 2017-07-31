//
//  DownLoadTest.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/5/17.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "DownLoadTest.h"
#import "DownLoadOperation.h"


@implementation DownloadToken

@end


@interface DownLoadTest ()


@property (assign, nonatomic, nullable) Class operationClass;

@property (nonatomic,strong) NSOperationQueue *downLoadQueue;

@property (nonatomic,strong) NSURLSessionConfiguration *sessionConfigeration;

@property (strong, nonatomic, nullable) dispatch_queue_t barrierQueue;

////记录最后加到队列里面的一个OPeraiton
@property (nonatomic,weak,nullable) NSOperation *lastAddOperation;

@property (strong, nonatomic, nonnull) NSMutableDictionary<NSURL *, DownLoadOperation *> *URLOperations;

@property (strong, nonatomic, nullable) HTTPHeadersMutableDictionary *HTTPHeaders;

////如果在downLoadtext 里面创建了session  operation 里面就不用创建 代理方法就会在 downLoadText里面调用
@property (strong, nonatomic) NSURLSession *session;


@end


@implementation DownLoadTest

- (instancetype)init{
    return  [self initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
}
- (nonnull instancetype) initWithSessionConfiguration:(NSURLSessionConfiguration *)sessionConfiguration{
    self = [super init];
    if (self) {
        _downLoadQueue = [NSOperationQueue new];
        _downLoadQueue.maxConcurrentOperationCount = 1;
        _downLoadQueue.name = @"hqDownLoad";
        _sessionConfigeration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _HTTPHeaders = [@{@"Accept": @"image/*;q=0.8"} mutableCopy];
        //image/webp是web格式的图片，q=0.8指的是权重系数为0.8，q的取值范围是0 - 1， 默认值为1，q作用于它前边分号;前边的内容。在这里，image/webp,image/*;q=0.8表示优先接受image/webp,其次接受image/*的图片
        _sessionConfigeration.timeoutIntervalForRequest = 30;
        _URLOperations = [NSMutableDictionary new];
        _barrierQueue = dispatch_queue_create("com.hackemist.SDWebImageDownloaderBarrierQueue", DISPATCH_QUEUE_CONCURRENT);
        sessionConfiguration.timeoutIntervalForRequest = 15;
        //_session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    }
    return self;
}

+ (nullable instancetype)shareDownLoadManager{
    static DownLoadTest *text = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        text = [[DownLoadTest alloc] init];
    });
    return text;
}
- (void)setValue:(NSString *)value forHTTPHeaderField:(nullable NSString *)field{
    if (value) {
        self.HTTPHeaders[field] = value;
    }else{
        [self.HTTPHeaders removeObjectForKey:field];
    }
}
- (nullable NSString *)valueForHTTPHeaderField:(nullable NSString *)field {
    return self.HTTPHeaders[field];
}
- (void)setMaxConcurrentDownloads:(NSInteger)maxConcurrentDownloads {
    _downLoadQueue.maxConcurrentOperationCount = maxConcurrentDownloads;
}

- (NSUInteger)currentDownloadCount {
    return _downLoadQueue.operationCount;
}

- (NSInteger)maxConcurrentDownloads {
    return _downLoadQueue.maxConcurrentOperationCount;
}
- (void)setOperationClass:(nullable Class)operationClass {
    if (operationClass && [operationClass isSubclassOfClass:[NSOperation class]] && [operationClass conformsToProtocol:@protocol(DownLoadOperationOperationInterface)]) {
        _operationClass = operationClass;
    } else {
        _operationClass = [DownLoadOperation class];
    }
}
- (nullable DownloadToken *)downloadWithUrl:(nullable NSURL *)url andOptions:(DownLoadOptions)options andProcess:(nullable ProgressBlock) process andComplite:(nullable CompletedBlock)complite{
    __weak DownLoadTest *wself = self;
    return [self addProcess:process andComlite:complite andUrl:url andOperation:^DownLoadOperation *{
        __strong __typeof (wself) sself = wself;
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:sself.sessionConfigeration.timeoutIntervalForRequest];
        ////是否使用cookie 保存服务端的状态
        request.HTTPShouldHandleCookies = YES;
        ////是否使用流水线式的下载顺序
        request.HTTPShouldUsePipelining = YES;
        ///设置请求头
        if (sself.httpFilterBlock) {
            request.allHTTPHeaderFields = sself.httpFilterBlock(url,[sself.HTTPHeaders mutableCopy]);
        }else{
            request.allHTTPHeaderFields = sself.HTTPHeaders;
        }
        DownLoadOperation *operation = [[DownLoadOperation alloc] initWithRequest:request inSession:nil options:DownLoadOptionsNone];
        ///配置每个operation 的下载证书
        if (sself.urlCredential) {
            operation.credential = sself.urlCredential;
        }else{
            if (sself.userName && sself.passWord) {
                operation.credential = [[NSURLCredential alloc] initWithUser:sself.userName password:sself.passWord persistence:NSURLCredentialPersistenceForSession];
            }
        }
        //// 设置 operatio 在队列里面的执行优先级
        if (sself.options == DownLoadOptionsNone) {
            operation.queuePriority = NSOperationQueuePriorityVeryLow;
        }else{
            operation.queuePriority = NSOperationQueuePriorityHigh;
        }
        ////operation 添加到队列之后   operation 的start 方法立即执行
        [sself.downLoadQueue addOperation:operation];
        
        ////添加操作的依赖
        if (sself.loadOrder == DownLoadOrderFIFOExecutionOrder) {
            if (sself.lastAddOperation) {
                [operation addDependency:sself.lastAddOperation];
            }
            sself.lastAddOperation = operation;
        }
        return operation;
    }];
}
- (nullable DownloadToken *)addProcess:(nullable ProgressBlock)process andComlite:(nullable CompletedBlock)complite andUrl:(nullable NSURL *)url andOperation:(DownLoadOperation * (^)())operation{
    if (url == nil) {
        if (complite != nil) {
            complite(nil, nil, nil, NO);
        }
        return nil;
    }
    __block DownloadToken *token = nil;
    dispatch_barrier_sync(self.barrierQueue, ^{
        DownLoadOperation *op = self.URLOperations[url];
        if (!op) {
            op = operation();
            self.URLOperations[url] = op;
            __weak DownLoadOperation *weakOP = op;
            ////任务完成时回调
            op.completionBlock = ^{
                DownLoadOperation *sop = weakOP;
                if (!sop) return ;
                if (self.URLOperations[url] == sop) {
                    [self.URLOperations removeObjectForKey:url];
                }
            };
        }
        
        ////创建要返回的 下载的唯一识别 token
        id cancelToken = [op addHandlersForProgress:process completed:complite];
        token = [DownloadToken new];
        token.url = url;
        token.downloadOperationCancelToken = cancelToken;
    });

    return token;
}
- (void)cancel:(nullable DownloadToken *)token {
    dispatch_barrier_async(self.barrierQueue, ^{
        DownLoadOperation *operation = self.URLOperations[token.url];
        BOOL canceled = [operation cancel:token.downloadOperationCancelToken];
        if (canceled) {
            [self.URLOperations removeObjectForKey:token.url];
        }
    });
}
- (void)setSuspended:(BOOL)suspended {
    (self.downLoadQueue).suspended = suspended;
}

- (void)cancelAllDownloads {
    [self.downLoadQueue cancelAllOperations];
}

- (DownLoadOperation *)operationWithTask:(NSURLSessionTask *)task {
    DownLoadOperation *returnOperation = nil;
    for (DownLoadOperation *operation in self.downLoadQueue.operations) {
        if (operation.dataTask.taskIdentifier == task.taskIdentifier) {
            returnOperation = operation;
            break;
        }
    }
    return returnOperation;
}


#pragma mark NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    
    // Identify the operation that runs this task and pass it the delegate method
    DownLoadOperation *dataOperation = [self operationWithTask:dataTask];
    
    [dataOperation URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    
    // Identify the operation that runs this task and pass it the delegate method
    DownLoadOperation *dataOperation = [self operationWithTask:dataTask];
    
    [dataOperation URLSession:session dataTask:dataTask didReceiveData:data];
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler {
    
    // Identify the operation that runs this task and pass it the delegate method
    DownLoadOperation *dataOperation = [self operationWithTask:dataTask];
    
    [dataOperation URLSession:session dataTask:dataTask willCacheResponse:proposedResponse completionHandler:completionHandler];
}

#pragma mark NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    // Identify the operation that runs this task and pass it the delegate method
    DownLoadOperation *dataOperation = [self operationWithTask:task];
    
    [dataOperation URLSession:session task:task didCompleteWithError:error];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    
    completionHandler(request);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    
    // Identify the operation that runs this task and pass it the delegate method
    DownLoadOperation *dataOperation = [self operationWithTask:task];
    
    [dataOperation URLSession:session task:task didReceiveChallenge:challenge completionHandler:completionHandler];
}


@end



