//
//  HQDeviceVoiceManager.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/6.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HQDeviceVoiceManager.h"

@implementation HQDeviceVoiceManager

+ (HQDeviceVoiceManager *)sharedManager {
    static HQDeviceVoiceManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HQDeviceVoiceManager alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}
- (BOOL)isProximitySensorEnabled {
    return [UIDevice currentDevice].proximityMonitoringEnabled;
}

- (BOOL)enableProximitySensor {
    if (!self.isProximitySensorEnabled) {
        [UIDevice currentDevice].proximityMonitoringEnabled = YES;
        if (self.isProximitySensorEnabled) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChanged:) name:UIDeviceProximityStateDidChangeNotification object:nil];
            return YES;
        }else {
            return NO;
        }
    }
    return YES;
}
- (BOOL)disableProximitySensor {
    if (self.isProximitySensorEnabled) {
        [UIDevice currentDevice].proximityMonitoringEnabled = NO;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
    }
    return NO;
}

- (BOOL)isCloseToUser {
    return [UIDevice currentDevice].proximityState;
}

- (void)sensorStateChanged:(NSNotification *)notification {
    if (self.delegate && [self.delegate respondsToSelector:@selector(deviceIsCloseToUser:)]) {
        [self.delegate deviceIsCloseToUser:[self isCloseToUser]];
    }
}

@end
