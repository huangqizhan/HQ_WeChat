//
//  TextAsyncLayer.m
//  YYStudyDemo
//
//  Created by hqz  QQ 757618403 on 2018/9/3.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//

#import "TextAsyncLayer.h"
#import <libkern/OSAtomic.h>


static dispatch_queue_t TextAsyncLayerDisplayQueue(){
#define MAX_QUEUE_COUNT 16
    static int queueCount;
    static dispatch_queue_t queues[MAX_QUEUE_COUNT];
    static int32_t counter = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queueCount = (int)[NSProcessInfo processInfo].activeProcessorCount;
        queueCount = queueCount < 1 ? 1: queueCount > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : queueCount;
        if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
            for (int i = 0; i < queueCount; i++) {
                ///用qos 创建串行队列
                dispatch_queue_attr_t att = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED,0);
                dispatch_queue_t queue = dispatch_queue_create("text_render_queue", att);
                queues[i] = queue;
            }
        }else{
            for (int i = 0; i < queueCount; i++) {
                dispatch_queue_t queue = dispatch_queue_create("text_render_queue", DISPATCH_QUEUE_SERIAL);
                //设置队列优先级 （本来多个串行队列可以并行执行 但设置target后 多个串行队列可以并行知执行）
                dispatch_set_target_queue(queue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
                queues[i] = queue;
            }
        }
    });
    uint32_t cur = (uint32_t)OSAtomicIncrement32(&counter);
    return queues[(cur) % queueCount];
#undef MAX_QUEUE_COUNT
}
static dispatch_queue_t TextLayerAsyncReleaseQueue(){
#ifdef DispatchQueuePool_h
    return  DispatchGetQueueForQos(NSQualityOfServiceDefault);
#endif
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
}

/// a thread safe incrementing counter.
@interface _YYTextSentinel : NSObject
/// Returns the current value of the counter.
@property (atomic, readonly) int32_t value;
/// Increase the value atomically. @return The new value.
- (int32_t)increase;
@end

@implementation _YYTextSentinel {
    int32_t _value;
}
- (int32_t)value {
    return _value;
}
- (int32_t)increase {
    return OSAtomicIncrement32(&_value);
}

@end

@implementation TextAsyncLayerDisplayTask



@end



@implementation TextAsyncLayer{
    _YYTextSentinel *_sentinel;
}
///过滤属性值
+ (id)defaultValueForKey:(NSString *)key{
    if ([key isEqualToString:@"displaysAsynchronously"]) {
        return @(YES);
    } else {
        return [super defaultValueForKey:key];
    }
}

- (instancetype)init{
    self = [super init];
    if (self) {
        static CGFloat scale; //global
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            scale = [UIScreen mainScreen].scale;
        });
        self.contentsScale = scale;
        _sentinel = [_YYTextSentinel new];
        _displaysAsynchronously = YES;
    }
    return self;
}
- (void)dealloc{
    [_sentinel increase];
}

- (void)setNeedsDisplay{
    [self _cancelDisplay];
    [super setNeedsDisplay];
}
- (void)display{
    super.contents = super.contents;
    [self _displayAsync:_displaysAsynchronously];
}
///用背景色绘制成一张图片 再填充到contents 中
- (void)_displayAsync:(BOOL)displayAsync{
    __strong id <TextAsyncLayerDelegate> delegate = (id)self.delegate;
    TextAsyncLayerDisplayTask *task = [delegate newTextAsyncLayerDisplayTask];
    if (!task.display) {
        if(task.willDisplay) task.willDisplay(self);
        self.contents = nil;
        if(task.didDisplay) task.didDisplay(self,YES);
        return;
    }
    ///多个异步任务可能会同时一下判断 （在一个layer上头头脑是绘制 ） 为此添加 _YYTextSentinel 保证同一时间有一个异步的绘制任务  
    if (displayAsync) {
        if(task.willDisplay) task.willDisplay(self);
        _YYTextSentinel *sentinel = _sentinel;
        int32_t value = sentinel.value;
        BOOL (^isCanceled)(void) = ^ BOOL(void){
            return value != sentinel.value;
        };
        CGSize size = self.bounds.size;
        BOOL opaque = self.opaque;
        CGFloat scale = self.contentsScale;
        CGColorRef backgroundColor = (opaque && self.backgroundColor) ?CGColorRetain(self.backgroundColor) : NULL;
        if (size.width < 1 || size.height < 1) {
            CGImageRef image = (__bridge CGImageRef)self.contents;
            if (image) {
                dispatch_async(TextLayerAsyncReleaseQueue(), ^{
                    CGImageRelease(image);
                });
            }
            if (task.didDisplay) task.didDisplay(self,YES);
            CGColorRelease(backgroundColor);
            return;
        }
        dispatch_async(TextAsyncLayerDisplayQueue(), ^{
            if (isCanceled()) {
                CGColorRelease(backgroundColor);
                return ;
            }
            UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
            CGContextRef contenxt = UIGraphicsGetCurrentContext();
            if (opaque && contenxt) {
                CGContextSaveGState(contenxt);
                if (!backgroundColor || CGColorGetAlpha(backgroundColor) < 1) {
                    CGContextSetFillColorWithColor(contenxt, [UIColor whiteColor].CGColor);
                    CGContextAddRect(contenxt, CGRectMake(0, 0, size.width*scale, size.height*scale));
                    CGContextFillPath(contenxt);
                }
                if (backgroundColor) {
                    CGContextSetFillColorWithColor(contenxt, backgroundColor);
                    CGContextAddRect(contenxt, CGRectMake(0, 0, size.width*scale, size.height*scale));
                    CGContextFillPath(contenxt);
                }
                CGContextRestoreGState(contenxt);
                CGColorRelease(backgroundColor);
            }
            if (task.display) task.display(contenxt, size, isCanceled);
            if (isCanceled()) {
                UIGraphicsEndImageContext();
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(task.didDisplay) task.didDisplay(self, NO);
                });
                return;
            }
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            if (isCanceled()) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(task.didDisplay) task.didDisplay(self, NO);
                });
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (isCanceled()) {
                    if(task.didDisplay) task.didDisplay(self, NO);
                }else{
                    self.contents = (__bridge id)image.CGImage;
                    if(task.didDisplay) task.didDisplay(self, YES);
                }
                
            });
        });
    }else{
        [_sentinel increase];
        if (task.willDisplay) task.willDisplay(self);
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, self.contentsScale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (self.opaque && context) {
            CGSize size = self.bounds.size;
            size.width *= self.contentsScale;
            size.height *= self.contentsScale;
            CGContextSaveGState(context); {
                if (!self.backgroundColor || CGColorGetAlpha(self.backgroundColor) < 1) {
                    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
                    CGContextAddRect(context, CGRectMake(0, 0, size.width, size.height));
                    CGContextFillPath(context);
                }
                if (self.backgroundColor) {
                    CGContextSetFillColorWithColor(context, self.backgroundColor);
                    CGContextAddRect(context, CGRectMake(0, 0, size.width, size.height));
                    CGContextFillPath(context);
                }
            } CGContextRestoreGState(context);
        }
        task.display(context, self.bounds.size, ^{return NO;});
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.contents = (__bridge id)(image.CGImage);
        if (task.didDisplay) task.didDisplay(self, YES);
    }
}
- (void)_cancelDisplay{
    [_sentinel increase];
}

@end
