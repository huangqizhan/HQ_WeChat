//
//  WebImageOperation.m
//  YYStudyDemo
//
//  Created by hqz on 2018/7/10.
//  Copyright © 2018年 hqz. All rights reserved.
//

#import "WebImageOperation.h"
#import "UIImage+YYWebImage.h"
#import <ImageIO/ImageIO.h>
#import <libkern/OSAtomic.h>
#import "MyImage.h"


#define MIN_PROGRESSIVE_TIME_INTERVAL 0.2
#define MIN_PROGRESSIVE_BLUR_TIME_INTERVAL 0.4


/// Returns nil in App Extension.
static UIApplication *_YYSharedApplication() {
    static BOOL isAppExtension = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = NSClassFromString(@"UIApplication");
        if(!cls || ![cls respondsToSelector:@selector(sharedApplication)]) isAppExtension = YES;
        if ([[[NSBundle mainBundle] bundlePath] hasSuffix:@".appex"]) isAppExtension = YES;
    });
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    return isAppExtension ? nil : [UIApplication performSelector:@selector(sharedApplication)];
#pragma clang diagnostic pop
}
/// Returns YES if the right-bottom pixel is filled.
static BOOL YYCGImageLastPixelFilled(CGImageRef image) {
    if (!image) return NO;
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    if (width == 0 || height == 0) return NO;
    CGContextRef ctx = CGBitmapContextCreate(NULL, 1, 1, 8, 0, YYCGColorSpaceGetDeviceRGB(), kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrderDefault);
    if (!ctx) return NO;
    CGContextDrawImage(ctx, CGRectMake( -(int)width + 1, 0, width, height), image);
    uint8_t *bytes = CGBitmapContextGetData(ctx);
    BOOL isAlpha = bytes && bytes[0] == 0;
    CFRelease(ctx);
    return !isAlpha;
}
/// Returns JPEG SOS (Start Of Scan) Marker
static NSData *JPEGSOSMarker() {
    // "Start Of Scan" Marker
    static NSData *marker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        uint8_t bytes[2] = {0xFF, 0xDA};
        marker = [NSData dataWithBytes:bytes length:2];
    });
    return marker;
}
///黑名单
static NSMutableSet *URLBlacklist;
static dispatch_semaphore_t URLBlacklistLock;

///黑名单初始化
static void URLBlacklistInit() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        URLBlacklist = [NSMutableSet new];
        URLBlacklistLock = dispatch_semaphore_create(1);
    });
}
///是否在黑名单中
static BOOL URLBlackListContains(NSURL *url) {
    if (!url || url == (id)[NSNull null]) return NO;
    URLBlacklistInit();
    dispatch_semaphore_wait(URLBlacklistLock, DISPATCH_TIME_FOREVER);
    BOOL contains = [URLBlacklist containsObject:url];
    dispatch_semaphore_signal(URLBlacklistLock);
    return contains;
}
///添加到黑名单
static void URLInBlackListAdd(NSURL *url) {
    if (!url || url == (id)[NSNull null]) return;
    URLBlacklistInit();
    dispatch_semaphore_wait(URLBlacklistLock, DISPATCH_TIME_FOREVER);
    [URLBlacklist addObject:url];
    dispatch_semaphore_signal(URLBlacklistLock);
}

////urlconnection 跟operation的弱引用
@interface WebImageWeakProxy : NSProxy
@property (nonatomic, weak, readonly) id target;
- (instancetype)initWithTarget:(id)target;
+ (instancetype)proxyWithTarget:(id)target;
@end

