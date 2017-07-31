//
//  HQWiFiTools.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/5/19.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HQWiFi : NSObject

@property (nonatomic, copy, readonly, nullable)NSString *wifiName;
@property (nonatomic, copy, readonly, nullable)NSString *wifiBSSID;

- (nonnull instancetype)initWithName:(nullable NSString *)name BSSID:(nullable NSString *)bssid;


@end


@interface HQWiFiTools : NSObject

/**
 The shared default instance of `MCWiFiManager` initialized with default values.
 */
+ (nonnull instancetype)defaultInstance;

/**
 Default initializer
 
 @return An instance of `MCWiFiManager` initialized with default values.
 */
- (nonnull instancetype)init;


- (void)scanNetworksWithCompletionHandler:(void(^_Nullable)(NSArray <HQWiFi *>* _Nullable networks, HQWiFi *_Nullable currentWiFi, NSError *_Nullable error))handler;


- (nullable NSString *)getGatewayIpForCurrentWiFi;

/**
 *  Get the local info for currentWifi except for GatewayIp
 *
 *  @return NSDictionary
 *  {
 broadcast = "192.168.8.233";
 interface = en0;
 localIp = "192.168.5.140";
 netmask = "255.255.255.0";
 }
 */
- (nullable NSDictionary *)getLocalInfoForCurrentWiFi;


@end
