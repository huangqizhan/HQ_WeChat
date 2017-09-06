//
//  HQChatBoxViewController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/1.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQChatBoxViewController.h"
#import "HQFaceListView.h"
#import "HQMoreListView.h"
#import "HQFaceModel.h"
#import "HQCameraNavigationController.h"
#import "HQCameraController.h"
#import "HQLocalImageManager.h"
#import "HQGifPlayManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "HQRecordHUDView.h"
#import "HQRecordManager.h"
#import "HQTipView.h"
#import "HQLocationMapController.h"





@interface HQChatBoxViewController ()<HQChatBoxDelegate,HQFaceListViewDelegate,HQMoreListViewDelegate,HQPickerImageViewControllerDelegate,HQCameraControllerDelegate,HQAudioRecordDelegate>{
    NSInteger countDown;
}
///键盘frame
@property (nonatomic, assign) CGRect keyboardFrame;
///表情键盘窗口
@property (nonatomic,strong) HQFaceListView *faceListView;
///工具栏窗口
@property (nonatomic,strong) HQMoreListView *moreListView;

@property (nonatomic, strong) UIImagePickerController *imagePickerVc;
///语音HUD
@property (nonatomic,strong) HQRecordHUDView *recordHUDView;

@end



@implementation HQChatBoxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.chatBox];
    self.view.backgroundColor = IColor(237, 237, 246);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    ////建议使用UIKeyboardWillChangeFrameNotification 而不是 will show  and will Hidden 
    ///UIKeyboardWillChangeFrameNotification
}
- (void)keyboardWillHide:(NSNotification *)notification{
    self.keyboardFrame = CGRectZero;
    if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:)]) {
//        [_delegate chatBoxViewController:self didChangeChatBoxHeight:HEIGHT_TABBAR];
        _chatBox.boxStatus = HQChatBoxStatusNothing;
    }
}
- (void)keyboardFrameWillChange:(NSNotification *)notification{
    self.keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (_chatBox.boxStatus == HQChatBoxStatusShowKeyboard && self.keyboardFrame.size.height <= HEIGHT_CHATBOXVIEW) {
        return;
    }
    else if ((_chatBox.boxStatus == HQChatBoxStatusShowFace || _chatBox.boxStatus == HQChatBoxStatusShowMore) && self.keyboardFrame.size.height <= HEIGHT_CHATBOXVIEW) {
        return;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:)]) {
        
        
//        NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
//        NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
//        [UIView beginAnimations:nil context:NULL];
//        [UIView setAnimationBeginsFromCurrentState:YES];
//        [[UIMenuController sharedMenuController] setMenuItems:nil];
//        [UIView setAnimationDuration:[duration doubleValue]];
//        [UIView setAnimationCurve:[curve intValue]];
//        [_delegate chatBoxViewController:self didChangeChatBoxHeight: self.keyboardFrame.size.height + HEIGHT_TABBAR];
//        [UIView commitAnimations];
//        _chatBox.boxStatus = HQChatBoxStatusShowKeyboard; // 状态改变
        
        NSDictionary *userInfo = [notification userInfo];
        NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
        CGSize keybordSize = [value CGRectValue].size;
        NSValue *keyAnimationTime  =[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        NSTimeInterval keyBordTimerval;
        [keyAnimationTime getValue:&keyBordTimerval];
        [[HQGifPlayManager shareInstance] pauseAllAnimation]; ///暂停GIF播放
        [UIView animateWithDuration:keyBordTimerval animations:^{
            [_delegate chatBoxViewController:self didChangeChatBoxHeight: keybordSize.height + self.chatBox.height];
        }completion:^(BOOL finished) {
//            _chatBox.boxStatus = HQChatBoxStatusShowKeyboard; // 状态改变
            [[HQGifPlayManager shareInstance] restartAllAnimaiton]; ///GIF重新播放
        }];
    }
}
/************************************键盘处理**************************************************/
- (BOOL)resignFirstResponder{
    if (self.chatBox.boxStatus == HQChatBoxStatusShowVideo) { // 录制视频状态
        if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:)]) {
             [[HQGifPlayManager shareInstance] pauseAllAnimation]; ///暂停GIF播放
            [UIView animateWithDuration:0.3 animations:^{
                [_delegate chatBoxViewController:self didChangeChatBoxHeight:HEIGHT_TABBAR];
            } completion:^(BOOL finished) {
//                [self.videoView removeFromSuperview]; // 移除video视图
                self.chatBox.boxStatus = HQChatBoxStatusNothing;//同时改变状态
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [[HQGifPlayManager shareInstance] restartAllAnimaiton]; ///GIF重新播放
//                    [[ICVideoManager shareManager] exit];  // 防止内存泄露
                });
            }];
        }
        return [super resignFirstResponder];
    }
    if (self.chatBox.boxStatus != HQChatBoxStatusNothing && self.chatBox.boxStatus != HQChatBoxStatusShowVoice) {
        [self.chatBox resignFirstResponder];
        if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:)]) {
             [[HQGifPlayManager shareInstance] pauseAllAnimation]; ///暂停GIF播放
            [UIView animateWithDuration:0.3 animations:^{
                [_delegate chatBoxViewController:self didChangeChatBoxHeight:self.chatBox.height];
            } completion:^(BOOL finished) {
                [self.faceListView removeFromSuperview];
                [self.moreListView removeFromSuperview];
                // 状态改变
                self.chatBox.boxStatus = HQChatBoxStatusNothing;
                [[HQGifPlayManager shareInstance] restartAllAnimaiton]; ///GIF重新播放
            }];
        }
    }
    return [super resignFirstResponder];
}

