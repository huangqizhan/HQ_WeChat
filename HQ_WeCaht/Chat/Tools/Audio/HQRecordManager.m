//
//  HQRecordManager.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/1.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HQRecordManager.h"
#import "UIApplication+HQExtern.h"
#import "HQFileTools.h"
#import "EMVoiceConverter.h"





#define ERROR_AUDIO_DOMAIN @"HQAudioManager_Domain"

//amr临时目录
#define AMR_AUDIO_TMP_FOLDER @"amrAudioTmp"

//wav临时目录
#define WAV_AUDIO_TMP_FOLDER @"wavAudioTmp"

static HQRecordManager *recordManager;

@interface HQRecordManager ()<AVAudioRecorderDelegate>{
    CFTimeInterval startTime;
    NSDate *startDate;
    NSTimeInterval maxRecordTime;
    NSTimer *timer;
    NSTimeInterval endDuration;
}
@property (weak, nonatomic) id<HQAudioRecordDelegate> recordDelegate;

@property (nonatomic) dispatch_block_t block;

///会话
@property (nonatomic) AVAudioSession *audioSession;
///录音
@property (nonatomic) AVAudioRecorder *recorder;
///录音设置
@property (nonatomic) NSDictionary *recordSetting;

@property (nonatomic, copy) NSString *previousCategory;

///是否已经取消录音
@property (nonatomic) BOOL isCancelRecording;
///是否已经完成录音
@property (nonatomic) BOOL isFinishRecording;


@end


@implementation HQRecordManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        recordManager = [[HQRecordManager alloc] init];
    });
    
    return recordManager;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        self.audioSession = [AVAudioSession sharedInstance];
    }
    return self;
}

- (NSDictionary *)recordSetting {
    if (!_recordSetting) {
        _recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                          //采样率,影响音频的质量）
                          [NSNumber numberWithFloat: 8000.0],AVSampleRateKey,
                          ////设置录音格式
                          [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                          //线性采样位数  8、16、24、32
                          [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                          //录音通道数  1 或 2
                          [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                          nil];
    }
    return _recordSetting;
}

#pragma mark - 录音

- (void)requestRecordPermission:(void (^)(AVAudioSessionRecordPermission recordPermission))callback {
    switch (self.audioSession.recordPermission) {
        case AVAudioSessionRecordPermissionGranted:
            callback(AVAudioSessionRecordPermissionGranted);
            break;
        case AVAudioSessionRecordPermissionDenied:
            [self promptRecordPermissionDeniedAlert];
            
            callback(AVAudioSessionRecordPermissionDenied);
            break;
        case AVAudioSessionRecordPermissionUndetermined: {
            callback(AVAudioSessionRecordPermissionUndetermined);
            
            WEAK_SELF;
            [self.audioSession requestRecordPermission:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!granted) {
                        [weakSelf promptRecordPermissionDeniedAlert];
                    }
                    
                    callback(granted ? AVAudioSessionRecordPermissionGranted : AVAudioSessionRecordPermissionDenied);
                });
            }];
        }
            break;
    }
}

