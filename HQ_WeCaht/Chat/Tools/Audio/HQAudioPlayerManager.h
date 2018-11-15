//
//  HQAudioPlayerManager.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/1.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, HQErrorPlayType) {
    HQErrorPlayTypeInitFailed = 0,
    HQErrorPlayTypeFileNotExist,
    HQErrorPlayTypePlayError,
};

#pragma mark ------- 播放语音代理  --------

@protocol HQAudioPlayDelegate <NSObject>

@optional

- (void)audioPlayDidStarted:(id)userinfo;

//播放录音时，系统声音太小
- (void)audioPlayVolumeTooLow;

//发生播放错误时，播放Session同时结束
- (void)audioPlayDidFailed:(id)userinfo;

//播放结束时考虑到连续播放的需求，仅仅停止了当前播放，没有
//停止播放session
- (void)audioPlayDidFinished:(id)userinfo;

//播放停止时考虑到连续播放的需求，仅仅停止了当前播放，没有
//停止播放session
- (void)audioPlayDidStopped:(id)userinfo;

////切换到扬声器模式
- (void)changeSpeakerStatus;

@end



@interface HQAudioPlayerManager : NSObject

@property (nonatomic) BOOL isPlaying;

+ (instancetype)sharedManager;


- (void)startPlayingWithPath:(NSString *)aFilePath
                    delegate:(id<HQAudioPlayDelegate>)delegate
                    userinfo:(id)userinfo
             continuePlaying:(BOOL)continuePlaying;

//关闭整个播放Session
- (void)stopPlaying;

//仅仅停止当前文件的播放，不关闭Session
- (void)stopCurrentPlaying;


@end
