//
//  UIDevice+Add.h
//  YYKitStudy
//
//  Created by GoodSrc on 2017/12/14.
//  Copyright © 2017年 GoodSrc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (Add)
///当前版本
+ (double)systemVersion;
///是否是pad设备
@property (nonatomic, readonly) BOOL isPad;
///是否是模拟器
@property (nonatomic, readonly) BOOL isSimulator;
///是否越狱
@property (nonatomic, readonly) BOOL isJailbroken;
///是否可以打电话
@property (nonatomic, readonly) BOOL canMakePhoneCalls NS_EXTENSION_UNAVAILABLE_IOS("");
///机器型号
@property (nullable, nonatomic, readonly) NSString *machineModel;
///机器名称
@property (nullable, nonatomic, readonly) NSString *machineModelName;
///启动时间
@property (nonatomic, readonly) NSDate *systemUptime;
///wifi 地址
@property (nullable, nonatomic, readonly) NSString *ipAddressWIFI;

@property (nullable, nonatomic, readonly) NSString *ipAddressCell;


typedef NS_OPTIONS(NSUInteger, YYNetworkTrafficType) {
    YYNetworkTrafficTypeWWANSent     = 1 << 0,
    YYNetworkTrafficTypeWWANReceived = 1 << 1,
    YYNetworkTrafficTypeWIFISent     = 1 << 2,
    YYNetworkTrafficTypeWIFIReceived = 1 << 3,
    YYNetworkTrafficTypeAWDLSent     = 1 << 4,
    YYNetworkTrafficTypeAWDLReceived = 1 << 5,
    
    YYNetworkTrafficTypeWWAN = YYNetworkTrafficTypeWWANSent | YYNetworkTrafficTypeWWANReceived,
    YYNetworkTrafficTypeWIFI = YYNetworkTrafficTypeWIFISent | YYNetworkTrafficTypeWIFIReceived,
    YYNetworkTrafficTypeAWDL = YYNetworkTrafficTypeAWDLSent | YYNetworkTrafficTypeAWDLReceived,
    
    YYNetworkTrafficTypeALL = YYNetworkTrafficTypeWWAN |
    YYNetworkTrafficTypeWIFI |
    YYNetworkTrafficTypeAWDL,
};
///设备传输的数据量
- (uint64_t)getNetworkTrafficBytes:(YYNetworkTrafficType)types;


/// 磁盘空间大小
@property (nonatomic, readonly) int64_t diskSpace;

/// 可使用的磁盘大小
@property (nonatomic, readonly) int64_t diskSpaceFree;

/// 已使用的磁盘
@property (nonatomic, readonly) int64_t diskSpaceUsed;

///设备运行内存
@property (nonatomic, readonly) int64_t memoryTotal;
//已用运行内存
@property (nonatomic, readonly) int64_t memoryUsed;
///可支配的内存
@property (nonatomic, readonly) int64_t memoryFree;
///当前应用可用内存
@property (nonatomic, readonly) int64_t memoryActive;

@property (nonatomic, readonly) int64_t memoryInactive;

@property (nonatomic, readonly) int64_t memoryWired;

@property (nonatomic, readonly) int64_t memoryPurgable;
///双核
@property (nonatomic, readonly) NSUInteger cpuCount;
///cpu 使用时间
@property (nonatomic, readonly) float cpuUsage;


@property (nullable, nonatomic, readonly) NSArray<NSNumber *> *cpuUsagePerProcessor;
@end

NS_ASSUME_NONNULL_END



#ifndef kSystemVersion
#define kSystemVersion [UIDevice systemVersion]
#endif

#ifndef kiOS6Later
#define kiOS6Later (kSystemVersion >= 6)
#endif

#ifndef kiOS7Later
#define kiOS7Later (kSystemVersion >= 7)
#endif

#ifndef kiOS8Later
#define kiOS8Later (kSystemVersion >= 8)
#endif

#ifndef kiOS9Later
#define kiOS9Later (kSystemVersion >= 9)
#endif
