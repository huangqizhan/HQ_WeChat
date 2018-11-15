//
//  AnimatedImageView.m
//  YYStudyDemo
//
//  Created by hqz  QQ 757618403 on 2018/7/4.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//

#import "AnimatedImageView.h"
#import "ImageDeCode.h"
#import <mach/mach.h>
#import <pthread.h>

#define BUFFER_SIZE (10 * 1024 * 1024) // 10MB (minimum memory buffer size)

#define LOCK(...) dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER); \
__VA_ARGS__; \
dispatch_semaphore_signal(self->_lock);

#define LOCK_VIEW(...) dispatch_semaphore_wait(view->_lock, DISPATCH_TIME_FOREVER); \
__VA_ARGS__; \
dispatch_semaphore_signal(view->_lock);

///设备内存
static int64_t _YYDeviceMemoryTotal() {
    int64_t mem = [[NSProcessInfo processInfo] physicalMemory];
    if (mem < -1) mem = -1;
    return mem;
}
///设备剩余内存
static int64_t _YYDeviceMemoryFree() {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t page_size;
    vm_statistics_data_t vm_stat;
    kern_return_t kern;
    
    kern = host_page_size(host_port, &page_size);
    if (kern != KERN_SUCCESS) return -1;
    kern = host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    if (kern != KERN_SUCCESS) return -1;
    return vm_stat.free_count * page_size;
}

///weak retaion
@interface ImageWeakProxy : NSProxy
@property (nonatomic,strong) id target;
- (instancetype)initWithTarget:(id)target;
+ (instancetype)proxyWithTarget:(id)target;
@end

@implementation ImageWeakProxy
- (instancetype)initWithTarget:(id)target{
    _target = target;
    return self;
}
+ (instancetype)proxyWithTarget:(id)target{
   return [[self alloc] initWithTarget:target];
}
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel{
    NSMethodSignature *method = nil;
    method = [self.target methodSignatureForSelector:sel];
    return method;
}
- (void)forwardInvocation:(NSInvocation *)invocation{
    [invocation invokeWithTarget:self.target];
}
#pragma mark ------ <NSObject>
- (BOOL)respondsToSelector:(SEL)aSelector{
    return [_target respondsToSelector:aSelector];
}
- (BOOL)isEqual:(id)object{
    return [_target isEqual:object];
}
- (NSUInteger)hash{
    return [_target hash];
}
- (Class)superclass{
    return [_target superclass];
}
- (Class)class{
   return [_target class];
}
- (BOOL)isKindOfClass:(Class)aClass{
    return [_target isKindOfClass:aClass];
}
- (BOOL)isMemberOfClass:(Class)aClass{
    return [_target isMemberOfClass:aClass];
}
- (BOOL)conformsToProtocol:(Protocol *)aProtocol{
    return [_target conformsToProtocol:aProtocol];
}
- (BOOL)isProxy{
    return YES;
}
- (NSString *)description{
    return [_target description];
}
- (NSString *)debugDescription{
    return [_target debugDescription];
}
@end

typedef NS_ENUM(NSUInteger, YYAnimatedImageType) {
    YYAnimatedImageTypeNone = 0,
    YYAnimatedImageTypeImage,
    YYAnimatedImageTypeHighlightedImage,
    YYAnimatedImageTypeImages,
    YYAnimatedImageTypeHighlightedImages,
};

@interface  AnimatedImageView(){
    @package
    ///原始图片资源
    UIImage <YYAnimatedImage> *_curAniamtedImage;
    ///锁
    dispatch_semaphore_t _lock;
    ///播放队列
    NSOperationQueue *_requestQueue;
    ///界面刷新定时器
    CADisplayLink *_link;
    ///播放时间
    NSTimeInterval _time;
    ///当前正在播放的帧
    UIImage *_curFrame;
    ///当前播放帧的索引
    NSUInteger _curIndex;
    //总的帧数
    NSUInteger _totalFrameCount;
    ///是否播放结束
    BOOL _loopEnd;
    ///当前已经循环播放了多少次
    NSUInteger _cutLoop;
    ///总共播放的次数  如果是0 会无限循环
    NSUInteger _totalLoop;
    //播放的帧value  及index key
    NSMutableDictionary *_buffer;
    ///是否跳帧
    BOOL _bufferMiss;
    ///最大的动画播放数量
    NSUInteger _maxBufferCount;
    
