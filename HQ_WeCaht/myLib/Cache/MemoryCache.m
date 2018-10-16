//
//  MemoryCache.m
//  YYStudy
//
//  Created by hqz on 2018/5/24.
//  Copyright © 2018年 hqz. All rights reserved.
//

#import "MemoryCache.h"
#import <libkern/OSAtomic.h>
#import <QuartzCore/QuartzCore.h>
#import <pthread.h>
#import <UIKit/UIKit.h>
#if __has_include("DispatchQueuePool.h")
#import "DispatchQueuePool.h"
#endif

#ifdef DispatchQueuePool_h
static inline dispatch_queue_t MemeryCacheGetReleaseQueue(){
    return DispatchGetQueueForQos(NSQualityOfServiceUtility);
}
#else
static inline dispatch_queue_t MemeryCacheGetReleaseQueue(NSQualityOfService qos){
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
}
#endif

@interface MemeryCacheMapNode : NSObject{
    @package
    __unsafe_unretained MemeryCacheMapNode *_prev;
    __unsafe_unretained MemeryCacheMapNode *_next;
    id _key;
    id _value;
    NSUInteger _cost;
    NSTimeInterval _time;
}
@end
@implementation  MemeryCacheMapNode
@end

@interface MemeryCacheMap : NSObject{
    @package;
    CFMutableDictionaryRef _dic;
    NSUInteger _totalCost;
    NSUInteger _totalCount;
    MemeryCacheMapNode *_head;
    MemeryCacheMapNode *_tail;
    BOOL _releaseOnMainThread;
    BOOL _releaseAsynchronously;
}
- (void)insertNodeAtHead:(MemeryCacheMapNode *)node;
- (void)bringNodeAtHead:(MemeryCacheMapNode *)node;
- (void)removeNode:(MemeryCacheMapNode *)node;
- (MemeryCacheMapNode *)removeTailNode;
- (void)removeAll;

@end

@implementation  MemeryCacheMap
- (instancetype)init{
    self = [super init];
    _dic = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    _releaseOnMainThread = NO;
    _releaseAsynchronously = YES;
    return self;
}
- (void)dealloc{
    CFRelease(_dic);
}
- (void)insertNodeAtHead:(MemeryCacheMapNode *)node{
    CFDictionarySetValue(_dic, (__bridge const void *)node->_key, (__bridge const void *)node);
    _totalCost += node->_cost;
    _totalCount ++ ;
    if (_head) {
        node->_next = _head;
        _head->_prev = node;
        _head = node;
    }else{
        _head = _tail = node;
    }
}
- (void)bringNodeAtHead:(MemeryCacheMapNode *)node{
    if (_head == node) return;
    if (_tail == node) {
        ///_tail 指向node的上一个  （删除最node）
        _tail = node->_prev;
        _tail->_next = nil;
    }else{
        ///（删除node）node的上一个跟node的下一个链接
        node->_prev->_next = node->_next;
        node->_next->_prev = node->_prev;
    }
    ///把node 放在_head前面
    node->_next = _head;
    node->_prev = nil;
    _head->_prev = node;
    ///替换node跟_head
    _head = node;
}
- (void)removeNode:(MemeryCacheMapNode *)node{
    CFDictionaryRemoveValue(_dic, (__bridge const void *)node->_key);
    _totalCount --;
    _totalCost -= node->_cost;
    if(node->_next) node->_next->_prev = node->_prev;
    if(node->_prev) node->_prev->_next = node->_next;
    if(_head == node) _head = node->_next;
    if(_tail == node) _tail = node->_prev;
}
- (MemeryCacheMapNode *)removeTailNode{
    if (!_tail) return nil;
    CFDictionaryRemoveValue(_dic, (__bridge const void *)_tail->_key);
    _totalCount -- ;
    _totalCost -= _tail->_cost;
    if (_tail == _head) {
        _tail = _head = nil;
    }else{
        _tail = _tail->_prev;
        _tail->_next = nil;
    }
    return _tail;
}
- (void)removeAll{
    _totalCount = 0;
    _totalCost = 0;
    _head = _tail = nil;
    if (CFDictionaryGetCount(_dic) > 0) {
        CFDictionaryRef temp = _dic;
        _dic = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        if (_releaseAsynchronously) {
            dispatch_queue_t queue = MemeryCacheGetReleaseQueue();
            dispatch_async(queue, ^{
                CFRelease(temp);
            });
        }else if (_releaseOnMainThread){
            dispatch_async(dispatch_get_main_queue(), ^{
                CFRelease(temp);
            });
        }else{
            CFRelease(temp);
        }
    }
}
@end