@implementation WebImageWeakProxy
- (instancetype)initWithTarget:(id)target {
    _target = target;
    return self;
}
+ (instancetype)proxyWithTarget:(id)target {
    return [[WebImageWeakProxy alloc] initWithTarget:target];
}
- (id)forwardingTargetForSelector:(SEL)selector {
    return _target;
}
- (void)forwardInvocation:(NSInvocation *)invocation {
    void *null = NULL;
    [invocation setReturnValue:&null];
}
- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}
- (BOOL)respondsToSelector:(SEL)aSelector {
    return [_target respondsToSelector:aSelector];
}
- (BOOL)isEqual:(id)object {
    return [_target isEqual:object];
}
- (NSUInteger)hash {
    return [_target hash];
}
- (Class)superclass {
    return [_target superclass];
}
- (Class)class {
    return [_target class];
}
- (BOOL)isKindOfClass:(Class)aClass {
    return [_target isKindOfClass:aClass];
}
- (BOOL)isMemberOfClass:(Class)aClass {
    return [_target isMemberOfClass:aClass];
}
- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    return [_target conformsToProtocol:aProtocol];
}
- (BOOL)isProxy {
    return YES;
}
- (NSString *)description {
    return [_target description];
}
- (NSString *)debugDescription {
    return [_target debugDescription];
}
@end

@interface WebImageOperation ()<NSURLConnectionDelegate,NSURLConnectionDataDelegate>
@property (nonatomic, readwrite, getter=isExecuting) BOOL executing;
@property (readwrite, getter=isFinished) BOOL finished;
@property (nonatomic, readwrite, getter=isCancelled) BOOL cancelled;
@property (readwrite, getter=isStarted) BOOL started;
@property (nonatomic, strong) NSRecursiveLock *lock;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, assign) NSInteger expectedSize;
@property (nonatomic, assign) UIBackgroundTaskIdentifier taskID;

@property (nonatomic, assign) NSTimeInterval lastProgressiveDecodeTimestamp;
@property (nonatomic, strong) ImageDeCode *progressiveDecoder;
@property (nonatomic, assign) BOOL progressiveIgnored;
@property (nonatomic, assign) BOOL progressiveDetected;
@property (nonatomic, assign) NSUInteger progressiveScanedLength;
@property (nonatomic, assign) NSUInteger progressiveDisplayCount;
@property (nonatomic, copy) YYWebImageProgressBlock progress;
@property (nonatomic, copy) YYWebImageTransformBlock transform;
@property (nonatomic, copy) YYWebImageCompletionBlock completion;
@end

@implementation WebImageOperation

@synthesize executing = _executing;
@synthesize finished = _finished;
@synthesize cancelled = _cancelled;

///设置常住线程 属性 : name  开启当前线程的runloop 
+ (void)_networkThreadMain:(id)object {
    @autoreleasepool {
        [[NSThread currentThread] setName:@"com.ibireme.webimage.request"];
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runLoop run];
    }
}
/// 此线程是常住线程 用于处理 urlconnection delegate
+ (NSThread *)_networkThread {
    static NSThread *thread = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        thread = [[NSThread alloc] initWithTarget:self selector:@selector(_networkThreadMain:) object:nil];
        if ([thread respondsToSelector:@selector(setQualityOfService:)]) {
            thread.qualityOfService = NSQualityOfServiceBackground;
        }
        [thread start];
    });
    return thread;
}
////队列池 该队列用于 decoding/reading image
+ (dispatch_queue_t)_imageQueue {
#define MAX_QUEUE_COUNT 16
    static int queueCount;
    static dispatch_queue_t queues[MAX_QUEUE_COUNT];
    static dispatch_once_t onceToken;
    static int32_t counter = 0;
    dispatch_once(&onceToken, ^{
        queueCount = (int)[NSProcessInfo processInfo].activeProcessorCount;
        queueCount = queueCount < 1 ? 1 : queueCount > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : queueCount;
        if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
            for (NSUInteger i = 0; i < queueCount; i++) {
                dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_UTILITY, 0);
                queues[i] = dispatch_queue_create("com.ibireme.image.decode", attr);
            }
        } else {
            for (NSUInteger i = 0; i < queueCount; i++) {
                queues[i] = dispatch_queue_create("com.ibireme.image.decode", DISPATCH_QUEUE_SERIAL);
                dispatch_set_target_queue(queues[i], dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0));
            }
        }
    });
    int32_t cur = OSAtomicIncrement32(&counter);
    if (cur < 0) cur = -cur;
    return queues[(cur) % queueCount];