    NSUInteger _increBufferCount;
    ///当前帧的rect
    CGRect _curContentsRect;
    ///当前帧是否有rect
    BOOL _curImageHasContentsRect;
}
///是否正在播放
@property (nonatomic, readwrite) BOOL currentIsPlayingAnimation;

- (void)calcMaxBufferCount;
@end


/**
 图片资源读取的异步操作都在此 operation 里面
 */
@interface AnimatedImageViewFetchOperation : NSOperation

@property (nonatomic,weak) AnimatedImageView *view;
@property (nonatomic,assign) NSUInteger nextIndex;
@property (nonatomic,strong) UIImage <YYAnimatedImage>  *currImage;

@end


@implementation  AnimatedImageViewFetchOperation

- (void)main{
    __strong AnimatedImageView *view = _view;
    if(!view) return;
    if([self isCancelled]) return;
    view->_increBufferCount ++ ;
    if (view->_increBufferCount == 0) {
        [view calcMaxBufferCount];
    }
    if (view->_increBufferCount > (NSInteger) view->_maxBufferCount) {
        view->_increBufferCount = view->_maxBufferCount;
    }
    NSUInteger idx = _nextIndex;
    NSUInteger max = view->_increBufferCount < 1 ? 1 : view->_increBufferCount;
    NSUInteger total = view->_totalFrameCount;
    view = nil;
    ////填充buffer 数据
    for (int i = 0 ; i < max ; i++ , idx++) {
        @autoreleasepool{
            if(idx >= total) idx = 0;
            if ([self isCancelled]) break;
            __strong AnimatedImageView *view = _view;
            if (!view) break;
            LOCK_VIEW(BOOL miss = (view->_buffer[@(idx)] == nil);
            );
            if (miss) {
                 UIImage *img = [_currImage animatedImageFrameAtIndex:idx];
                img = img.imageByDecoded;
                if([self isCancelled]) break;
                view->_buffer[@(idx)] = img ? img : [NSNull null];
                view = nil;
            }
        }
    }
}

@end

@implementation AnimatedImageView


- (instancetype)init {
    self = [super init];
    _runloopMode = NSDefaultRunLoopMode;
    _autoPlayAnimatedImage = YES;
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    _runloopMode = NSDefaultRunLoopMode;
    _autoPlayAnimatedImage = YES;
    return self;
}

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    _runloopMode = NSDefaultRunLoopMode;
    _autoPlayAnimatedImage = YES;
    self.frame = (CGRect) {CGPointZero, image.size };
    self.image = image;
    return self;
}