@implementation MemoryCache{
    pthread_mutex_t _lock;
    MemeryCacheMap  *_lru;
    dispatch_queue_t _queue;
}

- (void)trimRecursively{
    __strong typeof(self) _self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_autoTrimInterval * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        __strong typeof(self) self = _self;
        if (!self) return ;
        [self trimInBackground];
        [self trimRecursively];
    });
}
- (void)trimInBackground{
    dispatch_async(_queue , ^{
        [self _trimToCost:self->_costLimit];
        [self _trimToCount:self->_countLimit];
        [self _trimToAge:self->_ageLimit];
    });
}
- (void)_trimToCost:(NSUInteger)costLimit {
    BOOL finish = NO;
    pthread_mutex_lock(&_lock);
    if (costLimit == 0) {
        [_lru removeAll];
        finish = YES;
    } else if (_lru->_totalCost <= costLimit) {
        finish = YES;
    }
    pthread_mutex_unlock(&_lock);
    if (finish) return;
    
    NSMutableArray *holder = [NSMutableArray new];
    while (!finish) {
        if (pthread_mutex_trylock(&_lock) == 0) {
            if (_lru->_totalCost > costLimit) {
                MemeryCacheMapNode *node = [_lru removeTailNode];
                if (node) [holder addObject:node];
            } else {
                finish = YES;
            }
            pthread_mutex_unlock(&_lock);
        } else {
            usleep(10 * 1000); //10 ms
        }
    }
    if (holder.count) {
        dispatch_queue_t queue = _lru->_releaseOnMainThread ? dispatch_get_main_queue() : MemeryCacheGetReleaseQueue();
        dispatch_async(queue, ^{
            [holder count]; // release in queue
        });
    }
}
- (void)_trimToCount:(NSUInteger)countLimit {
    BOOL finish = NO;
    pthread_mutex_lock(&_lock);
    if (countLimit == 0) {
        [_lru removeAll];
        finish = YES;
    } else if (_lru->_totalCount <= countLimit) {
        finish = YES;
    }
    pthread_mutex_unlock(&_lock);
    if (finish) return;
    
    NSMutableArray *holder = [NSMutableArray new];
    while (!finish) {
        if (pthread_mutex_trylock(&_lock) == 0) {
            if (_lru->_totalCount > countLimit) {
                MemeryCacheMapNode *node = [_lru removeTailNode];
                if (node) [holder addObject:node];
            } else {
                finish = YES;
            }
            pthread_mutex_unlock(&_lock);
        } else {
            usleep(10 * 1000); //10 ms
        }
    }
    if (holder.count) {
        dispatch_queue_t queue = _lru->_releaseOnMainThread ? dispatch_get_main_queue() : MemeryCacheGetReleaseQueue();
        dispatch_async(queue, ^{
            [holder count]; // release in queue
        });
    }
}
- (void)_trimToAge:(NSTimeInterval)ageLimit {
    BOOL finish = NO;
    NSTimeInterval now = CACurrentMediaTime();
    pthread_mutex_lock(&_lock);
    if (ageLimit <= 0) {
        [_lru removeAll];
        finish = YES;
    } else if (!_lru->_tail || (now - _lru->_tail->_time) <= ageLimit) {
        finish = YES;
    }
    pthread_mutex_unlock(&_lock);
    if (finish) return;
    
    NSMutableArray *holder = [NSMutableArray new];
    while (!finish) {
        if (pthread_mutex_trylock(&_lock) == 0) {
            if (_lru->_tail && (now - _lru->_tail->_time) > ageLimit) {
                MemeryCacheMapNode *node = [_lru removeTailNode];
                if (node) [holder addObject:node];
            } else {
                finish = YES;
            }
            pthread_mutex_unlock(&_lock);
        } else {
            usleep(10 * 1000); //10 ms
        }
    }
    if (holder.count) {
        dispatch_queue_t queue = _lru->_releaseOnMainThread ? dispatch_get_main_queue() : MemeryCacheGetReleaseQueue();
        dispatch_async(queue, ^{
            [holder count]; // release in queue
        });
    }
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [_lru removeAll];
    pthread_mutex_destroy(&_lock);
}

- (NSUInteger)totalCount {
    pthread_mutex_lock(&_lock);
    NSUInteger count = _lru->_totalCount;
    pthread_mutex_unlock(&_lock);
    return count;
}

- (NSUInteger)totalCost {
    pthread_mutex_lock(&_lock);
    NSUInteger totalCost = _lru->_totalCost;
    pthread_mutex_unlock(&_lock);
    return totalCost;
}