- (void)checkAvailabilityWithDelegate:(id<HQAudioRecordDelegate>)delegate   callback:(void (^)(NSError *error))callback {
    if (!callback)
        return;
    [self.audioSession requestRecordPermission:^(BOOL granted) {
        //第一步：拥有访问麦克风的权限
        if (!granted) {
            NSError *error = [NSError errorWithDomain:ERROR_AUDIO_DOMAIN
                                                 code:HQErrorRecordTypeAuthorizationDenied
                                             userInfo:nil];
            callback(error);
            return;
        }else {
            if ([delegate respondsToSelector:@selector(audioRecordAuthorizationDidGranted)]) {
                [delegate audioRecordAuthorizationDidGranted];
            }
        }
        
        //第二步：当前麦克风未使用
        if (self.isRecording) {
            NSError *error1 = [NSError errorWithDomain:ERROR_AUDIO_DOMAIN
                                                  code:HQErrorRecordTypeMultiRequest
                                              userInfo:nil];
            
            callback(error1);
            return;
        }
        
        //第三步：设置AudioSession.category
        NSError *error;
        self.previousCategory = self.audioSession.category;
        BOOL success = [self.audioSession
                        setCategory:AVAudioSessionCategoryRecord
                        withOptions:AVAudioSessionCategoryOptionDuckOthers
                        error:&error];
        
        if (!success || error) {
            NSError *error1 = [NSError errorWithDomain:ERROR_AUDIO_DOMAIN
                                                  code:HQErrorRecordTypeInitFailed
                                              userInfo:nil];
            
            callback(error1);
            return;
        }
        
        //第四步：激活AudioSession
        error = nil;
        success = [[AVAudioSession sharedInstance]
                   setActive:YES
                   withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                   error:&error];
        if (!success || error) {
            NSError *error1 = [NSError errorWithDomain:ERROR_AUDIO_DOMAIN
                                                  code:HQErrorRecordTypeInitFailed
                                              userInfo:nil];
            
            callback(error1);
            return;
        }
        
        //第五步：创建临时录音文件
        NSURL *tmpAudioFile = [self.class wavPathWithName:[self.class randomFileName]];
        if (!tmpAudioFile) {
            NSError *error1 = [NSError errorWithDomain:ERROR_AUDIO_DOMAIN
                                                  code:HQErrorRecordTypeCreateAudioFileFailed
                                              userInfo:nil];
            
            callback(error1);
            return;
        }
        
        //第六步：创建AVAudioRecorder
        error = nil;
        _recorder = [[AVAudioRecorder alloc] initWithURL:tmpAudioFile
                                                settings:self.recordSetting
                                                   error:&error];
        
        if(!_recorder || error) {
            _recorder = nil;
            NSError *error1 = [NSError errorWithDomain:ERROR_AUDIO_DOMAIN
                                                  code:HQErrorRecordTypeInitFailed
                                              userInfo:nil];
            callback(error1);
            return ;
        }
        
        //第七步：开始录音
        success = [self.recorder record];
        startTime = CACurrentMediaTime();
        startDate = [NSDate date];
        if (!success) {
            _recorder = nil;
            NSError *error1 = [NSError errorWithDomain:ERROR_AUDIO_DOMAIN
                                                  code:HQErrorRecordTypeRecordError
                                              userInfo:nil];
            callback(error1);
            return ;
        }
        callback(nil);
    }];
}

- (void)startRecordingWithDelegate:(id<HQAudioRecordDelegate>)delegate{
    [self checkAvailabilityWithDelegate:delegate callback:^(NSError *error) {
        if (!error) {
            self.recordDelegate = delegate;
            self.isFinishRecording = NO;
            self.isCancelRecording = NO;
            self.isRecording = YES;
            self.recorder.delegate = self;
            
            [timer invalidate];
            if (self.recordDelegate && [self.recordDelegate respondsToSelector:@selector(audioRecordMaxRecordTime)]){
                timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerHandler:) userInfo:nil repeats:YES];
                [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
            }
            //开启仪表计数功能,可以获取当前录音音量大小
            self.recorder.meteringEnabled = YES;
            maxRecordTime = MAX_RECORD_TIME_ALLOWED;
            if (self.recordDelegate && [self.recordDelegate respondsToSelector:@selector(audioRecordMaxRecordTime)]){
                maxRecordTime = [delegate audioRecordMaxRecordTime];
            }
            //录音音量变化
            [self updateVoiceMeter];
            
            if ([delegate respondsToSelector:@selector(audioRecordDidStartRecordingWithError: andVoiceFile:)]) {
                
                _block = dispatch_block_create(0, ^{
                    [delegate audioRecordDidStartRecordingWithError:nil andVoiceFile:self.recorder.url.path];
                });
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((MIN_RECORD_TIME_REQUIRED + 0.00005) * NSEC_PER_SEC)), dispatch_get_main_queue(), _block);
            }
        }else {
            if (delegate && [delegate respondsToSelector:@selector(audioRecordDidStartRecordingWithError: andVoiceFile:)]) {
                [delegate audioRecordDidStartRecordingWithError:error andVoiceFile:self.recorder.url.path];
            }
            switch (error.code) {
                case HQErrorRecordTypeAuthorizationDenied: {
                    [self promptRecordPermissionDeniedAlert];
                    break;
                }
                case HQErrorRecordTypeInitFailed: {
                    [UIApplication showMessageAlertWithTitle:@"无法录音" message:@"无法正常访问您的麦克风"
                                           actionTitle:@"确定"];
                    break;
                }
                case HQErrorRecordTypeMultiRequest:
                    [UIApplication showMessageAlertWithTitle:@"无法录音" message:@"无法正常访问您的麦克风"
                                           actionTitle:@"确定"];
                    break;
                case HQErrorRecordTypeCreateAudioFileFailed:
                    [UIApplication showMessageAlertWithTitle:@"无法录音" message:@"创建录音文件出错"
                                           actionTitle:@"确定"];
                    break;
                case HQErrorRecordTypeRecordError:
                    [UIApplication showMessageAlertWithTitle:@"无法录音" message:@"无法正常访问您的麦克风"
                                           actionTitle:@"确定"];
                    break;
                default:
                    break;
                    
            }
        }
        
    }];
}
//处理音量变化
- (void)updateVoiceMeter {
    WEAK_SELF;
    __block BOOL isSendMsg = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while(weakSelf.isRecording) {
            [weakSelf.recorder updateMeters];
            float averagePower = [weakSelf.recorder peakPowerForChannel:0];
            double lowPassResults = pow(10, (0.05 * averagePower)) * 10;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.recordDelegate audioRecordDidUpdateVoiceMeter:lowPassResults];
            });
            
            if (weakSelf.recorder.currentTime >= maxRecordTime &&!isSendMsg) {
                isSendMsg = YES;
                if (weakSelf.recordDelegate && [weakSelf.recordDelegate respondsToSelector:@selector(audioRecordDurationTooLongWithVoicePath:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.recordDelegate audioRecordDurationTooLongWithVoicePath:weakSelf.recorder.url.path];
                    });
                }
            }
            [NSThread sleepForTimeInterval:0.05];
        }
    });
}