- (instancetype)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage {
    self = [super init];
    _runloopMode = NSDefaultRunLoopMode;
    _autoPlayAnimatedImage = YES;
    CGSize size = image ? image.size : highlightedImage.size;
    self.frame = (CGRect) {CGPointZero, size };
    self.image = image;
    self.highlightedImage = highlightedImage;
    return self;
}
- (void)resetAniamted{
    if (!_link) {
        _lock = dispatch_semaphore_create(1);
        _buffer = [NSMutableDictionary new];
        _requestQueue = [[NSOperationQueue alloc] init];
        _requestQueue.maxConcurrentOperationCount = 2;
        _link = [CADisplayLink displayLinkWithTarget:[ImageWeakProxy proxyWithTarget:self] selector:@selector(step:)];
        if (_runloopMode) {
            [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:_runloopMode];
        }
        _link.paused = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    [_requestQueue cancelAllOperations];
    LOCK(
         if (_buffer.count){
             NSMutableDictionary *holder = _buffer;
             _buffer = [NSMutableDictionary new];
            ///让对象在子线程中销毁 减少主线程的消耗
             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                 [holder class];
             });
         }
    );
    _link.paused = YES;
    _time = 0;
    if (_curIndex != 0) {
        [self willChangeValueForKey:@"currentAnimatedImageIndex"];
        _curIndex = 0;
        [self didChangeValueForKey:@"currentAnimatedImageIndex"];
    }
    _curAniamtedImage = nil;
    _curFrame = nil;
    _cutLoop = 0;
    _totalLoop = 0;
    _totalFrameCount = 1;
    _loopEnd = NO;
    _bufferMiss = NO;
    _increBufferCount = 0;
}
- (void)dealloc {
    [_requestQueue cancelAllOperations];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [_link invalidate];
}
///设置image
- (void)setImage:(UIImage *)image{
    if (self.image == image) return;
    [self setImage:image withType:YYAnimatedImageTypeImage];
}
- (void)setHighlightedImage:(UIImage *)highlightedImage{
    if (self.highlightedImage == highlightedImage) return;
    [self setImage:highlightedImage withType:YYAnimatedImageTypeHighlightedImage];
}
- (void)setAnimationImages:(NSArray<UIImage *> *)animationImages{
    if(self.animationImages == animationImages) return;
    [self setImage:animationImages withType:YYAnimatedImageTypeImages];
}
- (void)setHighlightedAnimationImages:(NSArray<UIImage *> *)highlightedAnimationImages{
    if (self.highlightedAnimationImages == highlightedAnimationImages) return;
    [self setImage:highlightedAnimationImages withType:YYAnimatedImageTypeHighlightedImages];
}
- (void)setHighlighted:(BOOL)highlighted{
    [super setHighlighted:highlighted];
    if(_link) [self resetAniamted];
    [self imageChanged];
}
- (void)setImage:(id )image withType:(YYAnimatedImageType)type{
    [super stopAnimating];
    if (_link) [self resetAniamted];
     _curFrame = nil;
    switch (type) {
        case YYAnimatedImageTypeNone: break;
        case YYAnimatedImageTypeImage: super.image = image; break;
        case YYAnimatedImageTypeHighlightedImage: super.highlightedImage = image; break;
        case YYAnimatedImageTypeImages: super.animationImages = image; break;
        case YYAnimatedImageTypeHighlightedImages: super.highlightedAnimationImages = image; break;
    }
    [self imageChanged];
}
- (void)step:(CADisplayLink *)link{
    UIImage <YYAnimatedImage> *image = _curAniamtedImage;
    NSMutableDictionary *buffer = _buffer;
    UIImage *bufferedImage = nil;
    NSUInteger nextIndex = (_curIndex + 1) % _totalFrameCount;
    ////帧数是否已经填满
    BOOL bufferIsFull = NO;
    ///0.016667
    if (!image) return;
    if(_loopEnd){
        [self stopAnimating];
        return;
    }
    NSTimeInterval delay = 0;
    ///是否丢了帧
    if (!_bufferMiss) {
        _time += _link.duration;
        delay = [image animatedImageDurationAtIndex:_curIndex];
        /// 当播放每一帧的时间积累小于当前帧的播放时间
        if(_time < delay) return;
        ///退回到原来的时间
        _time -= delay;
        ///播放到最后一帧
        if (nextIndex == 0) {
            _cutLoop ++ ;
            ///是否播放结束
            if (_cutLoop >= _totalLoop && _totalLoop != 0) {
                _loopEnd = YES;
                [self stopAnimating];
                [self.layer setNeedsDisplay];
                return;
            }
        }
        delay = [image animatedImageDurationAtIndex:nextIndex];
        if (_time > delay)  _time = delay;
    }
    ///切换self.layer 的contents  需要加锁控制
    LOCK(
         bufferedImage = buffer[@(nextIndex)];
         if (bufferedImage){
             if((int) _increBufferCount < _totalFrameCount){
                 [buffer removeObjectForKey:@(nextIndex)];
             }
             [self willChangeValueForKey:@"currentAnimatedImageIndex"];
             _curIndex = nextIndex;
             [self didChangeValueForKey:@"currentAnimatedImageIndex"];
             _curFrame = bufferedImage == (id)[NSNull null] ? nil : bufferedImage;
             if (_curImageHasContentsRect) {
                 _curContentsRect = [image animatedImageContentsRectAtIndex:_curIndex];
                 [self setContentsRect:_curContentsRect forImage:_curFrame];
             }
             _bufferMiss = NO;
             nextIndex = (_curIndex + 1) % _totalFrameCount;
             ////数据已经全部填充到buffer当中 就不会在队列中异步填充数据
             if (buffer.count == _totalFrameCount) {
                 bufferIsFull = YES;
             }
         }else{
            _bufferMiss = YES;
         }
    );
    ////显示layer contents
    if (!_bufferMiss) {
        [self.layer setNeedsDisplay]; // let system call `displayLayer:` before runloop sleep
    }
    ///队列还没有添加操作 或者 数据还没有填充
    if (!bufferIsFull && _requestQueue.operationCount == 0) {
        AnimatedImageViewFetchOperation *operation = [AnimatedImageViewFetchOperation new];
        operation.view = self;
        operation.nextIndex = nextIndex;
        operation.currImage = image;
        [_requestQueue addOperation:operation];
    }
}
- (void)imageChanged{
    YYAnimatedImageType newType = [self currentImageType];
    id newVisibleImage = [self imageForType:newType];
    NSUInteger newImageFrameCount = 0;
    BOOL hasContentsRect = NO;
    if ([newVisibleImage isKindOfClass:[UIImage class]] && [newVisibleImage conformsToProtocol:@protocol(YYAnimatedImage)]) {
        ///gif 帧数
        newImageFrameCount = ((UIImage <YYAnimatedImage> *) newVisibleImage).animatedImageFrameCount;
        if (newImageFrameCount > 1) {
            ///是否有contents
            hasContentsRect = [(UIImage <YYAnimatedImage> *)newVisibleImage respondsToSelector:@selector(animatedImageContentsRectAtIndex:)];
        }
    }
#warning =======
    if (!hasContentsRect && _curImageHasContentsRect) {
        if (!CGRectEqualToRect(self.layer.contentsRect, CGRectMake(0, 0, 1, 1)) ) {
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            self.layer.contentsRect = CGRectMake(0, 0, 1, 1);
            [CATransaction commit];
        }
    }
    _curImageHasContentsRect = hasContentsRect;
    if (hasContentsRect) {
        CGRect rect = [((UIImage<YYAnimatedImage> *) newVisibleImage) animatedImageContentsRectAtIndex:0];
        [self setContentsRect:rect forImage:newVisibleImage];
    }
    if (newImageFrameCount > 1) {
        [self resetAniamted];
        _curAniamtedImage = newVisibleImage;
        _curFrame = newVisibleImage;
        _totalLoop = _curAniamtedImage.animatedImageLoopCount;
        _totalFrameCount = _curAniamtedImage.animatedImageFrameCount;
        [self calcMaxBufferCount];
    }
    [self setNeedsDisplay];
    [self didMoved];
}
- (void)didMoved {
    if (self.autoPlayAnimatedImage) {
        if(self.superview && self.window) {
            [self startAnimating];
        } else {
            [self stopAnimating];
        }
    }
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    [self didMoved];
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    [self didMoved];
}
#pragma mark ----- rewrite -----
- (BOOL)isAnimating{
    return self.currentIsPlayingAnimation;
}
- (void)startAnimating{
    YYAnimatedImageType type = [self currentImageType];
    if (type == YYAnimatedImageTypeImages || type == YYAnimatedImageTypeHighlightedImages) {
        NSArray *images = [self imageForType:type];
        if (images.count) {
            [super startAnimating];
            self.currentIsPlayingAnimation = YES;
        }
    }else{
        if (_curAniamtedImage && _link.paused) {
            _cutLoop = 0;
            _loopEnd = NO;
            _link.paused = NO;
            self.currentIsPlayingAnimation = YES;
        }
    }
}
- (void)stopAnimating{
    [super stopAnimating];
    _link.paused = YES;
    [_requestQueue cancelAllOperations];
    self.currentIsPlayingAnimation = NO;
}
///呈现没一帧的内容 self.layer setNeedDisplay  callback
- (void)displayLayer:(CALayer *)layer{
    layer.contents = (__bridge id)_curFrame.CGImage;
}
///内存警告
- (void)didReceiveMemoryWarning:(NSNotification *)noti{
    [_requestQueue cancelAllOperations];
    [_requestQueue addOperationWithBlock: ^{
        self->_increBufferCount = -60 - (int)(arc4random() % 120); // about 1~3 seconds to grow back..
        NSNumber *next = @((self->_curIndex + 1) % self->_totalFrameCount);
        LOCK(
             NSArray * keys = self->_buffer.allKeys;
             for (NSNumber * key in keys) {
                 if (![key isEqualToNumber:next]) { // keep the next frame for smoothly animation
                     [self->_buffer removeObjectForKey:key];
                 }
             }
             )//LOCK
    }];
}
///进入后台
- (void)didEnterBackground:(NSNotification *)info{
    [_requestQueue cancelAllOperations];
    NSNumber *next = @((_curIndex + 1) % _totalFrameCount);
    LOCK(
         NSArray * keys = _buffer.allKeys;
         for (NSNumber * key in keys) {
             if (![key isEqualToNumber:next]) { // keep the next frame for smoothly animation
                 [_buffer removeObjectForKey:key];
             }
         }
    )//LOCK
    dispatch_semaphore_signal(_lock);
}
- (void)setCurrentAnimatedImageIndex:(NSUInteger)currentAnimatedImageIndex{
    if (!_curAniamtedImage) return;
    if (currentAnimatedImageIndex >= _curAniamtedImage.animatedImageFrameCount) return;
    if(currentAnimatedImageIndex == _curIndex) return;
    void (^block)(void) = ^{
        LOCK(
             [self->_requestQueue cancelAllOperations];
             [self->_buffer removeAllObjects];
             [self willChangeValueForKey:@"currentAnimatedImageIndex"];
             self->_curIndex = currentAnimatedImageIndex;
             [self didChangeValueForKey:@"currentAnimatedImageIndex"];
             self->_curFrame = [self->_curAniamtedImage animatedImageFrameAtIndex:self->_curIndex];
             if (self->_curImageHasContentsRect) {
                 self->_curContentsRect = [self->_curAniamtedImage animatedImageContentsRectAtIndex:self->_curIndex];
             }
             self->_time = 0;
             self->_loopEnd = NO;
             self->_bufferMiss = NO;
             [self.layer setNeedsDisplay];
        )
    };
    if (pthread_main_np()) {
        block();
    }else{
        dispatch_async(dispatch_get_main_queue(), block);
    }
}
- (NSUInteger)currentAnimatedImageIndex {
    return _curIndex;
}
- (void)setRunloopMode:(NSString *)runloopMode {
    if ([_runloopMode isEqual:runloopMode]) return;
    if (_link) {
        if (_runloopMode) {
            [_link removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:_runloopMode];
        }
        if (runloopMode.length) {
            [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:runloopMode];
        }
    }
    _runloopMode = runloopMode.copy;
}