- (BOOL)becomeFirstResponder{
    return [super becomeFirstResponder];
}
#pragma mark -------- ChatBoxDelegate -----
- (void)chatBox:(HQChatBox *)chatBox changeStatusForm:(HQChatBoxStatus)fromStatus to:(HQChatBoxStatus)toStatus{
    if (toStatus == HQChatBoxStatusShowKeyboard) {  // 显示键盘
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.faceListView removeFromSuperview];
            [self.moreListView removeFromSuperview];
        });
        return;
    } else if (toStatus == HQChatBoxStatusShowVoice) {    // 语音输入按钮
         [[HQGifPlayManager shareInstance] pauseAllAnimation]; ///暂停GIF播放
        [UIView animateWithDuration:0.3 animations:^{
        if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:)]) {
            [_delegate chatBoxViewController:self didChangeChatBoxHeight:self.chatBox.height];
        }
        } completion:^(BOOL finished) {
            [self.faceListView removeFromSuperview];
            [self.moreListView removeFromSuperview];
            [[HQGifPlayManager shareInstance] restartAllAnimaiton]; ///GIF重新播放
        }];
    } else if (toStatus == HQChatBoxStatusShowFace) {     // 表情面板
        if (fromStatus == HQChatBoxStatusShowVoice || fromStatus == HQChatBoxStatusNothing ) {
            CGRect newRect;
            newRect.size.height = HEIGHT_CHATBOXVIEW;
            self.faceListView.top = HEIGHT_CHATBOXVIEW;
            self.keyboardFrame = newRect;
             [[HQGifPlayManager shareInstance] pauseAllAnimation]; ///暂停GIF播放
            [UIView animateWithDuration:0.3 animations:^{
                [self.view addSubview:self.faceListView];
               self.moreListView.top = self.faceListView.top = self.chatBox.height;
            if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:)]) {
                [_delegate chatBoxViewController:self didChangeChatBoxHeight:self.chatBox.height + HEIGHT_CHATBOXVIEW];
            }
            } completion:^(BOOL finished) {
               [[HQGifPlayManager shareInstance] restartAllAnimaiton]; ///GIF重新播放
            }];
        } else {  // 表情高度变化
            [self.view addSubview:self.faceListView];
            self.faceListView.top = HEIGHT_CHATBOXVIEW;
            CGRect newRect;
            newRect.size.height = HEIGHT_CHATBOXVIEW;
            self.keyboardFrame = newRect;
             [[HQGifPlayManager shareInstance] pauseAllAnimation]; ///暂停GIF播放
            [UIView animateWithDuration:0.3 animations:^{
               self.moreListView.top = self.faceListView.top = self.chatBox.height;
            } completion:^(BOOL finished) {
                [self.moreListView removeFromSuperview];
                [[HQGifPlayManager shareInstance] restartAllAnimaiton]; ///GIF重新播放
            }];
            if (fromStatus != HQChatBoxStatusShowMore) {
                if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:)]) {
                    [_delegate chatBoxViewController:self didChangeChatBoxHeight:self.chatBox.height + HEIGHT_CHATBOXVIEW];
                }
            }
        }
    } else if (toStatus == HQChatBoxStatusShowMore) {  ///更多
        if (fromStatus == HQChatBoxStatusShowVoice || fromStatus == HQChatBoxStatusNothing) {
            CGRect newRect;
            newRect.size.height = HEIGHT_CHATBOXVIEW;
            self.keyboardFrame = newRect;
            [self.view addSubview:self.moreListView];
            self.moreListView.top = HEIGHT_CHATBOXVIEW;
             [[HQGifPlayManager shareInstance] pauseAllAnimation]; ///暂停GIF播放
            [UIView animateWithDuration:0.3 animations:^{
                self.moreListView.top = self.chatBox.height;
                if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:)]) {
                    [_delegate chatBoxViewController:self didChangeChatBoxHeight:self.chatBox.height + HEIGHT_CHATBOXVIEW];
                }
            } completion:^(BOOL finished) {
                [[HQGifPlayManager shareInstance] restartAllAnimaiton]; ///GIF重新播放
            }];
        } else {
            CGRect newRect;
            newRect.size.height = HEIGHT_CHATBOXVIEW;
            self.keyboardFrame = newRect;
            [self.view addSubview:self.moreListView];
            self.moreListView.top = HEIGHT_CHATBOXVIEW;
             [[HQGifPlayManager shareInstance] pauseAllAnimation]; ///暂停GIF播放
            [UIView animateWithDuration:0.2 animations:^{
                self.moreListView.top = self.chatBox.height;
            } completion:^(BOOL finished) {
                [self.faceListView removeFromSuperview];
            }];
            [UIView animateWithDuration:0.2 animations:^{
                if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:)]) {
                    [_delegate chatBoxViewController:self didChangeChatBoxHeight:self.chatBox.height+HEIGHT_CHATBOXVIEW];
                }
            } completion:^(BOOL finished) {
                [[HQGifPlayManager shareInstance] restartAllAnimaiton]; ///GIF重新播放
            }];
        }
    }
}
- (void)chatBox:(HQChatBox *)chatBox changeChatBoxHeight:(CGFloat)height{
    self.moreListView.top = self.faceListView.top = self.chatBox.bottom;
    [_delegate chatBoxInputStatusController:self ChatBoxHeight:self.keyboardFrame.size.height+height];
}
- (void)chatBox:(HQChatBox *)chatBox sendTextMessage:(NSString *)textMessage{
    if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:sendTextMessage:)]) {
        [_delegate chatBoxViewController:self sendTextMessage:textMessage];
    }
}
/************************************录音**************************************************/
#pragma mark ------ 开始录音 ----
- (void)chatBoxDidStartRecordingVoice:(HQChatBox *)chatBox{
    [[HQRecordManager sharedManager] stopRecording];
    if (![HQRecordManager sharedManager].isRecording) {
        [self.recordHUDView setStyle:HQVoiceIndicatorStyleRecord];
        [[HQRecordManager sharedManager] startRecordingWithDelegate:self];
    }
}
#pragma mark ------- 完成录音 -----
- (void)chatBoxDidStopRecordingVoice:(HQChatBox *)chatBox{
    [[HQRecordManager sharedManager] stopRecording];
    
}
#pragma mark -------- 取消 -----
- (void)chatBoxDidCancelRecordingVoice:(HQChatBox *)chatBox{
    [[HQRecordManager sharedManager] cancelRecording];
}
#pragma mark -------- 拖拽  拽出拽进  ------
- (void)chatBoxDidDrag:(BOOL)inside{
    if (!inside) {
        if (self.recordHUDView.subviews && self.recordHUDView.style != HQVoiceIndicatorStyleVolumeTooLow && self.recordHUDView.style != HQVoiceIndicatorStyleCancel) {
            [self.recordHUDView setStyle:HQVoiceIndicatorStyleCancel];
        }
    }else{
        if (self.recordHUDView.subviews && self.recordHUDView.style != HQVoiceIndicatorStyleVolumeTooLow && self.recordHUDView.style != HQVoiceIndicatorStyleRecord){
            [self.recordHUDView setStyle:HQVoiceIndicatorStyleRecord];
        }
    }
}
#pragma mark -------- 录音太短 -------
- (void)chatBoxRecordTooShort{
     [[HQRecordManager sharedManager] cancelRecording];
    [HQTipView showTipView:self.recordHUDView];
    [self.recordHUDView setStyle:HQVoiceIndicatorStyleTooShort];
    [self hideVoiceIndicatorViewAfterDelay:1];
    [[HQRecordManager sharedManager] removeCurrentAudioFile];
}
#pragma mark ------- 录制语音代理 --------