#undef MAX_QUEUE_COUNT
}
#pragma mark ------ override NSObject aciton
- (instancetype)init {
    @throw [NSException exceptionWithName:@"YYWebImageOperation init error" reason:@"YYWebImageOperation must be initialized with a request. Use the designated initializer to init." userInfo:nil];
    return [self initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@""]] options:0 cache:nil cacheKey:nil progress:nil transform:nil completion:nil];
}
- (instancetype)initWithRequest:(NSURLRequest *)request
                        options:(YYWebImageOptions)options
                          cache:(WebImageCache *)cache
                       cacheKey:(NSString *)cacheKey
                       progress:(YYWebImageProgressBlock)progress
                      transform:(YYWebImageTransformBlock)transform
                     completion:(YYWebImageCompletionBlock)completion{
    self = [super init];
    if (!self) return nil;
    _request = request;
    _options = options;
    _cache = cache;
    _cacheKey = cacheKey ? cacheKey : _request.URL.absoluteString;
    _shouldUseCredentialStorage = YES;
    _progress = progress;
    _completion = completion;
    _transform = transform;
    _executing = NO;
    _finished = NO;
    _cancelled = NO;
    _taskID = UIBackgroundTaskInvalid;
    _lock = [[NSRecursiveLock alloc] init];
    return self;
}
- (void)dealloc{
    [_lock lock];
    if (_taskID != UIBackgroundTaskInvalid) {
        [_YYSharedApplication() endBackgroundTask:_taskID];
        _taskID = UIBackgroundTaskInvalid;
    }
    if ([self isExecuting]) {
        self.finished = YES;
        self.executing = NO;
        self.cancelled = YES;
        if (!_request.URL.isFileURL && (_options & YYWebImageOptionShowNetworkActivity)) {
            [WebImageManager decrementNetworkActivityCount];
        }
        [_connection cancel];
        _connection = nil;
        if (_completion) {
            _completion(nil,_request.URL,YYWebImageFromNone,YYWebImageStageCancelled,nil);
        }
    }
    [_lock unlock];
}
- (void)_endBackgroundTask {
    [_lock lock];
    if (_taskID != UIBackgroundTaskInvalid) {
        //        NSLog(@"currentThread = %@",[NSThread currentThread]);
        [_YYSharedApplication() endBackgroundTask:_taskID];
        _taskID = UIBackgroundTaskInvalid;
    }
    [_lock unlock];
}

