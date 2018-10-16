//
//  TextDebugOption.m
//  YYStudyDemo
//
//  Created by hqz on 2018/9/3.
//  Copyright © 2018年 hqz. All rights reserved.
//

#import "TextDebugOption.h"
#import <CoreFoundation/CoreFoundation.h>
#import <pthread.h>


static pthread_mutex_t _sharedDebugLock;
static CFMutableSetRef _sharedDebugTargets = nil;
static TextDebugOption *_sharedDebugOption = nil;


static const void* _sharedDebugSetRetain(CFAllocatorRef allocator, const void *value) {
    return value;
}

static void _sharedDebugSetRelease(CFAllocatorRef allocator, const void *value) {
}
///set 添加元素的时候调用此方法
void _sharedDebugSetFunction(const void *value, void *context) {
    id<TextDebugTarget> target = (__bridge id<TextDebugTarget>)(value);
    [target setDebugOption:_sharedDebugOption];
}

static void _initShareDebug(){
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pthread_mutex_init(&_sharedDebugLock, NULL);
        CFSetCallBacks callback = kCFTypeSetCallBacks;
        callback.retain = _sharedDebugSetRetain;
        callback.release = _sharedDebugSetRelease;
        _sharedDebugTargets = CFSetCreateMutable(CFAllocatorGetDefault(), 0, &callback);
    });
}
static void _setSharedOptionDebug(TextDebugOption *option){
    _initShareDebug();
    pthread_mutex_lock(&_sharedDebugLock);
    _sharedDebugOption = option.copy;
    CFSetApplyFunction(_sharedDebugTargets, _sharedDebugSetFunction, NULL);
    pthread_mutex_unlock(&_sharedDebugLock);
}

static TextDebugOption * _getSharedOptionDebug(){
    _initShareDebug();
    pthread_mutex_lock(&_sharedDebugLock);
    TextDebugOption *op = _sharedDebugOption;
    pthread_mutex_unlock(&_sharedDebugLock);
    return op;
}

static void _addShareOptionDebug(id<TextDebugTarget> target){
    _initShareDebug();
    pthread_mutex_lock(&_sharedDebugLock);
    CFSetAddValue(_sharedDebugTargets, (__bridge const void *)(target));
    pthread_mutex_unlock(&_sharedDebugLock);
}
static void _removeShareOptionDebug(id <TextDebugTarget> target){
    _initShareDebug();
    pthread_mutex_lock(&_sharedDebugLock);
    CFSetRemoveValue(_sharedDebugTargets, (__bridge const void *) target);
    pthread_mutex_unlock(&_sharedDebugLock);
}

@implementation TextDebugOption
- (instancetype)copyWithZone:(NSZone *)zone{
    TextDebugOption *op = [self.class new];
    op.baselineColor = self.baselineColor;
    op.CTFrameBorderColor = self.CTFrameBorderColor;
    op.CTFrameFillColor = self.CTFrameFillColor;
    op.CTLineBorderColor = self.CTLineBorderColor;
    op.CTLineFillColor = self.CTLineFillColor;
    op.CTLineNumberColor = self.CTLineNumberColor;
    op.CTRunBorderColor = self.CTRunBorderColor;
    op.CTRunFillColor = self.CTRunFillColor;
    op.CTRunNumberColor = self.CTRunNumberColor;
    op.CGGlyphBorderColor = self.CGGlyphBorderColor;
    op.CGGlyphFillColor = self.CGGlyphFillColor;
    return op;
}
- (BOOL)needDrawDebug{
    if (self.baselineColor ||
        self.CTFrameBorderColor ||
        self.CTFrameFillColor ||
        self.CTLineBorderColor ||
        self.CTLineFillColor ||
        self.CTLineNumberColor ||
        self.CTRunBorderColor ||
        self.CTRunFillColor ||
        self.CTRunNumberColor ||
        self.CGGlyphBorderColor ||
        self.CGGlyphFillColor) return YES;
    return NO;
}
- (void)clear{
    self.baselineColor = nil;
    self.CTFrameBorderColor = nil;
    self.CTFrameFillColor = nil;
    self.CTLineBorderColor = nil;
    self.CTLineFillColor = nil;
    self.CTLineNumberColor = nil;
    self.CTRunBorderColor = nil;
    self.CTRunFillColor = nil;
    self.CTRunNumberColor = nil;
    self.CGGlyphBorderColor = nil;
    self.CGGlyphFillColor = nil;
}
+ (void)addDebugTarget:(id<TextDebugTarget>)target{
    if(target) _addShareOptionDebug(target);
}
+ (void)removeDebugTarget:(id<TextDebugTarget>)target{
    if(target) _removeShareOptionDebug(target);
}
+ (nullable TextDebugOption *)sharedDebugOption{
    return _getSharedOptionDebug();
}
+ (void)setSharedDebugOption:(nullable TextDebugOption *)option{
    NSAssert([NSThread mainThread], @"This method must be called on the main thread");
   if(option) _setSharedOptionDebug(option);
}
@end