/**
 系统允许录音
 */
- (void)audioRecordAuthorizationDidGranted{
    [HQTipView showTipView:self.recordHUDView];
    [self.recordHUDView setStyle:HQVoiceIndicatorStyleRecord];
}

/*
 * 录音是否成功开始
 * error=nil:录音开始，没有错误；否则录音启动失败，error包含错误信息
 *
 */
- (void)audioRecordDidStartRecordingWithError:(NSError *)error andVoiceFile:(NSString *)filePath{
    if (error) {
        if (self.recordHUDView.subviews) {
            [HQTipView hideTipView:self.recordHUDView];
        }
        return;
    }
    ////创建消息体   显示在tableView上
    if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewControllerCreateAudioMessage:andFilePath:)]) {
        [_delegate chatBoxViewControllerCreateAudioMessage:self andFilePath:filePath];
    }
}
/*
 * averagePower，录音音量
 */
- (void)audioRecordDidUpdateVoiceMeter:(double)averagePower{
    if (self.recordHUDView.subviews) {
        [self.recordHUDView updateMetersValue:averagePower];
    }
}
//录音时长变化，以秒为单位
- (void)audioRecordDurationDidChanged:(NSTimeInterval)duration andVoicePath:(NSString *)filePath{
   ///更新语音cell的时间
    if (duration > 0.5) {
        if (_delegate  && [_delegate respondsToSelector:@selector(chatBoxViewControllerUpdateAudioMessage:andFilePath: andTimeral:)]) {
            [_delegate chatBoxViewControllerUpdateAudioMessage:self andFilePath:filePath andTimeral:duration];
        }
        
    }
}

