//
//  ReachabilityManager.m
//  AFDemo
//
//  Created by hqz on 2018/11/7.
//  Copyright © 2018年 8km. All rights reserved.
//

#import "ReachabilityManager.h"
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>


NSString * const NetworkingReachabilityDidChangeNotification = @"com.alamofire.networking.reachability.change";
NSString * const NetworkingReachabilityNotificationStatusItem = @"AFNetworkingReachabilityNotificationStatusItem";

typedef void (^NetworkReachabilityStatusBlock)(NetworkReachabilityStatus status);

NSString * StringFromNetworkReachabilityStatus(NetworkReachabilityStatus status) {
    switch (status) {
        case NetworkReachabilityStatusNotReachable:
            return NSLocalizedStringFromTable(@"Not Reachable", @"networking", nil);
        case NetworkReachabilityStatusReachableViaWWAN:
            return NSLocalizedStringFromTable(@"Reachable via WWAN", @"networking", nil);
        case NetworkReachabilityStatusReachableViaWiFi:
            return NSLocalizedStringFromTable(@"Reachable via WiFi", @"networking", nil);
        case NetworkReachabilityStatusUnknown:
        default:
            return NSLocalizedStringFromTable(@"Unknown", @"networking", nil);
    }
}
static NetworkReachabilityStatus NetworkReachabilityStatusForFlags(SCNetworkReachabilityFlags flags) {
    BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
    BOOL canConnectionAutomatically = (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) || ((flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0));
    BOOL canConnectWithoutUserInteraction = (canConnectionAutomatically && (flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0);
    BOOL isNetworkReachable = (isReachable && (!needsConnection || canConnectWithoutUserInteraction));
    
    NetworkReachabilityStatus status = NetworkReachabilityStatusUnknown;
    if (isNetworkReachable == NO) {
        status = NetworkReachabilityStatusNotReachable;
    }
#if    TARGET_OS_IPHONE
    else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
        status = NetworkReachabilityStatusReachableViaWWAN;
    }
#endif
    else {
        status = NetworkReachabilityStatusReachableViaWiFi;
    }
    
    return status;
}
///网络状态改变回调
static void PostReachabilityStatusChange(SCNetworkReachabilityFlags flags, NetworkReachabilityStatusBlock block) {
    NetworkReachabilityStatus status = NetworkReachabilityStatusForFlags(flags);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (block) {
            block(status);
        }
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        NSDictionary *userInfo = @{ NetworkingReachabilityNotificationStatusItem: @(status) };
        [notificationCenter postNotificationName:NetworkingReachabilityDidChangeNotification object:nil userInfo:userInfo];
    });
}
///注册的网络状态改变的回调
static void NetworkReachabilityCallback(SCNetworkReachabilityRef __unused target, SCNetworkReachabilityFlags flags, void *info) {
    PostReachabilityStatusChange(flags, (__bridge
       NetworkReachabilityStatusBlock)info);
}
///retain 回调
static const void * NetworkReachabilityRetainCallback(const void *info) {
    return Block_copy(info);
}
///release 回调
static void NetworkReachabilityReleaseCallback(const void *info) {
    if (info) {
        Block_release(info);
    }
}

@interface ReachabilityManager ()

@property (readonly, nonatomic, assign) SCNetworkReachabilityRef networkReachability;
@property (readwrite, nonatomic, assign) NetworkReachabilityStatus networkReachabilityStatus;
@property (readwrite, nonatomic, copy) NetworkReachabilityStatusBlock networkReachabilityStatusBlock;

@end

@implementation ReachabilityManager

+ (instancetype)sharedManager {
    static ReachabilityManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [self manager];
    });
    
    return _sharedManager;
}
+ (instancetype)managerForDomain:(NSString *)domain {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [domain UTF8String]);
    
    ReachabilityManager *manager = [[self alloc] initWithReachability:reachability];
    
    CFRelease(reachability);
    
    return manager;
}
+ (instancetype)managerForAddress:(const void *)address {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)address);
    ReachabilityManager *manager = [[self alloc] initWithReachability:reachability];
    
    CFRelease(reachability);
    
    return manager;
}
+ (instancetype)manager
{
#if (defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED >= 90000) || (defined(__MAC_OS_X_VERSION_MIN_REQUIRED) && __MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
    struct sockaddr_in6 address;
    bzero(&address, sizeof(address));
    address.sin6_len = sizeof(address);
    address.sin6_family = AF_INET6;
#else
    struct sockaddr_in address;
    bzero(&address, sizeof(address));
    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;
#endif
    return [self managerForAddress:&address];
}
- (instancetype)initWithReachability:(SCNetworkReachabilityRef)reachability {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _networkReachability = CFRetain(reachability);
    self.networkReachabilityStatus = NetworkReachabilityStatusUnknown;
    
    return self;
}
- (instancetype)init NS_UNAVAILABLE
{
    return nil;
}

- (void)dealloc {
    [self stopMonitoring];
    
    if (_networkReachability != NULL) {
        CFRelease(_networkReachability);
    }
}
#pragma mark -

- (BOOL)isReachable {
    return [self isReachableViaWWAN] || [self isReachableViaWiFi];
}

- (BOOL)isReachableViaWWAN {
    return self.networkReachabilityStatus == NetworkReachabilityStatusReachableViaWWAN;
}

- (BOOL)isReachableViaWiFi {
    return self.networkReachabilityStatus == NetworkReachabilityStatusReachableViaWiFi;
}
- (void)startMonitoring {
    [self stopMonitoring];
    
    if (!self.networkReachability) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    NetworkReachabilityStatusBlock block = ^(NetworkReachabilityStatus status){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.networkReachabilityStatus = status;
        if (strongSelf.networkReachabilityStatusBlock) {
            strongSelf.networkReachabilityStatusBlock(status);
        }
    };
    
    SCNetworkReachabilityContext context = {0,(__bridge void * _Nullable)(block),NetworkReachabilityRetainCallback,NetworkReachabilityReleaseCallback,NULL};
   ///设置监听的回调
    SCNetworkReachabilitySetCallback(self.networkReachability, NetworkReachabilityCallback, &context);
    ///开始监听
    SCNetworkReachabilityScheduleWithRunLoop(self.networkReachability, CFRunLoopGetMain(), kCFRunLoopDefaultMode);
    
    ///获取标记
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        SCNetworkConnectionFlags flag;
        if (SCNetworkReachabilityGetFlags(self.networkReachability, &flag)) {
            PostReachabilityStatusChange(flag,block);
        }
        
    });
}
///停止监听 网络变化
- (void)stopMonitoring {
    if (!self.networkReachability) {
        return;
    }
    SCNetworkReachabilityUnscheduleFromRunLoop(self.networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
}
///字符串表示 网络状态
- (NSString *)localizedNetworkReachabilityStatusString {
    return StringFromNetworkReachabilityStatus(self.networkReachabilityStatus);
}
///设置回调 block
- (void)setReachabilityStatusChangeBlock:(void (^)(NetworkReachabilityStatus status))block {
    self.networkReachabilityStatusBlock = block;
}
#pragma mark - NSKeyValueObserving
///让kvo 只能监听 属性 networkReachabilityStatus
+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    if ([key isEqualToString:@"reachable"] || [key isEqualToString:@"reachableViaWWAN"] || [key isEqualToString:@"reachableViaWiFi"]) {
        return [NSSet setWithObject:@"networkReachabilityStatus"];
    }
    
    return [super keyPathsForValuesAffectingValueForKey:key];
}

@end
