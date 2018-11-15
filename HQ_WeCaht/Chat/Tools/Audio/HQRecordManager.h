//
//  HQRecordManager.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/1.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AVFoundation;
#pragma mark -------- 录音代理  -------

@protocol HQAudioRecordDelegate <NSObject>

@optional

- (void)audioRecordAuthorizationDidGranted;

/*
 * 录音是否成功开始
 * error=nil:录音开始，没有错误；否则录音启动失败，error包含错误信息
 *
 */
- (void)audioRecordDidStartRecordingWithError:(NSError *)error andVoiceFile:(NSString *)filePath;

/*
 * averagePower，录音音量
 */
- (void)audioRecordDidUpdateVoiceMeter:(double)averagePower;

//录音时长变化，以秒为单位
- (void)audioRecordDurationDidChanged:(NSTimeInterval)duration andVoicePath:(NSString *)filePath;

//录音最长时间，默认为MAX_RECORD_TIME_ALLOWED = 60秒
- (NSTimeInterval)audioRecordMaxRecordTime;

- (void)audioRecordDidFinishSuccessed:(NSString *)voiceFilePath duration:(CFTimeInterval)duration;

- (void)audioRecordDidFailedWithVoicePath:(NSString *)filePath;

- (void)audioRecordDidCancelledWithVoicePath:(NSString *)filePath;

- (void)audioRecordDurationTooShortWithVoicePath:(NSString *)filePath;

//当设置的最长录音时间到后，派发该消息，但不停止录音，由delegate停止录音
//方便delegate做一些倒计时之类的动作
- (void)audioRecordDurationTooLongWithVoicePath:(NSString *)filePath;

@end



typedef NS_ENUM(NSInteger, HQErrorRecordType) {
    HQErrorRecordTypeAuthorizationDenied,
    HQErrorRecordTypeInitFailed,
    HQErrorRecordTypeCreateAudioFileFailed,
    HQErrorRecordTypeMultiRequest,
    HQErrorRecordTypeRecordError,
};



@interface HQRecordManager : NSObject

@property (nonatomic) BOOL isRecording;


+ (instancetype)sharedManager;

- (void)startRecordingWithDelegate:(id<HQAudioRecordDelegate>)delegate;

- (void)stopRecording;

- (void)cancelRecording;

////获得系统的录音权限
- (void)requestRecordPermission:(void (^)(AVAudioSessionRecordPermission recordPermission))callback;

- (void)removeFileWith:(NSString *)filePath;


- (void)removeCurrentAudioFile;

- (void)removeVoiceFileWithFileName:(NSString *)fileName;

- (void)removeAmrVoiceFileWithFileName:(NSString *)fileName;
@end
