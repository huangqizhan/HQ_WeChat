//
//  ReachabilityManager.h
//  AFDemo
//
//  Created by hqz on 2018/11/7.
//  Copyright © 2018年 8km. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>


typedef NS_ENUM(NSInteger, NetworkReachabilityStatus) {
    ///未知
    NetworkReachabilityStatusUnknown          = -1,
    ///没有联网
    NetworkReachabilityStatusNotReachable     = 0,
    ///无线广域网 (2,3,4) G
    NetworkReachabilityStatusReachableViaWWAN = 1,
    ///无线局域网
    NetworkReachabilityStatusReachableViaWiFi = 2,
};
/// 网络变化通知
FOUNDATION_EXPORT NSString * const NetworkingReachabilityDidChangeNotification;
/// 网络变化状态
FOUNDATION_EXPORT NSString * const NetworkingReachabilityNotificationStatusItem;

FOUNDATION_EXPORT NSString * StringFromNetworkReachabilityStatus(NetworkReachabilityStatus status);

NS_ASSUME_NONNULL_BEGIN

@interface ReachabilityManager : NSObject

///网络状态
@property (readonly, nonatomic, assign) NetworkReachabilityStatus networkReachabilityStatus;
///是否联网
@property (readonly, nonatomic, assign, getter = isReachable) BOOL reachable;
///是否wwan
@property (readonly, nonatomic, assign, getter = isReachableViaWWAN) BOOL reachableViaWWAN;
///是否是wifi
@property (readonly, nonatomic, assign, getter = isReachableViaWiFi) BOOL reachableViaWiFi;

+ (instancetype)sharedManager;

+ (instancetype)manager;

///域名
+ (instancetype)managerForDomain:(NSString *)domain;
/**
 Creates and returns a network reachability manager for the socket address.
 
 @param address The socket address (`sockaddr_in6`) used to evaluate network reachability.
 
 @return An initialized network reachability manager, actively monitoring the specified socket address.
 */
+ (instancetype)managerForAddress:(const void *)address;


- (instancetype)initWithReachability:(SCNetworkReachabilityRef)reachability NS_DESIGNATED_INITIALIZER;

///开始检测
- (void)startMonitoring;

//停止检测
- (void)stopMonitoring;


- (NSString *)localizedNetworkReachabilityStatusString;

- (void)setReachabilityStatusChangeBlock:(nullable void (^)(NetworkReachabilityStatus status))block;


@end

NS_ASSUME_NONNULL_END
