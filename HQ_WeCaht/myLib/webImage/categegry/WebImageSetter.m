//
//  WebImageSetter.m
//  YYStudyDemo
//
//  Created by hqz on 2018/7/16.
//  Copyright © 2018年 hqz. All rights reserved.
//

#import "WebImageSetter.h"
#import <libkern/OSAtomic.h>
#import "WebImageOperation.h"
NSString *const _YYWebImageFadeAnimationKey = @"WebImageFadeKey";
const NSTimeInterval _YYWebImageFadeTime = 0.2;
const NSTimeInterval _YYWebImageProgressiveFadeTime = 0.4;

@implementation WebImageSetter{
    dispatch_semaphore_t _lock;
    NSOperation *_operation;
    NSURL *_imageURL;
    int32_t _sentinel;
}

- (instancetype)init{
    self = [super init];
    _lock = dispatch_semaphore_create(1);
    return self;
}
- (void)dealloc {
    OSAtomicIncrement32(&_sentinel);
    [_operation cancel];
}
- (NSURL *)imageURL {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    NSURL *imageURL = _imageURL;
    dispatch_semaphore_signal(_lock);
    return imageURL;
}
- (int32_t)setOperationWithSentinel:(int32_t)sentinel url:(NSURL *)imageURL options:(YYWebImageOptions)options manager:(WebImageManager *)manager progress:(YYWebImageProgressBlock)progress transform:(YYWebImageTransformBlock)transform completion:(YYWebImageCompletionBlock)completion{
    if (sentinel != _sentinel) {
        if (completion) completion(nil, imageURL, YYWebImageFromNone, YYWebImageStageCancelled, nil);
        return _sentinel;
    }
    NSOperation *operation = [manager requestImageWithURL:imageURL options:options progress:progress transform:transform completion:completion];
    if (!operation && completion) {
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : @"YYWebImageOperation create failed." };
        completion(nil, imageURL, YYWebImageFromNone, YYWebImageStageFinished, [NSError errorWithDomain:@"com.ibireme.webimage" code:-1 userInfo:userInfo]);
    }
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    if (sentinel == _sentinel) {
        if (_operation) [_operation cancel];
        _operation = operation;
        sentinel = OSAtomicIncrement32(&_sentinel);
    } else {
        [operation cancel];
    }
    dispatch_semaphore_signal(_lock);
    return sentinel;
}
- (int32_t)cancel {
    return [self cancelWithNewUrl:nil];
}
- (int32_t )cancelWithNewUrl:(NSURL *)url{
#warning 此处有问题   当多个cell 都在加载图片 重复滑动一个cell 画出屏幕再滑入屏幕 (本来图片快要加载完了 结果滑入屏幕时改操作又会取消  又得重新下载 )  应该判断如果是当前的请求 就不应该取消 继续下载   webImageSetter 跟cell里面的控件一样也是会重用的 
    int32_t sentinel;
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    if (_operation) {
        [_operation cancel];
        _operation = nil;
    }
    _imageURL = url;
    sentinel = OSAtomicIncrement32(&_sentinel);
    dispatch_semaphore_signal(_lock);
    return sentinel;
}
+ (dispatch_queue_t)setterQueue {
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.ibireme.webimage.setter", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(queue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    });
    return queue;
}

@end