//录音最长时间，默认为MAX_RECORD_TIME_ALLOWED = 60秒
- (NSTimeInterval)audioRecordMaxRecordTime{
    return MAX_RECORD_TIME_ALLOWED-10;
}
////语音录制完成
- (void)audioRecordDidFinishSuccessed:(NSString *)voiceFilePath duration:(CFTimeInterval)duration{
    if (self.recordHUDView.subviews) {
        if (self.recordHUDView.style == HQVoiceIndicatorStyleTooLong) {
            WEAKSELF;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.75*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                STRONG_SELF;
                if (strongSelf->_recordHUDView.superview) {
                    [HQTipView hideTipView:strongSelf->_recordHUDView];
                }
                [weakSelf.chatBox cancelRecordButtonTouchEvent];
            });
        }else{
            [HQTipView hideTipView:self.recordHUDView];
        }
    }
    //////语音消息处理
    if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewControllerDidFinishRecord:andFilePath: andVoiceDuration:)]) {
        [_delegate chatBoxViewControllerDidFinishRecord:self andFilePath:voiceFilePath andVoiceDuration:duration];
    }
}
///语音录制失败
- (void)audioRecordDidFailedWithVoicePath:(NSString *)filePath{
    if (self.recordHUDView.superview) {
        [HQTipView hideTipView:self.recordHUDView];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewControllerRemoveAudioMessage:andFilePath:)]) {
        [_delegate chatBoxViewControllerRemoveAudioMessage:self andFilePath:filePath];
    }
}
////录制语音失败
- (void)audioRecordDidCancelledWithVoicePath:(NSString *)filePath{
    [self audioRecordDidFailedWithVoicePath:filePath];
}
///录制语音太短
- (void)audioRecordDurationTooShortWithVoicePath:(NSString *)filePath{
    [HQTipView showTipView:self.recordHUDView];
    [self.recordHUDView setStyle:HQVoiceIndicatorStyleTooShort];
    [self hideVoiceIndicatorViewAfterDelay:2];
}
//当设置的最长录音时间到后，派发该消息，但不停止录音，由delegate停止录音
//方便delegate做一些倒计时之类的动作
- (void)audioRecordDurationTooLongWithVoicePath:(NSString *)filePath{
    if (self.recordHUDView.superview) {
        countDown = 9;
        NSTimer *countDownTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(showCountDownIndicator:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:countDownTimer forMode:NSRunLoopCommonModes];
    }
}
- (void)showCountDownIndicator:(NSTimer *)timer {
    if (self.recordHUDView.superview && countDown > 0) {
        [self.recordHUDView setCountDown:countDown];
        --countDown;
    }else {
        [self.recordHUDView setCountDown:0];
        [timer invalidate];
        [self.recordHUDView setStyle:HQVoiceIndicatorStyleTooLong];
        [self hideVoiceIndicatorViewAfterDelay:2];
        [[HQRecordManager sharedManager] stopRecording];
    }
}