#pragma mark ------ operation Actions --------
- (void)_finish{
    self.finished = YES;
    self.executing = NO;
    [self _endBackgroundTask];
}
- (void)_startOperation{
    if ([self isCancelled]) return;
    @autoreleasepool{
        ///检查是否有本地数据
        if (_cache && !(_options & YYWebImageOptionUseNSURLCache) && !(_options & YYWebImageOptionRefreshImageCache)) {
            UIImage *image = [_cache getImageForKey:_cacheKey withType:YYImageCacheTypeMemory];
            if (image && _completion){
                 [_lock lock];
               ///如果是在内存中缓存  不用decode 直接返回
                _completion(image,_request.URL,YYWebImageFromMemoryCache,YYWebImageStageFinished,nil);
                [self _finish];
                [_lock unlock];
                return;
            }
            if (!(_options & YYWebImageOptionIgnoreDiskCache)) {
                __weak typeof(self) _self = self;
                dispatch_queue_t q = [self.class _imageQueue];
                dispatch_async(q, ^{
                    __strong typeof(_self) self = _self;
                    if (!self || [self isCancelled]){
                      return ;
                    }
                    UIImage *image = [self->_cache getImageForKey:self->_cacheKey withType:YYImageCacheTypeDisk];
                    if (image) {
                        //存入内存缓存
                        [self->_cache setImage:image imageData:nil forKey:self->_cacheKey withType:YYImageCacheTypeMemory];
                        [self performSelector:@selector(_didReceiveImageFomeDiskCache:) onThread:[self.class _networkThread] withObject:image waitUntilDone:NO];
                    }else{
                        ///没找到图片
                        [self performSelector:@selector(_startRequest:) onThread:[self.class _networkThread] withObject:nil waitUntilDone:NO];
                    }
                });
                return;
            }
        }
        [self performSelector:@selector(_startRequest:) onThread:[self.class _networkThread] withObject:nil waitUntilDone:NO];
    }
}
///开始请求
- (void)_startRequest:(id)object{
    if ([self isCancelled]) return;
    @autoreleasepool {
        ///地址错误 或已经加入到黑明单
        if ((_options & YYWebImageOptionIgnoreFailedURL) && URLBlackListContains(_request.URL)) {
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:@{ NSLocalizedDescriptionKey : @"Failed to load URL, blacklisted." }];
            [_lock lock];
            if (_completion) _completion(nil,_request.URL,YYWebImageFromNone,YYWebImageStageFinished,error);
            [self _finish];
            [_lock unlock];
            return;
        }
        if (_request.URL.isFileURL) {
            NSArray *keys = @[NSURLFileSizeKey];
            NSDictionary *attr = [_request.URL resourceValuesForKeys:keys error:nil];
            NSNumber *size = attr[NSURLFileSizeKey];
            _expectedSize = (size != nil) ? size.unsignedIntegerValue : -1;
        }
        
        ///start request image from web
        [_lock lock];
        if (![self isCancelled]) {
            _connection = [[NSURLConnection alloc] initWithRequest:_request delegate:[WebImageWeakProxy proxyWithTarget:self]];
            if (!_request.URL.isFileURL && (_options & YYWebImageOptionShowNetworkActivity)) {
                [WebImageManager incrementNetworkActivityCount];
            }
        }
        [_lock unlock];
        
    }
}
- (void)_cancelOperation{
    @autoreleasepool{
        if (_connection) {
            if (!_request.URL.isFileURL && (_options & YYWebImageOptionShowNetworkActivity)) {
                [WebImageManager decrementNetworkActivityCount];
            }
            [_connection cancel];
        }
        _connection = nil;
        if (_completion)_completion(nil,_request.URL,YYWebImageFromNone,YYWebImageStageCancelled,nil);
        [self _endBackgroundTask];
    }
}
///从磁盘获取到图片处理
- (void)_didReceiveImageFomeDiskCache:(UIImage *)image{
    @autoreleasepool {
        [_lock lock];
        if (![self isCancelled]) {
            if (image) {
                if (_completion) _completion(image, _request.URL, YYWebImageFromDiskCache, YYWebImageStageFinished, nil);
                [self _finish];
            } else {
                [self _startRequest:nil];
            }
        }
        [_lock unlock];
    }
}
///从服务器获取到图片处理
- (void)_didReceiveImageFromWeb:(UIImage *)image {
    @autoreleasepool {
        [_lock lock];
        if (![self isCancelled]) {
            if (_cache) {
                if (image || (_options & YYWebImageOptionRefreshImageCache)) {
                    NSData *data = _data;
                    dispatch_async([WebImageOperation _imageQueue], ^{
                        YYImageCacheType cacheType = (self->_options & YYWebImageOptionIgnoreDiskCache) ? YYImageCacheTypeMemory : YYImageCacheTypeAll;
                        [self->_cache setImage:image imageData:data forKey:self->_cacheKey withType:cacheType];
                    });
                }
            }
            _data = nil;
            NSError *error = nil;
            if (!image) {
                error = [NSError errorWithDomain:@"com.ibireme.image" code:-1 userInfo:@{ NSLocalizedDescriptionKey : @"Web image decode fail." }];
                if (_options & YYWebImageOptionIgnoreFailedURL) {
                    if (URLBlackListContains(_request.URL)) {
                        error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:@{ NSLocalizedDescriptionKey : @"Failed to load URL, blacklisted." }];
                    } else {
                        URLInBlackListAdd(_request.URL);
                    }
                }
            }
            if (_completion) _completion(image, _request.URL, YYWebImageFromRemote, YYWebImageStageFinished, error);
            [self _finish];
        }
        [_lock unlock];
    }
}

