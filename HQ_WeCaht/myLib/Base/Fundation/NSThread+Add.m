//
//  NSThread+Add.m
//  YYKitStudy
//
//  Created by GoodSrc on 2017/12/12.
//  Copyright © 2017年 GoodSrc. All rights reserved.
//

#import "NSThread+Add.h"
#import <CoreFoundation/CoreFoundation.h>
#import "Global.h"



@interface NSThread_YYAdd : NSObject @end
@implementation NSThread_YYAdd @end

#if __has_feature(objc_arc)
#error This file must be compiled without ARC. Specify the -fno-objc-arc flag to this file.
#endif


static NSString *const YYNSThreadAutoleasePoolKey = @"YYNSThreadAutoleasePoolKey";
static NSString *const YYNSThreadAutoleasePoolStackKey = @"YYNSThreadAutoleasePoolStackKey";


static const void *PoolStackRetainCallBack(CFAllocatorRef allocator, const void *value) {
    return value;
}

static void PoolStackReleaseCallBack(CFAllocatorRef allocator, const void *value) {
    CFRelease((CFTypeRef)value);
}

static inline void YYAutoreleasePoolPush() {
    NSMutableDictionary *dic =  [NSThread currentThread].threadDictionary;
    NSMutableArray *poolStack = dic[YYNSThreadAutoleasePoolStackKey];
    
    if (!poolStack) {
        /*
         do not retain pool on push,
         but release on pop to avoid memory analyze warning
         */
        CFArrayCallBacks callbacks = {0};
        callbacks.retain = PoolStackRetainCallBack;
        callbacks.release = PoolStackReleaseCallBack;
        poolStack = (id)CFBridgingRelease(CFArrayCreateMutable(CFAllocatorGetDefault(), 0, &callbacks));
        dic[YYNSThreadAutoleasePoolStackKey] = poolStack;
        CFRelease((__bridge CFTypeRef)(poolStack));
    }
   NSAutoreleasePool *pool =  [[NSAutoreleasePool alloc] init];
    [poolStack addObject:pool]; // push
}
static inline void YYAutoreleasePoolPop() {
    NSMutableDictionary *dic =  [NSThread currentThread].threadDictionary;
    NSMutableArray *poolStack = dic[YYNSThreadAutoleasePoolStackKey];
    [poolStack removeLastObject]; // pop
}

static void YYRunLoopAutoreleasePoolObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    switch (activity) {
        case kCFRunLoopEntry: {
            YYAutoreleasePoolPush();
        } break;
        case kCFRunLoopBeforeWaiting: {
            YYAutoreleasePoolPop();
            YYAutoreleasePoolPush();
        } break;
        case kCFRunLoopExit: {
            YYAutoreleasePoolPop();
        } break;
        default: break;
    }
}
static void YYRunloopAutoreleasePoolSetup() {
    CFRunLoopRef runloop = CFRunLoopGetCurrent();
    
    CFRunLoopObserverRef pushObserver;
    pushObserver = CFRunLoopObserverCreate(CFAllocatorGetDefault(), kCFRunLoopEntry,
                                           true,         // repeat
                                           -0x7FFFFFFF,  // before other observers
                                           YYRunLoopAutoreleasePoolObserverCallBack, NULL);
    CFRunLoopAddObserver(runloop, pushObserver, kCFRunLoopCommonModes);
    CFRelease(pushObserver);
    
    CFRunLoopObserverRef popObserver;
    popObserver = CFRunLoopObserverCreate(CFAllocatorGetDefault(), kCFRunLoopBeforeWaiting | kCFRunLoopExit,
                                          true,        // repeat
                                          0x7FFFFFFF,  // after other observers
                                          YYRunLoopAutoreleasePoolObserverCallBack, NULL);
    CFRunLoopAddObserver(runloop, popObserver, kCFRunLoopCommonModes);
    CFRelease(popObserver);
}


@implementation NSThread (Add)

+ (void)addAutoreleasePoolToCurrentRunloop {
    if ([NSThread isMainThread]) return; // The main thread already has autorelease pool.
    NSThread *thread = [self currentThread];
    if (!thread) return;
    if (thread.threadDictionary[YYNSThreadAutoleasePoolKey]) return; // already added
    YYRunloopAutoreleasePoolSetup();
    thread.threadDictionary[YYNSThreadAutoleasePoolKey] = YYNSThreadAutoleasePoolKey; // mark the state
}


@end