- (void)timerHandler:(NSTimer *)timer {
    [self.recordDelegate audioRecordDurationDidChanged:self.recorder.currentTime andVoicePath:self.recorder.url.path];
}

/**
 *  停止录音
 */
- (void)stopRecording {
    if(!self.isRecording){
        return;
    }
    
    //录音时间过短，按照取消录音对待
    if(self.recorder.currentTime < MIN_RECORD_TIME_REQUIRED){
        self.isFinishRecording = NO;
        self.isCancelRecording = YES;
        
        [self willStopRecord];
        if (self.recordDelegate && [self.recordDelegate respondsToSelector:@selector(audioRecordDurationTooShortWithVoicePath:)]) {
            [self.recordDelegate audioRecordDurationTooShortWithVoicePath:self.recorder.url.path];
            [self removeFileWith:_recorder.url.path];
        }
    }else {
        self.isFinishRecording = YES;
        self.isCancelRecording = NO;
        
        [self willStopRecord];
    }
}
/**
 *  取消录音
 */
- (void)cancelRecording {
    if(!self.isRecording){
        return;
    }
    
    self.isFinishRecording = NO;
    self.isCancelRecording = YES;
    [self willStopRecord];
    if (self.recordDelegate && [self.recordDelegate respondsToSelector:@selector(audioRecordDidCancelledWithVoicePath:)]) {
        [self.recordDelegate audioRecordDidCancelledWithVoicePath:self.recorder.url.path];
    }
    [self removeCurrentAudioFile];
}
- (void)willStopRecord {
    endDuration = _recorder.currentTime;
    if (_recorder.isRecording)
        [self.recorder stop]; //stop后会调用代理finishing方法
    //    endDate = [NSDate date];
    self.isRecording = NO;
    
    if (!dispatch_block_testcancel(_block))
        dispatch_block_cancel(_block);
    _block = nil;
}
- (void)didStopRecord {
    _recorder.delegate = nil;
    _recorder = nil;
    self.recordDelegate = nil;
    self.isRecording = NO;
    self.isFinishRecording = NO;
    self.isCancelRecording = NO;
    maxRecordTime = 1<<10;
    startDate = nil;
    //    endDate = nil;
    endDuration = 0;
    if (self.previousCategory.length > 0) {
        [self.audioSession setCategory:self.previousCategory error:nil];
        self.previousCategory = nil;
    }
    [self.audioSession setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}
#pragma mark - AVAudioRecorderDelegate   录音结束
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder
                           successfully:(BOOL)flag {
    NSString *recordPath = [[_recorder url] path];
    
    if (!flag) {
        if ([self.recordDelegate respondsToSelector:@selector(audioRecordDidFailedWithVoicePath:)]) {
            [self.recordDelegate audioRecordDidFailedWithVoicePath:self.recorder.url.path];
        }
        
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:recordPath error:nil];
        
    }else if (self.isFinishRecording) {
        //录音格式转换，从wav转为amr
        NSString *amrFilePath = [self.class amrPathWithName:[[self.recorder.url.path lastPathComponent] stringByDeletingPathExtension]].absoluteString;
        BOOL convertResult = [self convertWAV:recordPath toAMR:amrFilePath];
        if (convertResult) {
            if ([self.recordDelegate respondsToSelector:@selector(audioRecordDidFinishSuccessed:duration:)]) {
                [self.recordDelegate audioRecordDidFinishSuccessed:amrFilePath duration:endDuration];
            }
        }else {
            if ([self.recordDelegate respondsToSelector:@selector(audioRecordDidFailedWithVoicePath:)]) {
                [self.recordDelegate audioRecordDidFailedWithVoicePath:self.recorder.url.path];
            }
        }
        // 删除录的wav
//        NSFileManager *fm = [NSFileManager defaultManager];
//        [fm removeItemAtPath:recordPath error:nil];
    }else if (self.isCancelRecording) {
        // 删除录的wav
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:recordPath error:nil];
    }
    [self didStopRecord];
}
///录音出错
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder
                                   error:(NSError *)error {
    NSLog(@"audioRecorderEncodeErrorDidOccur");
    if ([self.recordDelegate respondsToSelector:@selector(audioRecordDidFailedWithVoicePath:)]) {
        [self.recordDelegate audioRecordDidFailedWithVoicePath:self.recorder.url.path];
    }
    [self didStopRecord];
    [self removeFileWith:recorder.url.path];
}
- (void)promptRecordPermissionDeniedAlert {
    [UIApplication showMessageAlertWithTitle:@"无法录音" message:@"请在iPhone的“设置-隐私-麦克风”选项中，允许微信访问你的手机麦克风。"
                           actionTitle:@"好"];
}

