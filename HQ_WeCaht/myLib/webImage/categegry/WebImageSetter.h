//
//  WebImageSetter.h
//  YYStudyDemo
//
//  Created by hqz  QQ 757618403 on 2018/7/16.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <pthread.h>
#import "WebImageManager.h"


extern NSString *const _YYWebImageFadeAnimationKey;
extern const NSTimeInterval _YYWebImageFadeTime;
extern const NSTimeInterval _YYWebImageProgressiveFadeTime;

static inline void _yy_dispatch_sync_on_main_queue(void (^block)(void)) {
    if (pthread_main_np()) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}
/**
 用来控制 如果同一个URL 多次请求  避免重复多次请求
 */
@interface WebImageSetter : NSObject
/// Current image url.
@property (nullable, nonatomic, readonly) NSURL *imageURL;
/// Current sentinel.
@property (nonatomic, readonly) int32_t sentinel;


/// Create new operation for web image and return a sentinel value.
- (int32_t)setOperationWithSentinel:(int32_t)sentinel
                                url:(nullable NSURL *)imageURL
                            options:(YYWebImageOptions)options
                            manager:(WebImageManager *)manager
                           progress:(nullable YYWebImageProgressBlock)progress
                          transform:(nullable YYWebImageTransformBlock)transform
                         completion:(nullable YYWebImageCompletionBlock)completion;


- (int32_t )cancelWithNewUrl:(NSURL *)url;

/// Cancel and return a sentinel value. The imageURL will be set to nil.
- (int32_t)cancel;

/// A queue to set operation.
+ (dispatch_queue_t)setterQueue;


@end
