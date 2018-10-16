//
//  WebImageManager.m
//  YYStudyDemo
//
//  Created by 黄麒展 on 2018/7/8.
//  Copyright © 2018年 hqz. All rights reserved.
//

#import "WebImageManager.h"
#import "ImageDeCode.h"
#import <objc/runtime.h>
#import "WebImageOperation.h"

#define kNetworkIndicatorDelay (1/30.0)


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

@interface _YYWebImageApplicationNetworkIndicatorInfo : NSObject
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) NSTimer *timer;
@end
@implementation _YYWebImageApplicationNetworkIndicatorInfo
@end

@implementation WebImageManager
+ (instancetype)sharedManager {
    static WebImageManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        WebImageCache *cache = [WebImageCache sharedCache];
        NSOperationQueue *queue = [NSOperationQueue new];
        if ([queue respondsToSelector:@selector(setQualityOfService:)]) {
            queue.qualityOfService = NSQualityOfServiceBackground;
        }
        manager = [[self alloc] initWithCache:cache queue:queue];
    });
    return manager;
}
- (instancetype)init {
    @throw [NSException exceptionWithName:@"YYWebImageManager init error" reason:@"Use the designated initializer to init." userInfo:nil];
    return [self initWithCache:nil queue:nil];
}
- (instancetype)initWithCache:(WebImageCache *)cache queue:(NSOperationQueue *)queue{
    self = [super init];
    if (!self) return nil;
    _cache = cache;
    _queue = queue;
    _timeout = 15.0;
    if (YYImageWebPAvailable()) {
        _headers = @{ @"Accept" : @"image/webp,image/*;q=0.8" };
    } else {
        _headers = @{ @"Accept" : @"image/*;q=0.8" };
    }
    return self;
}
///开始请求
- (WebImageOperation *)requestImageWithURL:(NSURL *)url
                                            options:(YYWebImageOptions)options
                                           progress:(nullable YYWebImageProgressBlock)progress
                                          transform:(nullable YYWebImageTransformBlock)transform
                                         completion:(nullable YYWebImageCompletionBlock)completion{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    ///是否使用cookies
    request.HTTPShouldHandleCookies = (options & YYWebImageOptionHandleCookies);
    ///超时
    request.timeoutInterval = _timeout;
    ///请求头
    request.allHTTPHeaderFields = [self headersForURL:url];
    ////是否并行请求
    request.HTTPShouldUsePipelining = YES;
    ///缓存策略
    request.cachePolicy = (options & YYWebImageOptionUseNSURLCache) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData;
    WebImageOperation *operation = [[WebImageOperation alloc] initWithRequest:request options:options cache:_cache cacheKey:[self cacheKeyForURL:url] progress:progress transform:transform?transform:_sharedTransformBlock completion:completion];
    if (_username && _password) {
        operation.credential = [[NSURLCredential alloc] initWithUser:_username password:_password persistence:NSURLCredentialPersistenceForSession];
    }
    if (operation) {
        NSOperationQueue *queue = _queue;
        if (queue) {
            [queue addOperation:operation];
        }else{
            [operation start];
        }
    }
    return operation;
}
///每一条请求对应的请求头 如果没有 就会使用默认
- (NSDictionary *)headersForURL:(NSURL *)url {
    if (!url) return nil;
    return _headersFilter ? _headersFilter(url, _headers) : _headers;
}
///每张图片缓存key 如果没有就以url.absoluteString 为key 
- (NSString *)cacheKeyForURL:(NSURL *)url {
    if (!url) return nil;
    return _cacheKeyFilter ? _cacheKeyFilter(url) : url.absoluteString;
}
////给当前类添加 networkIndicatorInfo 类属性
+ (_YYWebImageApplicationNetworkIndicatorInfo *)_networkIndicatorInfo {
    return objc_getAssociatedObject(self, @selector(_networkIndicatorInfo));
}
+ (void)_setNetworkIndicatorInfo:(_YYWebImageApplicationNetworkIndicatorInfo *)info{
    objc_setAssociatedObject(self, @selector(_networkIndicatorInfo), info, OBJC_ASSOCIATION_RETAIN);
}


+ (void)_delaySetActivity:(NSTimer *)timer {
    UIApplication *app = _YYSharedApplication();
    if (!app) return;
    
    NSNumber *visiable = timer.userInfo;
    if (app.networkActivityIndicatorVisible != visiable.boolValue) {
        [app setNetworkActivityIndicatorVisible:visiable.boolValue];
    }
    [timer invalidate];
}
+ (void)_changeNetworkActivityCount:(NSInteger)delta {
    if (!_YYSharedApplication()) return;
    
    void (^block)(void) = ^{
        _YYWebImageApplicationNetworkIndicatorInfo *info = [self _networkIndicatorInfo];
        if (!info) {
            info = [_YYWebImageApplicationNetworkIndicatorInfo new];
            [self _setNetworkIndicatorInfo:info];
        }
        NSInteger count = info.count;
        count += delta;
        info.count = count;
        [info.timer invalidate];
        ///创建timer 而且添加到runloop 的 commonModes 来防止timer的action 不会被调用
        info.timer = [NSTimer timerWithTimeInterval:kNetworkIndicatorDelay target:self selector:@selector(_delaySetActivity:) userInfo:@(info.count > 0) repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:info.timer forMode:NSRunLoopCommonModes];
    };
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}
+ (void)incrementNetworkActivityCount {
    [self _changeNetworkActivityCount:1];
}

+ (void)decrementNetworkActivityCount {
    [self _changeNetworkActivityCount:-1];
}

+ (NSInteger)currentNetworkActivityCount {
    _YYWebImageApplicationNetworkIndicatorInfo *info = [self _networkIndicatorInfo];
    return info.count;
}

@end