- (YYAnimatedImageType)currentImageType {
    YYAnimatedImageType curType = YYAnimatedImageTypeNone;
    if (self.highlighted) {
        if (self.highlightedAnimationImages.count) curType = YYAnimatedImageTypeHighlightedImages;
        else if (self.highlightedImage) curType = YYAnimatedImageTypeHighlightedImage;
    }
    if (curType == YYAnimatedImageTypeNone) {
        if (self.animationImages.count) curType = YYAnimatedImageTypeImages;
        else if (self.image) curType = YYAnimatedImageTypeImage;
    }
    return curType;
}
- (id)imageForType:(YYAnimatedImageType)type {
    switch (type) {
        case YYAnimatedImageTypeNone: return nil;
        case YYAnimatedImageTypeImage: return self.image;
        case YYAnimatedImageTypeHighlightedImage: return self.highlightedImage;
        case YYAnimatedImageTypeImages: return self.animationImages;
        case YYAnimatedImageTypeHighlightedImages: return self.highlightedAnimationImages;
    }
    return nil;
}
- (void)setContentsRect:(CGRect)rect forImage:(UIImage *)image{
    CGRect layerRect = CGRectMake(0, 0, 1, 1);
    if (image) {
        CGSize imageSize = image.size;
        if (imageSize.width > 0.01 && imageSize.height > 0.01) {
            layerRect.origin.x = rect.origin.x / imageSize.width;
            layerRect.origin.y = rect.origin.y / imageSize.height;
            layerRect.size.width = rect.size.width / imageSize.width;
            layerRect.size.height = rect.size.height / imageSize.height;
            layerRect = CGRectIntersection(layerRect, CGRectMake(0, 0, 1, 1));
            if (CGRectIsNull(layerRect) || CGRectIsEmpty(layerRect)) {
                layerRect = CGRectMake(0, 0, 1, 1);
            }
        }
    }
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.layer.contentsRect = layerRect;
    [CATransaction commit];
}
// dynamically adjust buffer size for current memory.
- (void)calcMaxBufferCount {
    int64_t bytes = (int64_t)_curAniamtedImage.animatedImageBytesPerFrame;
    if (bytes == 0) bytes = 1024;
    
    int64_t total = _YYDeviceMemoryTotal();
    int64_t free = _YYDeviceMemoryFree();
    int64_t max = MIN(total * 0.2, free * 0.6);
    max = MAX(max, BUFFER_SIZE);
    if (_maxBufferSize) max = max > _maxBufferSize ? _maxBufferSize : max;
    double maxBufferCount = (double)max / (double)bytes;
    if (maxBufferCount < 1) maxBufferCount = 1;
    else if (maxBufferCount > 512) maxBufferCount = 512;
    _maxBufferCount = maxBufferCount;
}
#pragma mark - Override NSObject(NSKeyValueObservingCustomization)

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    if ([key isEqualToString:@"currentAnimatedImageIndex"]) {
        return NO;
    }
    return [super automaticallyNotifiesObserversForKey:key];
}
#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    _runloopMode = [aDecoder decodeObjectForKey:@"runloopMode"];
    if (_runloopMode.length == 0) _runloopMode = NSDefaultRunLoopMode;
    if ([aDecoder containsValueForKey:@"autoPlayAnimatedImage"]) {
        _autoPlayAnimatedImage = [aDecoder decodeBoolForKey:@"autoPlayAnimatedImage"];
    } else {
        _autoPlayAnimatedImage = YES;
    }
    
    UIImage *image = [aDecoder decodeObjectForKey:@"YYAnimatedImage"];
    UIImage *highlightedImage = [aDecoder decodeObjectForKey:@"YYHighlightedAnimatedImage"];
    if (image) {
        self.image = image;
        [self setImage:image withType:YYAnimatedImageTypeImage];
    }
    if (highlightedImage) {
        self.highlightedImage = highlightedImage;
        [self setImage:highlightedImage withType:YYAnimatedImageTypeHighlightedImage];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_runloopMode forKey:@"runloopMode"];
    [aCoder encodeBool:_autoPlayAnimatedImage forKey:@"autoPlayAnimatedImage"];
    
    BOOL ani, multi;
    ani = [self.image conformsToProtocol:@protocol(YYAnimatedImage)];
    multi = (ani && ((UIImage <YYAnimatedImage> *)self.image).animatedImageFrameCount > 1);
    if (multi) [aCoder encodeObject:self.image forKey:@"YYAnimatedImage"];
    
    ani = [self.highlightedImage conformsToProtocol:@protocol(YYAnimatedImage)];
    multi = (ani && ((UIImage <YYAnimatedImage> *)self.highlightedImage).animatedImageFrameCount > 1);
    if (multi) [aCoder encodeObject:self.highlightedImage forKey:@"YYHighlightedAnimatedImage"];
}

@end



