//
//  Global.h
//  YYKitStudy
//
//  Created by GoodSrc on 2017/11/22.
//  Copyright © 2017年 GoodSrc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sys/time.h>
#import <pthread.h>

#ifndef Global_h
#define Global_h


////__cplusplus 表示 c++ 中的宏定义 如果是 c 或者c++ 调用  YYSS_EXTERN_C_BEGIN  YYSS_EXTERN_C_END 之间的代码  就会添加   extern "C"{}   代码来兼容 c 或者c++    否则什么都没有
 

#ifdef __cplusplus
#define YYSS_EXTERN_C_BEGIN  extern "C" {
#define YYSS_EXTERN_C_END  }
#else
#define YYSS_EXTERN_C_BEGIN
#define YYSS_EXTERN_C_END

#endif


YYSS_EXTERN_C_BEGIN

//返回 _low_  <=  &&  <= _high_   区间之内
#ifndef YYSS_CLAMP
#define YYSS_CLAMP(_x_, _low_, _high_)  (((_x_) > (_high_)) ? (_high_) : (((_x_) < (_low_)) ? (_low_) : (_x_)))
#endif


////交换_a_  ,_b_ 的值
#ifndef YYSS_SWAP
#define YYSS_SWAP(_a_,_b_)    do { __typeof__(_a_) _tmp_ = (_a_);(_a_) = (_b_);(_b_) = _tmp_;} while (0);
#endif

/////nil 断言
#define YYSSAssertNil(condition, description, ...) NSAssert(!(condition), (description), ##__VA_ARGS__)
/////not nil 断言
#define YYSSAssertNotNil(condition, description, ...) NSAssert((condition), (description), ##__VA_ARGS__)
///主线程断言
#define YYSSAssertMainThread() NSAssert([NSThread isMainThread], @"This method must be called on the main thread")

////防止调用categary 方法的奔溃   （.a）为静态文件中的类添加类别时 （没有添加 other link falgs  '-Objc_all_load'） 找不到方法  奔溃
#ifndef YYSSSYNTH_DUMMY_CLASS
#define YYSSSYNTH_DUMMY_CLASS(_name_) \
@interface YYSSSYNTH_DUMMY_CLASS ## _name_ : NSObject @end \
@implementation YYSSSYNTH_DUMMY_CLASS ## _name_ @end
#endif



 /*
  在类目中动态的给类添加属性

  //// @# 是把变量名转成字符串
  /// ## 是替换   def(n) ##n     --> ## 替换成##n 替换成n
  @warning #import <objc/runtime.h>
  */