/************************************键盘**************************************************/

#pragma mark ------- HQFaceListViewDelegate ------
- (void)HQFaceListViewDidseletedItem:(HQFaceListView *)listView andFaceModel:(HQFaceModel *)faceModel{
    if ([faceModel.type isEqualToString:@"1"]) {
        [self.chatBox.textView insertText:faceModel.code.emoji];
        [self.chatBox.textView scrollRangeToVisible:NSMakeRange(self.chatBox.textView.text.length, 0)];
    }else if ([faceModel.type isEqualToString:@"2"]){
        [self.chatBox.textView insertText:faceModel.face_name];
        [self.chatBox.textView scrollRangeToVisible:NSMakeRange(self.chatBox.textView.text.length, 0)];
    }else if ([faceModel.type isEqualToString:@"4"]){
        [self sendGifMessageWith:faceModel];
    }
}
- (void)HQFaceListViewDidDeleteItem:(HQFaceListView *)listView{
    [self.chatBox.textView deleteBackward];
}
- (void)HQFaceListViewDidSendAction:(HQFaceListView *)listView{
    if (self.chatBox.textView.hasText) {
        if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:sendTextMessage:)]) {
            [_delegate chatBoxViewController:self sendTextMessage:self.chatBox.textView.text];
            self.chatBox.textView.text = @"";
        }
    }
}
#pragma mark ------ 发送GIF表情  -----
- (void)sendGifMessageWith:(HQFaceModel *)faceModel{
    if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:sendGifMessage:)]) {
        [_delegate chatBoxViewController:self sendGifMessage:faceModel.face_name];
    }

}
#pragma mark ------ 图片 拍摄 视屏聊天 位置 红包 转账 个人名片 语音输入 收藏 卡券 -----
- (void)HQMoreListViewDidSeleteItem:(HQMoreListView *)listView andFaceModel:(HQFaceModel *)faceModel{
    if ([faceModel.itemTitle isEqualToString:@"图片"]) {
        [self selectPicturePushToHQPickerImageViewController];
    }else if ([faceModel.itemTitle isEqualToString:@"拍摄"]){
        [self customerCaptureCamera];
    }else if ([faceModel.itemTitle isEqualToString:@"位置"]){
        [self seleteCurrentLocation];
    }
}
#pragma mark ------- 跳转位置界面 -------
- (void)seleteCurrentLocation{
    HQLocationMapController *mapVC = [[HQLocationMapController alloc] init];
    [mapVC setSearchResultCallBack:^(UIImage *image , CLLocationCoordinate2D coor2D,NSString *address){
        if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewControllerSendlocationMessage:andImage:andLocation:andAddress: andFileName:)]) {
            NSString *fileName = [NSString stringWithFormat:@"%ld",(long)[NSDate returnTheTimeralFrom1970]];
            [[HQLocalImageManager shareImageManager] saveImage:image andFileName:fileName];
            [_delegate chatBoxViewControllerSendlocationMessage:self andImage:image andLocation:coor2D andAddress:address andFileName:fileName];
        }
    }];
    [self presentViewController:mapVC animated:YES completion:nil];
}
#pragma mark ------- 图片选择  -----------
- (void)selectPicturePushToHQPickerImageViewController{
    HQPickerImageViewController *pickerImageVC = [[HQPickerImageViewController alloc] initWithMaxImagesCount:6 columnNumber:4 delegate:self pushPhotoPickerVc:YES];
    [self presentViewController:pickerImageVC animated:YES completion:nil];
}
#pragma mark ------ 图片选择后处理    -------
- (void)imagePickerController:(HQPickerImageViewController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceImageUuids:(NSArray *)imageUuids{
    if (photos.count == imageUuids.count) {
        NSMutableArray *names = [NSMutableArray new];
        for (int i = 0; i<photos.count; i++) {
            NSString *fileName = [NSString stringWithFormat:@"%ld",(long)[NSDate returnTheTimeralFrom1970]+i];
            [names addObject:fileName];
            [[HQLocalImageManager shareImageManager] saveImage:photos[i] andFileName:fileName];
        }
        if (names.count == photos.count && names.count > 0 && photos.count > 0) {
            if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:sendImageMessage:imagePath: andFileName:)]) {
                [_delegate chatBoxViewController:self sendImageMessage:photos imagePath:imageUuids andFileName:names];
            }
        }
    }