+ (NSString *)randomFileName {
    int x = arc4random() % 100000;
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [NSString stringWithFormat:@"%d%d",(int)time,x];
    
    return fileName;
}

+ (NSURL *)wavPathWithName:(NSString *)fileName {
    NSURL *wavTmpFolder = [HQFileTools createFolderWithName:WAV_AUDIO_TMP_FOLDER inDirectory:[HQFileTools dataPath]];
    if (!wavTmpFolder) {
        return nil;
    }
    NSString *filePathName = [NSString stringWithFormat:@"%@.wav", fileName];
    NSURL *filePath = [wavTmpFolder URLByAppendingPathComponent:filePathName];
    
    return filePath;
}

+ (NSURL *)amrPathWithName:(NSString *)fileName{
    NSURL *wavTmpFolder = [HQFileTools createFolderWithName:AMR_AUDIO_TMP_FOLDER inDirectory:[HQFileTools dataPath]];
    if (!wavTmpFolder) {
        return nil;
    }
    NSString *filePathName = [NSString stringWithFormat:@"%@.amr", fileName];
    NSURL *filePath = [wavTmpFolder URLByAppendingPathComponent:filePathName];
    return filePath;
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
#pragma mark ------- 删除文件  -----
- (void)removeFileWith:(NSString *)filePath{
    dispatch_queue_t queue = dispatch_queue_create("remoceQueue",DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        BOOL isok = [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        NSLog(@"remove %d",isok);
    });
}
- (void)removeCurrentAudioFile{
    if (_recorder.url.path) {
        [self removeFileWith:_recorder.url.path];
    }
}
- (void)removeVoiceFileWithFileName:(NSString *)fileName{
    NSString *wavFilePath = [[NSString stringWithFormat:@"%@/wavAudioTmp",[HQFileTools dataPath]] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.wav",fileName]];
    [self removeFileWith:wavFilePath];
    NSString *amrFilePath = [[NSString stringWithFormat:@"%@/amrAudioTmp",[HQFileTools dataPath]] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.amr",fileName]];
    [self removeFileWith:amrFilePath];
}
- (void)removeAmrVoiceFileWithFileName:(NSString *)fileName{
    NSString *amrFilePath = [[NSString stringWithFormat:@"%@/amrAudioTmp",[HQFileTools dataPath]] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.amr",fileName]];
    [self removeFileWith:amrFilePath];
}
@end