#pragma mark -------- override NSOperation  --------
- (void)start{
    @autoreleasepool{
        [_lock lock];
        self.started = YES;
        if ([self isCancelled]) {
            ///取消的操作是在 NSRunLoopCommonModes
            [self performSelector:@selector(_cancelOperation) onThread:[self.class _networkThread] withObject:nil waitUntilDone:NO modes:@[NSRunLoopCommonModes]];
            self.finished = YES;
        }else if ([self isReady] && !self.isFinished && !self.isExecuting){
            if (!_request) {
                self.finished = YES;
                if (_completion) {
                    NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:@{NSLocalizedDescriptionKey:@"request in nil"}]; _completion(nil,nil,YYWebImageFromNone,YYWebImageStageCancelled,error);
                }
            }else{
                self.executing = YES;
                [self performSelector:@selector(_startOperation) onThread:[self.class _networkThread] withObject:nil waitUntilDone:NO modes:@[NSDefaultRunLoopMode]];
                if ((_options & YYWebImageOptionAllowBackgroundTask && _YYSharedApplication())) {
                    __weak typeof(self) _self = self;
                    if (_taskID == UIBackgroundTaskInvalid) {
                        [_YYSharedApplication() beginBackgroundTaskWithExpirationHandler:^{
                            __strong typeof(_self) self = _self;
                            if (self) {
                                [self cancel];
                                self.finished = YES;
                            }
                        }];
                    }
                }
            }
        }
        [_lock unlock];
    }
}
- (void)cancel{
    [_lock lock];
    if (![self isCancelled]) {
        [super cancel];
        self.cancelled = YES;
        if ([self isExecuting]) {
            self.executing = NO;
            [self performSelector:@selector(_cancelOperation) onThread:[self.class _networkThread] withObject:nil waitUntilDone:NO modes:@[NSDefaultRunLoopMode]];
        }
        if (self.isStarted) {
            self.finished = YES;
        }
    }
    [_lock unlock];
}
- (void)setExecuting:(BOOL)executing{
    [_lock lock];
    if (executing != _executing) {
        [self willChangeValueForKey:@"isExecuting"];
        _executing = executing;
        [self didChangeValueForKey:@"isExecuting"];
    }
    [_lock unlock];
}
- (BOOL)isExecuting{
    [_lock lock];
    BOOL executing = _executing;
    [_lock unlock];
    return executing;
}
- (BOOL)isFinished{
    [_lock lock];
    BOOL finish = _finished;
    [_lock unlock];
    return finish;
}
- (void)setFinished:(BOOL)finished{
    [_lock lock];
    if (_finished != finished) {
        [self willChangeValueForKey:@"isFinished"];
        _finished = finished;
        [self didChangeValueForKey:@"isFinished"];
    }
    [_lock unlock];
}
- (void)setCancelled:(BOOL)cancelled{
    [_lock lock];
    if (_cancelled != cancelled) {
        [self willChangeValueForKey:@"isCancelled"];
        _cancelled = cancelled;
        [self willChangeValueForKey:@"isCancelled"];
    }
    [_lock unlock];
}
- (BOOL)isCancelled{
    [_lock lock];
    BOOL canceled = _cancelled;
    [_lock unlock];
    return canceled;
}
- (BOOL)isConnection{
    return YES;
}
- (BOOL)isAsynchronous{
    return YES;
}
#pragma mark ------ NSUrlConnectionDelegate--------
- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection{
    return _shouldUseCredentialStorage;
}
////当使用https 时会调用此方法
- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    @autoreleasepool {
        ///服务端已经信任客户端
        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            if (!(_options & YYWebImageOptionAllowInvalidSSLCertificates) &&
                [challenge.sender respondsToSelector:@selector(performDefaultHandlingForAuthenticationChallenge:)]) {
                [challenge.sender performDefaultHandlingForAuthenticationChallenge:challenge];
            } else {
                ///为 challenge 的发送方提供 credential
                NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
                [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
            }
        } else {
            ///没有失败过
            if ([challenge previousFailureCount] == 0) {
                if (_credential) {
                    ///重新发送
                    [[challenge sender] useCredential:_credential forAuthenticationChallenge:challenge];
                } else {
                    ///continue
                    [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
                }
            } else {
                ///continue
                [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
            }
        }
    }
}
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse{
    if (!cachedResponse) return cachedResponse;
    if (_options & YYWebImageOptionUseNSURLCache) {
        return cachedResponse;
    } else {
        // ignore NSURLCache
        return nil;
    }
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    @autoreleasepool{
        NSError *error = nil;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (id) response;
            NSInteger statusCode = httpResponse.statusCode;
            if (statusCode >= 400  || statusCode == 304) {
                error = [NSError errorWithDomain:NSURLErrorDomain code:statusCode userInfo:nil];
            }
            if (error) {
                [connection cancel];
                [self connection:_connection didFailWithError:error];
            }else{
                if (response.expectedContentLength) {
                    _expectedSize = (NSInteger)response.expectedContentLength;
                    if (_expectedSize < 0) {
                        _expectedSize = -1;
                    }
                }
                _data = [NSMutableData dataWithCapacity:_expectedSize > 0 ? _expectedSize : 0];
                if (_progress) {
                    [_lock lock];
                    if (![self isCancelled]) {
                        _progress(0,_expectedSize);
                    }
                    [_lock unlock];
                }
            }
        }
    }
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    @autoreleasepool{
        [_lock lock];
        BOOL canceled = [self isCancelled];
        [_lock unlock];
        if (canceled) return;
        [_lock lock];
        if (data) [_data appendData:data];
        if (_progress) {
            if (![self isCancelled]) {
                _progress(_data.length , _expectedSize);
            }
        }
        [_lock unlock];
            /*****   processive    ******/
        BOOL processive = (_options * YYWebImageOptionProgressive);
        BOOL processiveBlur = (_options & YYWebImageOptionProgressiveBlur);
        if (!_completion || !processive || !processiveBlur)
            return;
        if(data.length <= 16) return;
        if (_expectedSize > 0 && data.length >= _expectedSize * 0.99) return;
        if (_progressiveIgnored) return;
        NSTimeInterval min = processiveBlur ? MIN_PROGRESSIVE_BLUR_TIME_INTERVAL : MIN_PROGRESSIVE_TIME_INTERVAL;
        NSTimeInterval now = CACurrentMediaTime();
        if (now - _lastProgressiveDecodeTimestamp < min) return;
        
        if (!_progressiveDecoder) {
            _progressiveDecoder = [[ImageDeCode alloc] initWithScale:[UIScreen mainScreen].scale];
        }
        [_progressiveDecoder updateData:_data final:NO];
        if ([self isCancelled]) return;
        if (_progressiveDecoder.type == YYImageTypeUnknown ||
            _progressiveDecoder.type == YYImageTypeWebP ||
            _progressiveDecoder.type == YYImageTypeOther) {
            _progressiveDecoder = nil;
            _progressiveIgnored = YES;
            return;
        }
        if (processiveBlur) { // only support progressive JPEG and interlaced PNG
            if (_progressiveDecoder.type != YYImageTypeJPEG &&
                _progressiveDecoder.type != YYImageTypePNG) {
                _progressiveDecoder = nil;
                _progressiveIgnored = YES;
                return;
            }
        }
        if (_progressiveDecoder.frameCount == 0) return;
        if (!processiveBlur) {
            YYImageFrame *frame = [_progressiveDecoder frameAtIndex:0 decodeForDisplay:YES];
            if (frame.image) {
                [_lock lock];
                if (![self isCancelled]) {
                    _completion(frame.image, _request.URL, YYWebImageFromRemote, YYWebImageStageProgress, nil);
                    _lastProgressiveDecodeTimestamp = now;
                }
                [_lock unlock];
            }
            return;
        }else{
            if (_progressiveDecoder.type == YYImageTypeJPEG){
                if (!_progressiveDetected) {
                    NSDictionary *dic = [_progressiveDecoder framePropertiesAtIndex:0];
                    NSDictionary *jpeg = dic[(id)kCGImagePropertyJFIFDictionary];
                    NSNumber *isProg = jpeg[(id)kCGImagePropertyJFIFIsProgressive];
                    if (!isProg.boolValue) {
                        _progressiveIgnored = YES;
                        _progressiveDecoder = nil;
                        return;
                    }
                    _progressiveDetected = YES;
                }
                NSInteger scanLength = (NSInteger)_data.length - (NSInteger)_progressiveScanedLength - 4;
                if (scanLength <= 2) return;
                NSRange scanRange = NSMakeRange(_progressiveScanedLength, scanLength);
                NSRange markerRange = [_data rangeOfData:JPEGSOSMarker() options:kNilOptions range:scanRange];
                _progressiveScanedLength = _data.length;
                if (markerRange.location == NSNotFound) return;
                if ([self isCancelled]) return;
            }else if (_progressiveDecoder.type == YYImageTypePNG){
                if (!_progressiveDetected) {
                    NSDictionary *dic = [_progressiveDecoder framePropertiesAtIndex:0];
                    NSDictionary *png = dic[(id)kCGImagePropertyPNGDictionary];
                    NSNumber *isProg = png[(id)kCGImagePropertyPNGInterlaceType];
                    if (!isProg.boolValue) {
                        _progressiveIgnored = YES;
                        _progressiveDecoder = nil;
                        return;
                    }
                    _progressiveDetected = YES;
                }
            }
            
            YYImageFrame *frame = [_progressiveDecoder frameAtIndex:0 decodeForDisplay:YES];
            UIImage *image = frame.image;
            if (!image) return;
            if ([self isCancelled]) return;
            
            if (!YYCGImageLastPixelFilled(image.CGImage)) return;
            _progressiveDisplayCount++;
            
            CGFloat radius = 32;
            if (_expectedSize > 0) {
                radius *= 1.0 / (3 * _data.length / (CGFloat)_expectedSize + 0.6) - 0.25;
            } else {
                radius /= (_progressiveDisplayCount);
            }
            image = [image yy_imageByBlurRadius:radius tintColor:nil tintMode:0 saturation:1 maskImage:nil];
            
            if (image) {
                [_lock lock];
                if (![self isCancelled]) {
                    _completion(image, _request.URL, YYWebImageFromRemote, YYWebImageStageProgress, nil);
                    _lastProgressiveDecodeTimestamp = now;
                }
                [_lock unlock];
            }
        }
    }
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    @autoreleasepool{
        [_lock lock];
        _connection = nil;
        if (![self isCancelled]) {
            __weak typeof(self) _self = self;
            dispatch_async([self.class _imageQueue], ^{
                __strong typeof(_self) self = _self;
                if (!self) return ;
                BOOL shouldDecode = (self.options & YYWebImageOptionIgnoreImageDecoding);
                BOOL allowAnimation = (self.options & YYWebImageOptionIgnoreAnimatedImage);
                BOOL hasAnimation = NO;
                UIImage *image = nil;
                if (allowAnimation) {
                    image = [[MyImage alloc] initWithData:self.data scale:[UIScreen mainScreen].scale];
                    if (shouldDecode) {
                        image = [image imageByDecoded];
                    }
                    if ([(MyImage *)image animatedImageFrameCount] > 1) {
                        hasAnimation = YES;
                    }
                }else{
                    ImageDeCode *decode = [ImageDeCode decoderWithData:self.data scale:[UIScreen mainScreen].scale];
                    image = [decode frameAtIndex:0 decodeForDisplay:shouldDecode].image;
                }
                /*
                 If the image has animation, save the original image data to disk cache.
                 If the image is not PNG or JPEG, re-encode the image to PNG or JPEG for
                 better decoding performance.
                 */
                
#pragma mark ------ customerAction   ----------
                YYImageType imageType = ImageTypeDetectType((__bridge CFDataRef)self.data);
                switch (imageType) {
                    case YYImageTypeJPEG:
                    case YYImageTypeGIF:
                    case YYImageTypePNG:
                    case YYImageTypeWebP: { // save to disk cache
                        if (!hasAnimation) {
                            if (imageType == YYImageTypeGIF ||
                                imageType == YYImageTypeWebP) {
                                self.data = nil; // clear the data, re-encode for disk cache
                            }
                        }
                    } break;
                    default: {
                        self.data = nil; // clear the data, re-encode for disk cache
                    } break;
                }
                
                if ([self isCancelled]) return;
                
                if (self.transform && image) {
                    UIImage *newImage = self.transform(image, self.request.URL);
                    if (newImage != image) {
                        self.data = nil;
                    }
                    image = newImage;
                    if ([self isCancelled]) return;
                }
                [self performSelector:@selector(_didReceiveImageFromWeb:) onThread:[self.class _networkThread] withObject:image waitUntilDone:NO];
            });
            if (![self.request.URL isFileURL] && (self.options & YYWebImageOptionShowNetworkActivity)) {
                [WebImageManager decrementNetworkActivityCount];
            }
        }
        [_lock unlock];
    }
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    @autoreleasepool {
        [_lock lock];
        if (![self isCancelled]) {
            if (_completion) {
                _completion(nil, _request.URL, YYWebImageFromNone, YYWebImageStageFinished, error);
            }
            _connection = nil;
            _data = nil;
            if (![_request.URL isFileURL] && (_options & YYWebImageOptionShowNetworkActivity)) {
                [WebImageManager decrementNetworkActivityCount];
            }
            [self _finish];
            
            if (_options & YYWebImageOptionIgnoreFailedURL) {
                if (error.code != NSURLErrorNotConnectedToInternet &&
                    error.code != NSURLErrorCancelled &&
                    error.code != NSURLErrorTimedOut &&
                    error.code != NSURLErrorUserCancelledAuthentication &&
                    error.code != NSURLErrorNetworkConnectionLost) {
                    URLInBlackListAdd(_request.URL);
                }
            }
        }
        [_lock unlock];
    }
}
#pragma override NSObject
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key{
    if ([key isEqualToString:@"isFinished"] || [key isEqualToString:@"isExecuting"]|| [key isEqualToString:@"isCancelled"]) {
        return NO;
    }
    return [super automaticallyNotifiesObserversForKey:key];
}
- (NSString *)description {
    NSMutableString *string = [NSMutableString stringWithFormat:@"<%@: %p ",self.class, self];
    [string appendFormat:@" executing:%@", [self isExecuting] ? @"YES" : @"NO"];
    [string appendFormat:@" finished:%@", [self isFinished] ? @"YES" : @"NO"];
    [string appendFormat:@" cancelled:%@", [self isCancelled] ? @"YES" : @"NO"];
    [string appendString:@">"];
    return string;
}

@end