//    __block PHAsset *imageAsset = nil;
//    PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:imageUuids options:nil];
//    [result enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        imageAsset = obj;
//        if (imageAsset){
//            //加载图片数据
//            [[PHImageManager defaultManager] requestImageDataForAsset:imageAsset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
//                UIImage *mmm = [UIImage imageWithData:imageData];
//                NSLog(@"mmm = %@",mmm);
//            }];
//        }
//    }];
}
- (void)imagePickerpPhotoControllerDidCancel:(HQPickerImageViewController *)picker{
    
}
#pragma mark ------ 选择视频 ------
- (void)imagePickerController:(HQPickerImageViewController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset{
    
}
#pragma mark ------- 选择GIF -------
- (void)imagePickerController:(HQPickerImageViewController *)picker didFinishPickingGifImage:(UIImage *)animatedImage sourceAssets:(id)asset{
    
}
#pragma mark -------- 自定义拍照 ------
- (void)customerCaptureCamera{
    HQCameraController *camVC = [[HQCameraController alloc] init];
    HQCameraNavigationController *cameraVC = [[HQCameraNavigationController alloc] initWithRootViewController:camVC];
    camVC.delegate = self;
    [self presentViewController:cameraVC animated:YES completion:nil];
}
- (void)HQCameraController:(HQCameraController *)cameraVC andCameraImage:(UIImage *)cameraImage andInfo:(NSDictionary *)info andIdentifer:(NSString *)identufer{
    if (cameraImage) {
        if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:sendImageMessage:imagePath: andFileName:)]) {
            if (cameraImage) {
                [_delegate chatBoxViewController:self sendImageMessage:@[cameraImage] imagePath:@[identufer] andFileName:@[[NSDate getCurrnetSendImageName]]];
            }
        }
    }
