//
//  HQDeviceVoiceManager.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/6.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol HQDeviceVoiceManagerDelegate <NSObject>

/**
 * @brief 当手机靠近或者离开耳朵时,回调该方法
 *
 */
- (void)deviceIsCloseToUser:(BOOL)isCloseToUser;

@end


@interface HQDeviceVoiceManager : NSObject


+ (instancetype)sharedManager;

@property (nonatomic, weak) id<HQDeviceVoiceManagerDelegate> delegate;

- (BOOL)isCloseToUser;
- (BOOL)isProximitySensorEnabled;
- (BOOL)enableProximitySensor;
- (BOOL)disableProximitySensor;



@end