- (BOOL)releaseOnMainThread {
    pthread_mutex_lock(&_lock);
    BOOL releaseOnMainThread = _lru->_releaseOnMainThread;
    pthread_mutex_unlock(&_lock);
    return releaseOnMainThread;
}

- (void)setReleaseOnMainThread:(BOOL)releaseOnMainThread {
    pthread_mutex_lock(&_lock);
    _lru->_releaseOnMainThread = releaseOnMainThread;
    pthread_mutex_unlock(&_lock);
}

- (BOOL)releaseAsynchronously {
    pthread_mutex_lock(&_lock);
    BOOL releaseAsynchronously = _lru->_releaseAsynchronously;
    pthread_mutex_unlock(&_lock);
    return releaseAsynchronously;
}

- (void)setReleaseAsynchronously:(BOOL)releaseAsynchronously {
    pthread_mutex_lock(&_lock);
    _lru->_releaseAsynchronously = releaseAsynchronously;
    pthread_mutex_unlock(&_lock);
}
- (void)trimToCost:(NSUInteger)costList{
    BOOL isFinish = NO;
    pthread_mutex_lock(&_lock);
    if (costList == 0) {
        [_lru removeAll];
        isFinish = YES;
    }else if (costList >= _lru->_totalCost){
        isFinish = YES;
    }
    pthread_mutex_unlock(&_lock);
    if (isFinish) return;
    
    NSMutableArray *holder = [NSMutableArray new];
    while (!isFinish) {
        if (pthread_mutex_trylock(&_lock)) {
            if (_lru->_totalCost > costList) {
                MemeryCacheMapNode *lastNode = [_lru removeTailNode];
                if (lastNode) [holder addObject:lastNode];
            }else{
                isFinish = YES;
            }
            pthread_mutex_unlock(&_lock);
        }else{
            usleep(10 * 1000);
        }
    }
    ///释放
    if (holder.count) {
        dispatch_queue_t queue = _lru->_releaseOnMainThread ? dispatch_get_main_queue() : MemeryCacheGetReleaseQueue();
        dispatch_async(queue, ^{
            [holder class];
        });
    }
}
- (void)trimToCount:(NSUInteger)countList{
    BOOL isFinish = NO;
    pthread_mutex_lock(&_lock);
    if (countList == 0) {
        [_lru removeAll];
        isFinish = YES;
    }else if (countList > _lru->_totalCount){
        isFinish = YES;
    }
    pthread_mutex_unlock(&_lock);
    if (isFinish) return;
    NSMutableArray *holder = [NSMutableArray new];
    while (!isFinish) {
        if (pthread_mutex_trylock(&_lock)) {
            if (_lru->_totalCount > countList) {
                MemeryCacheMapNode *lastNode = [_lru removeTailNode];
                if (lastNode) [holder addObject:lastNode];
            }else{
                isFinish = YES;
            }
            pthread_mutex_unlock(&_lock);
        }else{
            usleep(10 * 1000);
        }
    }
    //释放
    if (holder.count) {
        dispatch_queue_t queue = _lru->_releaseOnMainThread ? dispatch_get_main_queue() : MemeryCacheGetReleaseQueue();
        dispatch_async(queue, ^{
            [holder class];
        });
    }
}
- (void)trimToAhge:(NSTimeInterval)ageList{
    BOOL isFinish = NO;
    NSTimeInterval now = CACurrentMediaTime();
    pthread_mutex_lock(&_lock);
    if (ageList <= 0) {
        [_lru removeAll];
        isFinish = YES;
    }else if (!_lru->_tail || (now - _lru->_tail->_time) <= ageList){
        isFinish = YES;
    }
    pthread_mutex_unlock(&_lock);
    NSMutableArray *holder = [NSMutableArray new];
    while (!isFinish) {
        if (pthread_mutex_trylock(&_lock)) {
            if (_lru->_tail && (now - _lru->_tail->_time) > ageList) {
                MemeryCacheMapNode *lastNode = [_lru removeTailNode];
                if (lastNode) [holder addObject:lastNode];
            }else{
                isFinish = YES;
            }
            pthread_mutex_unlock(&_lock);
        }else{
            usleep(10 * 1000);
        }
    }
    //释放
    if (holder.count){
        dispatch_queue_t queue = _lru->_releaseOnMainThread ? dispatch_get_main_queue() : MemeryCacheGetReleaseQueue();
        dispatch_async(queue, ^{
            [holder class];
        });
    }
}
- (void)appDidReceiveMemoryWarningNotificatio{
    if (self.shouldRemoveAllObjectsOnMemoryWarning) {
        [self removeAllObjects];
    }
    if (self.memeryWarningBlcok) {
        self.memeryWarningBlcok(self);
    }
}
- (void)appDidEnterBackgroundNotification{
    if (self.shouldRemoveAllObjectsWhenEnteringBackground){
       [self removeAllObjects];
    }
    if (self.enterBackGroundBlcok) {
        self.enterBackGroundBlcok(self);
    }
}
- (instancetype)init{
    self = [super init];
    pthread_mutex_init(&_lock, NULL);
    _lru = [MemeryCacheMap new];
    _queue = dispatch_queue_create("com.ibireme.cache.memory", DISPATCH_QUEUE_SERIAL);
    
    _countLimit = NSUIntegerMax;
    _costLimit = NSUIntegerMax;
    _ageLimit = DBL_MAX;
    _autoTrimInterval = 5.0;
    _shouldRemoveAllObjectsOnMemoryWarning = YES;
    _shouldRemoveAllObjectsWhenEnteringBackground = YES;
    ///内存警告通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidReceiveMemoryWarningNotificatio) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    ///进入后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
    return self;
}
- (void)removeAllObjects {
    pthread_mutex_lock(&_lock);
    [_lru removeAll];
    pthread_mutex_unlock(&_lock);
}