#ifndef YYSYNTH_DYNAMIC_PROPERTY_OBJECT
#define YYSYNTH_DYNAMIC_PROPERTY_OBJECT(_getter_, _setter_, _association_, _type_) \
- (void)_setter_ : (_type_)object { \
    [self willChangeValueForKey:@#_getter_]; \
    objc_setAssociatedObject(self, _cmd, object, OBJC_ASSOCIATION_ ## _association_); \
    [self didChangeValueForKey:@#_getter_]; \
    } \
- (_type_)_getter_ { \
    return objc_getAssociatedObject(self, @selector(_setter_:)); \
}
#endif


#ifndef YYSSSYNTH_DYNAMIC_PROPERTY_CTYPE

#define YYSSSYNTH_DYNAMIC_PROPERTY_CTYPE(_getter_,_setter,_association_,_type_)\
- (void)_setter_:(_type_)object{\
[self willChangeValueForKey:@#_getter_];\
NSValue *value = [NSValue value:&object withObjCType:@encode(_type_)]; \
objc_setAssociatedObject(self, _cmd, value, OBJC_ASSOCIATION_RETAIN); \
[self didChangeValueForKey:@#_getter_]; \
}\
- (_type_)_getter_ { \
_type_ cValue = { 0 }; \
NSValue *value = objc_getAssociatedObject(self, @selector(_setter_:)); \
[value getValue:&cValue]; \
return cValue; \
}

#endif

#ifndef YY_SWAP // swap two value
#define YY_SWAP(_a_, _b_)  do { __typeof__(_a_) _tmp_ = (_a_); (_a_) = (_b_); (_b_) = _tmp_; } while (0)
#endif



#ifndef weakify
#if DEBUG
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif


/**
 Convert CFRange to NSRange
 @param range CFRange @return NSRange
 */
static inline NSRange YYNSRangeFromCFRange(CFRange range) {
    return NSMakeRange(range.location, range.length);
}

/**
 Convert NSRange to CFRange
 @param range NSRange @return CFRange
 */
static inline CFRange YYCFRangeFromNSRange(NSRange range) {
    return CFRangeMake(range.location, range.length);
}

/**
 ？？？？？？ 
 Same as CFAutorelease(), compatible for iOS6
 @param arg CFObject @return same as input
 */
static inline CFTypeRef YYCFAutorelease(CFTypeRef CF_RELEASES_ARGUMENT arg) {
    if (((long)CFAutorelease + 1) != 1) {
        return CFAutorelease(arg);
    } else {
        id __autoreleasing obj = CFBridgingRelease(arg);
        return (__bridge CFTypeRef)obj;
    }
}


/**
 计算block 中的运行时间
 
 @param block      执行的任务 执行的时间  毫秒
 
 */
static inline void YYBenchmark(void (^block)(void), void (^complete)(double ms)) {
    struct timeval t0, t1;
    gettimeofday(&t0, NULL);
    block();
    gettimeofday(&t1, NULL);
    double ms = (double)(t1.tv_sec - t0.tv_sec) * 1e3 + (double)(t1.tv_usec - t0.tv_usec) * 1e-3;
    complete(ms);
}




//static inline NSDate *_YYCompileTime(const char *data, const char *time) {
//    NSString *timeStr = [NSString stringWithFormat:@"%s %s",data,time];
//    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"MMM dd yyyy HH:mm:ss"];
//    [formatter setLocale:locale];
//    return [formatter dateFromString:timeStr];
//}

/**
 Returns a dispatch_time delay from now.
 */
static inline dispatch_time_t dispatch_time_delay(NSTimeInterval second) {
    return dispatch_time(DISPATCH_TIME_NOW, (int64_t)(second * NSEC_PER_SEC));
}

/**
 Returns a dispatch_wall_time delay from now.
 */
static inline dispatch_time_t dispatch_walltime_delay(NSTimeInterval second) {
    return dispatch_walltime(DISPATCH_TIME_NOW, (int64_t)(second * NSEC_PER_SEC));
}



/**
 Returns a dispatch_wall_time from NSDate.
 */
static inline dispatch_time_t dispatch_walltime_date(NSDate *date) {
    NSTimeInterval interval;
    double second, subsecond;
    struct timespec time;
    dispatch_time_t milestone;
    
    interval = [date timeIntervalSince1970];
    subsecond = modf(interval, &second);
    time.tv_sec = second;
    time.tv_nsec = subsecond * NSEC_PER_SEC;
    milestone = dispatch_walltime(&time, 0);
    return milestone;
}

/**
 Whether in main queue/thread.
 */
static inline bool dispatch_is_main_queue() {
    return pthread_main_np() != 0;
}

/**
 Submits a block for asynchronous execution on a main queue and returns immediately.
 */
static inline void dispatch_async_on_main_queue(void (^block)(void)) {
    dispatch_async(dispatch_get_main_queue(), block);
}
/**
 Submits a block for execution on a main queue and waits until the block completes.
 */
static inline void dispatch_sync_on_main_queue(void (^block)(void)) {
    if (pthread_main_np()) {
        block();
    } else {
//        dispatch_sync(dispatch_get_main_queue(), block);
    }
    
}

YYSS_EXTERN_C_END


#endif /* Global_h */
