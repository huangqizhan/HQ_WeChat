//
//  DownLoadOperation.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/5/17.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "DownLoadOperation.h"

NSString * const DownLoadStartNotification = @"DownLoadStartNotification";
NSString * const DownLoadReceiveResponseDataNotification = @"DownLoadReceiveDataNotification";
NSString * const DownLoadStopNotification = @"DownLoadStopNotification";
NSString * const DownLoadFinisnNotification = @"DownLoadFinisnNotification";


static NSString *const ProgressCallbackKey = @"progress";
static NSString *const CompletedCallbackKey = @"completed";

typedef NSMutableDictionary<NSString *, id> CallbacksDictionary;


@interface DownLoadOperation ()

@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;
@property (strong, nonatomic, nullable) NSMutableData *imageData;

@property (strong, nonatomic, nonnull) NSMutableArray<CallbacksDictionary *> *callbackBlocks;


@property (weak, nonatomic, nullable) NSURLSession *unownedSession;

@property (strong, nonatomic, nullable) NSURLSession *ownedSession;

@property (strong, nonatomic, readwrite, nullable) NSURLSessionTask *dataTask;


@property (strong, nonatomic, nullable) dispatch_queue_t barrierQueue;

@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundTaskId;

@end


@implementation DownLoadOperation{
    
    size_t width, height;
    UIImageOrientation orientation;
    BOOL responseFromCached;

}

@synthesize executing = _executing;
@synthesize finished = _finished;