- (BOOL)containsObjectForKey:(id)key {
    if (!key) return NO;
    pthread_mutex_lock(&_lock);
    BOOL contains = CFDictionaryContainsKey(_lru->_dic, (__bridge const void *)(key));
    pthread_mutex_unlock(&_lock);
    return contains;
}
- (id)objectForKey:(id)key {
    if (!key) return nil;
    pthread_mutex_lock(&_lock);
    MemeryCacheMapNode *node = CFDictionaryGetValue(_lru->_dic, (__bridge const void *)(key));
    if (node) {
        node->_time = CACurrentMediaTime();
        [_lru bringNodeAtHead:node];
    }
    pthread_mutex_unlock(&_lock);
    return node ? node->_value : nil;
}
- (void)setObject:(id)object forKey:(id)key {
    [self setObject:object forKey:key withCost:0];
}
- (void)setObject:(id)object forKey:(id)key withCost:(NSUInteger)cost {
    if (!key) return;
    if (!object) {
        [self removeObjectForKey:key];
        return;
    }
    pthread_mutex_lock(&_lock);
    MemeryCacheMapNode *node = CFDictionaryGetValue(_lru->_dic, (__bridge const void *)(key));
    NSTimeInterval now = CACurrentMediaTime();
    if (node) {
        _lru->_totalCost -= node->_cost;
        _lru->_totalCost += cost;
        node->_cost = cost;
        node->_time = now;
        node->_value = object;
        [_lru bringNodeAtHead:node];
    } else {
        node = [MemeryCacheMapNode new];
        node->_cost = cost;
        node->_time = now;
        node->_key = key;
        node->_value = object;
        [_lru insertNodeAtHead:node];
    }
    if (_lru->_totalCost > _costLimit) {
        dispatch_async(_queue, ^{
            [self trimToCost:self->_costLimit];
        });
    }
    if (_lru->_totalCount > _countLimit) {
        MemeryCacheMapNode *node = [_lru removeTailNode];
        if (_lru->_releaseAsynchronously) {
            dispatch_queue_t queue = _lru->_releaseOnMainThread ? dispatch_get_main_queue() : MemeryCacheGetReleaseQueue();
            dispatch_async(queue, ^{
                [node class]; //hold and release in queue
            });
        } else if (_lru->_releaseOnMainThread && !pthread_main_np()) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [node class]; //hold and release in queue
            });
        }
    }
    pthread_mutex_unlock(&_lock);
}
- (void)removeObjectForKey:(id)key {
    if (!key) return;
    pthread_mutex_lock(&_lock);
    MemeryCacheMapNode *node = CFDictionaryGetValue(_lru->_dic, (__bridge const void *)(key));
    if (node) {
        [_lru removeNode:node];
        if (_lru->_releaseAsynchronously) {
            dispatch_queue_t queue = _lru->_releaseOnMainThread ? dispatch_get_main_queue() : MemeryCacheGetReleaseQueue();
            dispatch_async(queue, ^{
                [node class]; //hold and release in queue
            });
        } else if (_lru->_releaseOnMainThread && !pthread_main_np()) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [node class]; //hold and release in queue
            });
        }
    }
    pthread_mutex_unlock(&_lock);
}
- (void)trimToAge:(NSTimeInterval)age {
    [self _trimToAge:age];
}

- (NSString *)description {
    if (_name) return [NSString stringWithFormat:@"<%@: %p> (%@)", self.class, self, _name];
    else return [NSString stringWithFormat:@"<%@: %p>", self.class, self];
}


+ (void)dispatchTest{
  
}
@end
