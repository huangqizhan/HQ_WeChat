//
//  HQAudioTools.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/1.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, HQSoundVolumeLevel) {
    HQSoundVolumeLevelHight = 13,
    HQSoundVolumeLevelMiddle = 8,
    HQSoundVolumeLevelLow = 3,
    HQSoundVolumeLevelMute = 0
};

@interface HQAudioTools : NSObject

//是否支持声音输入
+ (BOOL)hasMicphone;

//系统音量，只能有用户设置，分为16个等级，返回值范围为：0-1
+ (float)currentVolumn;

+ (NSInteger)currentVolumeLevel;

+ (void)playShortSound:(NSString *)soundName soundExtension:(NSString *)soundExtension;

// 播放接收到新消息时的声音
+ (void)playNewMessageSound;

//播放发送消息成功时的声音
+ (void)playSendMessageSound;

// 震动
+ (void)playVibration;

+ (void)playNewMessageSoundAndVibration;

+ (void)configAudioSessionForPlayback;


@end