- (nonnull instancetype)init{
    return  [self initWithRequest:nil inSession:nil options:0];
}
- (nonnull instancetype)initWithRequest:(nullable NSURLRequest *)request
                              inSession:(nullable NSURLSession *)session
                                options:(DownLoadOptions)options{
    if ((self = [super init])) {
        _request = [request copy];
        _shouldDecompressImages = YES;
        _options = options;
        _callbackBlocks = [NSMutableArray new];
        _executing = NO;
        _finished = NO;
        _expectedSize = 0;
        _unownedSession = session;
        responseFromCached = YES; // Initially wrong until `- URLSession:dataTask:willCacheResponse:completionHandler: is called or not called
        _barrierQueue = dispatch_queue_create("com.hackemist.SDWebImageDownloaderOperationBarrierQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}
////进入后台是否下载
- (BOOL)shouldContinueWhenAppEntersBackground {
    return YES;
}
- (void)callCompletionBlocksWithError:(nullable NSError *)error {
    [self callCompletionBlocksWithImage:nil imageData:nil error:error finished:YES];
}

- (void)callCompletionBlocksWithImage:(nullable UIImage *)image
                            imageData:(nullable NSData *)imageData
                                error:(nullable NSError *)error
                             finished:(BOOL)finished {
    NSArray<id> *completionBlocks = [self callbacksForKey:CompletedCallbackKey];
//    dispatch_main_async_safe(^{
//        for (SDWebImageDownloaderCompletedBlock completedBlock in completionBlocks) {
//            completedBlock(image, imageData, error, finished);
//        }
//    });
}

- (nullable id)addHandlersForProgress:(nullable ProgressBlock)progressBlock
                            completed:(nullable CompletedBlock)completedBlock{
    CallbacksDictionary *callDic = [CallbacksDictionary new];
    if (progressBlock) callDic[ProgressCallbackKey] = [progressBlock copy];
    if (completedBlock) callDic[CompletedCallbackKey] = [completedBlock copy];
    dispatch_barrier_async(self.barrierQueue, ^{
        [self.callbackBlocks addObject:callDic];
    });
    return callDic;
}
- (BOOL)cancel:(id)token{
    __block BOOL shouldCancel = NO;
    dispatch_barrier_sync(self.barrierQueue, ^{
        [self.callbackBlocks removeObjectIdenticalTo:token];
        if (self.callbackBlocks.count == 0) {
            shouldCancel = YES;
        }
    });
    if (shouldCancel) {
        [self cancel];
    }
    return shouldCancel;
}
- (nullable NSArray<id> *)callbacksForKey:(NSString *)key {
    __block NSMutableArray<id> *callbacks = nil;
    dispatch_sync(self.barrierQueue, ^{
        ////callbackBlocks 里面 都是字典  字典里面都有两个元素   key分别是  process complte
        ////获取某一个key所对应的所有的值  返回一个数组
        callbacks = [[self.callbackBlocks valueForKey:key] mutableCopy];
        ////通过地址删除指定的对象  如果数组里面有多个相同的对象 一次性全部删除
        [callbacks removeObjectIdenticalTo:[NSNull null]];
    });
    return callbacks;
}
- (void)start{
    @synchronized (self) {
        if (self.isCancelled) {
            self.finished = YES;
            [self reset];
        }
        Class applicationClass = NSClassFromString(@"UIApplication");
        BOOL hasApplication = applicationClass && [applicationClass respondsToSelector:@selector(sharedApplication)];
        if (hasApplication && [self shouldContinueWhenAppEntersBackground]) {
            __weak __typeof__ (self) wsSelf = self;
            UIApplication *app = [applicationClass performSelector:@selector(sharedApplication)];
            wsSelf.backgroundTaskId = [app beginBackgroundTaskWithExpirationHandler:^{
                __strong __typeof (wsSelf) sself = wsSelf;
                if (sself) {
                    for (int i = 0; i<10000; i++) {
                        NSLog(@"backgorund = %d",i);
                    }
                }
            }];
        }
        
        NSURLSession *session = self.unownedSession;
        if (session == nil) {
            NSURLSessionConfiguration *configer = [NSURLSessionConfiguration defaultSessionConfiguration];
            configer.timeoutIntervalForRequest = 15;
            session  = [NSURLSession sessionWithConfiguration:configer delegate:self delegateQueue:nil];
            self.ownedSession = session;
        }
        self.dataTask = [session dataTaskWithRequest:self.request];
        self.executing = YES;
    }
    [self.dataTask resume];
    
     if (self.dataTask) {
         for (ProgressBlock progressBlock in [self callbacksForKey:ProgressCallbackKey]) {
             progressBlock(0, 0, self.request.URL);
         }
         dispatch_async(dispatch_get_main_queue(), ^{
//             [[NSNotificationCenter defaultCenter] postNotificationName:SDWebImageDownloadStartNotification object:self];
         });
     } else {
         [self callCompletionBlocksWithError:[NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : @"Connection can't be initialized"}]];
     }

    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    if(!UIApplicationClass || ![UIApplicationClass respondsToSelector:@selector(sharedApplication)]) {
        return;
    }
    if (self.backgroundTaskId != UIBackgroundTaskInvalid) {
        UIApplication * app = [UIApplication performSelector:@selector(sharedApplication)];
        [app endBackgroundTask:self.backgroundTaskId];
        self.backgroundTaskId = UIBackgroundTaskInvalid;
    }

}

- (void)cancel{
    @synchronized (self) {
        [self cancelInternal];
    }
}

- (void)cancelInternal{
    if (self.finished) return;
    [super cancel];
    if (self.dataTask) {
        dispatch_async(dispatch_get_main_queue(), ^{
//            [[NSNotificationCenter defaultCenter] postNotificationName:SDWebImageDownloadStopNotification object:self];
        });
        if (self.isExecuting) self.executing = NO;
        if (!self.isFinished) self.finished = YES;
    }
    [self reset];
}

- (void)done {
    self.finished = YES;
    self.executing = NO;
    [self reset];
}
- (void)reset {
    dispatch_barrier_async(self.barrierQueue, ^{
        [self.callbackBlocks removeAllObjects];
    });
    self.dataTask = nil;
    self.imageData = nil;
    if (self.ownedSession) {
        [self.ownedSession invalidateAndCancel];
        self.ownedSession = nil;
    }
}
- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}
- (BOOL)isConcurrent {
    return YES;
}

#pragma mark ------ NSUrlSessionDataDelegate -------
////收到服务器相应处理
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    if (![response respondsToSelector:@selector(statusCode)] || (((NSHTTPURLResponse *)response).statusCode < 400 && ((NSHTTPURLResponse *)response).statusCode != 304)) {
        NSInteger expected = response.expectedContentLength > 0 ? (NSInteger)response.expectedContentLength : 0;
        self.expectedSize = expected;
        /////收到相应回调
        for (ProgressBlock progressBlock in [self callbacksForKey:ProgressCallbackKey]) {
            progressBlock(0, expected, self.request.URL);
        }
        self.imageData = [[NSMutableData alloc] initWithCapacity:expected];
        self.response = response;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:DownLoadReceiveResponseDataNotification object:self];
        });
    }else{///错误处理
        NSUInteger code = ((NSHTTPURLResponse *)response).statusCode;
        if (code == 304) {
            [self cancelInternal];
        } else {
            [self.dataTask cancel];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
//            [[NSNotificationCenter defaultCenter] postNotificationName:SDWebImageDownloadStopNotification object:self];
        });
        [self callCompletionBlocksWithError:[NSError errorWithDomain:NSURLErrorDomain code:((NSHTTPURLResponse *)response).statusCode userInfo:nil]];
        
        [self done];
    }
    if (completionHandler) {
        completionHandler(NSURLSessionResponseAllow);
    }
}
////接收到数据处理
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    [self.imageData appendData:data];
//    if ((self.options & SDWebImageDownloaderProgressiveDownload) && self.expectedSize > 0) {
//        // The following code is from http://www.cocoaintheshell.com/2011/05/progressive-images-download-imageio/
//        // Thanks to the author @Nyx0uf
//
//        // Get the total bytes downloaded
//        const NSInteger totalSize = self.imageData.length;
//
//        // Update the data source, we must pass ALL the data, not just the new bytes
//        CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)self.imageData, NULL);
//
//        if (width + height == 0) {
//            CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
//            if (properties) {
//                NSInteger orientationValue = -1;
//                CFTypeRef val = CFDictionaryGetValue(properties, kCGImagePropertyPixelHeight);
//                if (val) CFNumberGetValue(val, kCFNumberLongType, &height);
//                val = CFDictionaryGetValue(properties, kCGImagePropertyPixelWidth);
//                if (val) CFNumberGetValue(val, kCFNumberLongType, &width);
//                val = CFDictionaryGetValue(properties, kCGImagePropertyOrientation);
//                if (val) CFNumberGetValue(val, kCFNumberNSIntegerType, &orientationValue);
//                CFRelease(properties);
//
//                // When we draw to Core Graphics, we lose orientation information,
//                // which means the image below born of initWithCGIImage will be
//                // oriented incorrectly sometimes. (Unlike the image born of initWithData
//                // in didCompleteWithError.) So save it here and pass it on later.
//#if SD_UIKIT || SD_WATCH
//                orientation = [[self class] orientationFromPropertyValue:(orientationValue == -1 ? 1 : orientationValue)];
//#endif
//            }
//        }
//
//        if (width + height > 0 && totalSize < self.expectedSize) {
//            // Create the image
//            CGImageRef partialImageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
//
//#if SD_UIKIT || SD_WATCH
//            // Workaround for iOS anamorphic image
//            if (partialImageRef) {
//                const size_t partialHeight = CGImageGetHeight(partialImageRef);
//                CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//                CGContextRef bmContext = CGBitmapContextCreate(NULL, width, height, 8, width * 4, colorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
//                CGColorSpaceRelease(colorSpace);
//                if (bmContext) {
//                    CGContextDrawImage(bmContext, (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size.width = width, .size.height = partialHeight}, partialImageRef);
//                    CGImageRelease(partialImageRef);
//                    partialImageRef = CGBitmapContextCreateImage(bmContext);
//                    CGContextRelease(bmContext);
//                }
//                else {
//                    CGImageRelease(partialImageRef);
//                    partialImageRef = nil;
//                }
//            }
//#endif
//            if (partialImageRef) {
//
//                UIImage *image = [UIImage imageWithCGImage:partialImageRef scale:1 orientation:orientation];
//
//                NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:self.request.URL];
//                UIImage *scaledImage = [self scaledImageForKey:key image:image];
//                if (self.shouldDecompressImages) {
////                    image = [UIImage decodedImageWithImage:scaledImage];
//                }
//                else {
//                    image = scaledImage;
//                }
//                CGImageRelease(partialImageRef);
//
//                [self callCompletionBlocksWithImage:image imageData:nil error:nil finished:NO];
//            }
//        }
//        CFRelease(imageSource);
//    }
    for (ProgressBlock progressBlock in [self callbacksForKey:ProgressCallbackKey]) {
        NSLog(@"%ld %ld",self.imageData.length, self.expectedSize);
        progressBlock(self.imageData.length, self.expectedSize, self.request.URL);
    }
}
////url缓存处理
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler {
    responseFromCached = NO; // If this method is called, it means the response wasn't read from cache
    NSCachedURLResponse *cachedResponse = proposedResponse;
    
    if (self.request.cachePolicy == NSURLRequestReloadIgnoringLocalCacheData) {
        // Prevents caching of responses
        cachedResponse = nil;
    }
    if (completionHandler) {
        completionHandler(cachedResponse);
    }
}
#pragma mark ----- NSURLSessionTaskDelegate -----
////下载完成后数据处理
//- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
//    
//    @synchronized(self) {
//        self.dataTask = nil;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [[NSNotificationCenter defaultCenter] postNotificationName:DownLoadStopNotification object:self];
//            if (!error) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:DownLoadFinisnNotification object:self];
//            }
//        });
//    }
//    if (error) {
//        ///错误回调
//        [self callCompletionBlocksWithError:error];
//    }else{
//        if ([self callbacksForKey:CompletedCallbackKey].count > 0) {
//            /**
//             *  See #1608 and #1623 - apparently, there is a race condition on `NSURLCache` that causes a crash
//             *  Limited the calls to `cachedResponseForRequest:` only for cases where we should ignore the cached response
//             *    and images for which responseFromCached is YES (only the ones that cannot be cached).
//             *  Note: responseFromCached is set to NO inside `willCacheResponse:`. This method doesn't get called for large images or images behind authentication
//             */
//            if (self.options & SDWebImageDownloaderIgnoreCachedResponse && responseFromCached && [[NSURLCache sharedURLCache] cachedResponseForRequest:self.request]) {
//                // hack
//                [self callCompletionBlocksWithImage:nil imageData:nil error:nil finished:YES];
//            } else if (self.imageData) {
////                UIImage *image = [UIImage sd_imageWithData:self.imageData];
////                NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:self.request.URL];
////                image = [self scaledImageForKey:key image:image];
////
////                // Do not force decoding animated GIFs
////                if (!image.images) {
////                    if (self.shouldDecompressImages) {
////#warning 下载完之后gif图片处理
//////                        if (self.options & SDWebImageDownloaderScaleDownLargeImages) {
//////                            image = [UIImage decodedAndScaledDownImageWithImage:image];
//////                            [self.imageData setData:UIImagePNGRepresentation(image)];
//////                        } else {
//////                        }
////                        image = [UIImage decodedImageWithImage:image];
////                    }
////                }
////                if (CGSizeEqualToSize(image.size, CGSizeZero)) {
////                    [self callCompletionBlocksWithError:[NSError errorWithDomain:SDWebImageErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : @"Downloaded image has 0 pixels"}]];
////                } else {
////                    [self callCompletionBlocksWithImage:image imageData:self.imageData error:nil finished:YES];
////                }
//            } else {
//                [self callCompletionBlocksWithError:[NSError errorWithDomain:SDWebImageErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : @"Image data is nil"}]];
//            }
//        }
//    }
//    [self done];
//}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
//        if (!(self.options & SDWebImageDownloaderAllowInvalidSSLCertificates)) {
//            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
//        } else {
//
//        }
        credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        disposition = NSURLSessionAuthChallengeUseCredential;
    } else {
        if (challenge.previousFailureCount == 0) {
            if (self.credential) {
                credential = self.credential;
                disposition = NSURLSessionAuthChallengeUseCredential;
            } else {
                disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
            }
        } else {
            disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
        }
    }
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}
- (nullable UIImage *)scaledImageForKey:(nullable NSString *)key image:(nullable UIImage *)image {
    return nil;
//    return SDScaledImageForKey(key, image);
}
@end