//    __block PHAsset *imageAsset = nil;
//    PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:@[identufer] options:nil];
//    [result enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        imageAsset = obj;
//        if (imageAsset){
//            //加载图片数据
//            [[PHImageManager defaultManager] requestImageDataForAsset:imageAsset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
//                UIImage *mmm = [UIImage imageWithData:imageData];
//                NSLog(@"mmm = %@",mmm);
//            }];
//        }
//    }];

}
#pragma mark ------- 系统拍照 -----
- (void)takePhoto {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if ((authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied) && iOS7Later) {
        // 无权限 做一个友好的提示
        NSString *appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleDisplayName"];
        if (!appName) appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleName"];
        NSString *message = [NSString stringWithFormat:[NSBundle tz_localizedStringForKey:@"Please allow %@ to access your camera in \"Settings -> Privacy -> Camera\""],appName];
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:[NSBundle tz_localizedStringForKey:@"Can not use camera"] message:message delegate:self cancelButtonTitle:[NSBundle tz_localizedStringForKey:@"Cancel"] otherButtonTitles:[NSBundle tz_localizedStringForKey:@"Setting"], nil];
        [alert show];
    } else { // 调用相机
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
            self.imagePickerVc.sourceType = sourceType;
            if(iOS8Later) {
                self.imagePickerVc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            }
            [self presentViewController:_imagePickerVc animated:YES completion:nil];
        } else {
            NSLog(@"模拟器中无法打开照相机,请在真机中使用");
        }
    }
}
#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        if (image) {
            [[HQImageManager manager] NewSavePhotoWithImage:image completion:^(UIImage *photo, NSDictionary *info, NSString *identifer) {
                
            } faild:^(NSError *error) {
                
            }];
        }
    }
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark ------ UIAlertViewDelegate ----
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) { // 去设置界面，开启相机访问权限
        if (iOS8Later) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        } else {
            NSURL *privacyUrl = [NSURL URLWithString:@"prefs:root=Privacy&path=CAMERA"];
            if ([[UIApplication sharedApplication] canOpenURL:privacyUrl]) {
                [[UIApplication sharedApplication] openURL:privacyUrl];
            } else {
                NSString *message = [NSBundle tz_localizedStringForKey:@"Can not jump to the privacy settings page, please go to the settings page by self, thank you"];
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:[NSBundle tz_localizedStringForKey:@"Sorry"] message:message delegate:nil cancelButtonTitle:[NSBundle tz_localizedStringForKey:@"OK"] otherButtonTitles: nil];
                [alert show];
            }
        }
    }
}
#pragma mark ------- 延时调用隐藏提示视图 --------
- (void)hideVoiceIndicatorViewAfterDelay:(CGFloat)delay {
    if (self.recordHUDView.superview) {
        WEAK_SELF;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            STRONG_SELF;
            if (strongSelf->_recordHUDView.superview)
                [HQTipView hideTipView:strongSelf->_recordHUDView];
        });
    }
}
#pragma mark --------- Getter and Setter----------
- (HQChatBox *) chatBox{
    if (_chatBox == nil) {
        _chatBox = [[HQChatBox alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, HEIGHT_TABBAR)];
        _chatBox.delegate = self;
    }
    return _chatBox;
}
- (HQFaceListView *)faceListView{
    if (_faceListView == nil) {
        _faceListView = [[HQFaceListView alloc] initWithFrame:CGRectMake(0, HEIGHT_CHATBOXVIEW, App_Frame_Width, HEIGHT_CHATBOXVIEW)];
        _faceListView.delegate = self;
    }
    return _faceListView;
}
- (HQMoreListView *)moreListView{
    if (_moreListView == nil) {
        _moreListView = [[HQMoreListView alloc] initWithFrame:CGRectMake(0, HEIGHT_CHATBOXVIEW, App_Frame_Width, HEIGHT_CHATBOXVIEW)];
        _moreListView.delegate = self;
    }
    return _moreListView;
}
- (UIImagePickerController *)imagePickerVc {
    if (_imagePickerVc == nil) {
        _imagePickerVc = [[UIImagePickerController alloc] init];
        _imagePickerVc.delegate = self;
        // set appearance / 改变相册选择页的导航栏外观
        _imagePickerVc.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
        _imagePickerVc.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
        UIBarButtonItem *tzBarItem, *BarItem;
        if (iOS9Later) {
            //            tzBarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[TZImagePickerController class]]];
            //            BarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerController class]]];
        } else {
        }
        tzBarItem = [UIBarButtonItem appearanceWhenContainedIn:[self class], nil];
        BarItem = [UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil];
        NSDictionary *titleTextAttributes = [tzBarItem titleTextAttributesForState:UIControlStateNormal];
        [BarItem setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    }
    return _imagePickerVc;
}
- (HQRecordHUDView *)recordHUDView{
    if (_recordHUDView == nil) {
        _recordHUDView = [[[NSBundle mainBundle] loadNibNamed:@"HQRecordHUDView" owner:self options:nil] lastObject];
    }
    return _recordHUDView;
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
