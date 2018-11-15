//
//  HQAudioPlayerManager.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/1.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HQAudioPlayerManager.h"
#import "EMVoiceConverter.h"
#import "UIApplication+HQExtern.h"
#import "HQAudioTools.h"
#import "HQFileTools.h"
#import "HQDeviceVoiceManager.h"


static HQAudioPlayerManager *instance;

@interface HQAudioPlayerManager ()<AVAudioPlayerDelegate,HQDeviceVoiceManagerDelegate>{
    BOOL isPlaySessionActive;
}
@property (nonatomic, copy) NSString *previousCategory;
@property (nonatomic) AVAudioSession *audioSession;
@property (nonatomic) AVAudioPlayer *audioPlayer;
@property (weak, nonatomic) id<HQAudioPlayDelegate> playerDelegate;
@property (nonatomic) id userinfo;

@end



@implementation HQAudioPlayerManager
#pragma mark - 播放录音

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HQAudioPlayerManager alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.audioSession = [AVAudioSession sharedInstance];
    }
    
    return self;
}

- (void)checkAvailabilityWithFile:(NSString *)amrFileName callback:(void (^)(NSError *error))callback {
    [self stopCurrentPlaying];
    
    NSError *error;
    if (!isPlaySessionActive) {
        //设置AudioSession.category
        error = nil;
        self.previousCategory = self.audioSession.category;
        BOOL success = [self.audioSession
                        setCategory:AVAudioSessionCategoryPlayback
                        withOptions:AVAudioSessionCategoryOptionDuckOthers
                        error:&error];
        
        if (!success || error) {
            NSError *error1 = [NSError errorWithDomain:@"LLAudioManager_Domain"
                                                  code:HQErrorPlayTypeInitFailed
                                              userInfo:nil];
            callback(error1);
            return;
        }
        
        //激活AudioSession
        error = nil;
        success = [[AVAudioSession sharedInstance]
                   setActive:YES
                   withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                   error:&error];
        if (!success || error) {
            NSError *error1 = [NSError errorWithDomain:@"LLAudioManager_Domain"
                                                  code:HQErrorPlayTypeInitFailed
                                              userInfo:nil];
            
            callback(error1);
            return;
        }
    }
    //保证WAV格式录音文件存在
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *wavFilePath = [[NSString stringWithFormat:@"%@/wavAudioTmp",[HQFileTools dataPath]] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.wav",amrFileName]];
    if (![fileManager fileExistsAtPath:wavFilePath]) {
        BOOL covertRet = [self convertAMR:amrFileName toWAV:wavFilePath];
        if (!covertRet) {
            NSError *error1 = [NSError errorWithDomain:@"ERROR_AUDIO_DOMAIN"
                                                  code:HQErrorPlayTypeFileNotExist
                                              userInfo:nil];
            callback(error1);
            return ;
        }
    }
    //创建AVAudioPlayer
    error = nil;
    NSURL *wavURL = [NSURL URLWithString:wavFilePath];
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:wavURL error:&error];
    if(!_audioPlayer || error) {
        _audioPlayer = nil;
        NSError *error1 = [NSError errorWithDomain:@"ERROR_AUDIO_DOMAIN"
                                              code:HQErrorPlayTypeInitFailed
                                          userInfo:nil];
        callback(error1);
        return ;
    }
    
    //开始播放
    _audioPlayer.delegate = self;
    BOOL success = [_audioPlayer play];
    if (!success) {
        NSError *error1 = [NSError errorWithDomain:@"ERROR_AUDIO_DOMAIN"
                                              code:HQErrorPlayTypePlayError
                                          userInfo:nil];
        callback(error1);
        return ;
        
    }
    
    callback(nil);
}
// 播放音频，播放音频不需要特殊权限
- (void)startPlayingWithPath:(NSString *)aFilePath
                    delegate:(id<HQAudioPlayDelegate>)delegate
                    userinfo:(id)userinfo continuePlaying:(BOOL)continuePlaying {
    [self cancelDeviceVoiceNotification];
    [self AddDeviceVoiceNotification];
    [self checkAvailabilityWithFile:aFilePath callback:^(NSError *error) {
        if (!error) {
            self.playerDelegate = delegate;
            self.userinfo = userinfo;
            self.isPlaying = YES;
            isPlaySessionActive = YES;
            
            if (delegate && [delegate respondsToSelector:@selector(audioPlayDidStarted:)]) {
                [delegate audioPlayDidStarted:self.userinfo];
            }            
            if (!continuePlaying && [HQAudioTools currentVolumeLevel] <= HQSoundVolumeLevelLow) {
                if (delegate && [delegate respondsToSelector:@selector(audioPlayVolumeTooLow)]) {
                    [delegate audioPlayVolumeTooLow];
                }
            }
            
        }else {
            switch (error.code) {
                case HQErrorPlayTypeInitFailed:
                case HQErrorPlayTypeFileNotExist:
                case HQErrorPlayTypePlayError:{
                    NSString *msg = @"遇到问题，暂时无法播放";
                    [UIApplication showMessageAlertWithTitle:@"无法播放" message:msg
                                           actionTitle:@"确定"];
                    break;
                }
                default:
                    break;
            }
            
            [self _stopPlaying];
        }
    }];
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player
                       successfully:(BOOL)flag{
    if (flag) {
        [self _stopCurrentPlaying];
        
        if ([self.playerDelegate respondsToSelector:@selector(audioPlayDidFinished:)]) {
            [self.playerDelegate audioPlayDidFinished:self.userinfo];
        }
    }else {
        [self _stopPlaying];
        
        if ([self.playerDelegate respondsToSelector:@selector(audioPlayDidFailed:)]) {
            [self.playerDelegate audioPlayDidFailed:self.userinfo];
        }
        self.playerDelegate = nil;
        self.userinfo = nil;
    }
}
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player
                                 error:(NSError *)error{
    NSLog(@"audioPlayerDecodeErrorDidOccur");
    
    [self _stopPlaying];
    if (self.playerDelegate && [self.playerDelegate respondsToSelector:@selector(audioPlayDidFailed:)]) {
        [self.playerDelegate audioPlayDidFailed:self.userinfo];
    }
    self.playerDelegate = nil;
    self.userinfo = nil;
}
- (void)stopPlaying {
    if (!isPlaySessionActive) {
        return;
    }
    [self _stopPlaying];
    if (self.playerDelegate && [self.playerDelegate respondsToSelector:@selector(audioPlayDidStopped:)]) {
        [self.playerDelegate audioPlayDidStopped:self.userinfo];
    }
    self.playerDelegate = nil;
    self.userinfo = nil;
    
}
- (void)_stopPlaying {
    [self _stopCurrentPlaying];
    
    if (self.previousCategory.length > 0) {
        [self.audioSession setCategory:self.previousCategory error:nil];
        self.previousCategory = nil;
    }
    [self cancelDeviceVoiceNotification];
    [self.audioSession setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    isPlaySessionActive = NO;
}
- (void)stopCurrentPlaying {
    if (!self.isPlaying)
        return;
    [self _stopCurrentPlaying];
    if (self.playerDelegate && [self.playerDelegate respondsToSelector:@selector(audioPlayDidStopped:)]) {
        [self.playerDelegate audioPlayDidStopped:self.userinfo];
    }
}
- (void)_stopCurrentPlaying {
    if (_audioPlayer.isPlaying)
        [_audioPlayer stop]; //stop后不会调用delegate
    [self cancelDeviceVoiceNotification];
    _audioPlayer = nil;
    self.isPlaying = NO;
}
/**
 * @brief 当手机靠近或者离开耳朵时,回调该方法
 *
 */
- (void)deviceIsCloseToUser:(BOOL)isCloseToUser{
    if (isCloseToUser) {
        //切换为听筒播放
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }else {
        //切换为扬声器播放
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
    if (!isCloseToUser) {
        if (_playerDelegate && [_playerDelegate respondsToSelector:@selector(changeSpeakerStatus)]) {
            [_playerDelegate changeSpeakerStatus];
        }
    }
    
    
}
////添加设备监听
- (void)AddDeviceVoiceNotification{
    [[HQDeviceVoiceManager sharedManager] enableProximitySensor];
    [HQDeviceVoiceManager sharedManager].delegate = self;
}
////取消监听
- (void)cancelDeviceVoiceNotification{
    [[HQDeviceVoiceManager sharedManager] disableProximitySensor];
    [HQDeviceVoiceManager sharedManager].delegate = nil;
}

#pragma mark - Convert

- (BOOL)convertAMR:(NSString *)amrFilePath
             toWAV:(NSString *)wavFilePath{
    BOOL ret = NO;
    BOOL isFileExists = [[NSFileManager defaultManager] fileExistsAtPath:amrFilePath];
    if (isFileExists) {
        [EMVoiceConverter amrToWav:amrFilePath wavSavePath:wavFilePath];
        isFileExists = [[NSFileManager defaultManager] fileExistsAtPath:wavFilePath];
        if (isFileExists) {
            ret = YES;
        }
    }
    return ret;
}
- (BOOL)convertWAV:(NSString *)wavFilePath
             toAMR:(NSString *)amrFilePath {
    BOOL ret = NO;
    BOOL isFileExists = [[NSFileManager defaultManager] fileExistsAtPath:wavFilePath];
    if (isFileExists) {
        [EMVoiceConverter wavToAmr:wavFilePath amrSavePath:amrFilePath];
        isFileExists = [[NSFileManager defaultManager] fileExistsAtPath:amrFilePath];
        if (isFileExists) {
            ret = YES;
        }
    }
    return ret;
}


@end
