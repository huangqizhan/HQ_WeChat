//
//  HQChatBox.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/1.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQChatBox.h"
#import "HQRecordManager.h"




@interface HQChatBox ()<HQTextViewDelegate>{
    dispatch_block_t _block;
    UIEvent *_recordEvent;
    CFTimeInterval _touchDownTime;
    BOOL _canBecomeFirstResponder;
}

/** chotBox的顶部边线 */
@property (nonatomic, strong) UIView *topLine;
/** 录音按钮 */
@property (nonatomic, strong) UIButton *voiceButton;
/** 表情按钮 */
@property (nonatomic, strong) UIButton *faceButton;
/** (+)按钮 */
@property (nonatomic, strong) UIButton *moreButton;
/** 按住说话 */
@property (nonatomic, strong) UIButton *talkButton;
///录音许可
@property (nonatomic) BOOL recordPermissionGranted;



@end

@implementation HQChatBox

- (id) initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:IColor(241, 241, 248)];
        [self addSubview:self.topLine];
        [self addSubview:self.voiceButton];
        [self addSubview:self.textView];
        [self addSubview:self.faceButton];
        [self addSubview:self.moreButton];
        [self addSubview:self.talkButton];
        self.boxStatus = HQChatBoxStatusNothing; // 起始状态
//        [self addNotification];
    }
    return self;
}

#pragma mark - Getter and Setter

- (UIView *) topLine{
    if (_topLine == nil) {
        _topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0.5)];
        [_topLine setBackgroundColor:IColor(165, 165, 165)];
    }
    return _topLine;
}

- (UIButton *) voiceButton{
    if (_voiceButton == nil) {
        _voiceButton = [[UIButton alloc] initWithFrame:CGRectMake(0, (HEIGHT_TABBAR - CHATBOX_BUTTON_WIDTH) / 2, CHATBOX_BUTTON_WIDTH, CHATBOX_BUTTON_WIDTH)];
        [_voiceButton setImage:[UIImage imageNamed:@"ToolViewInputVoice"] forState:UIControlStateNormal];
        [_voiceButton setImage:[UIImage imageNamed:@"ToolViewInputVoiceHL"] forState:UIControlStateHighlighted];
        [_voiceButton addTarget:self action:@selector(voiceButtonDown:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _voiceButton;
}

- (UIButton *) moreButton{
    if (_moreButton == nil) {
        _moreButton = [[UIButton alloc] initWithFrame:CGRectMake(App_Frame_Width - CHATBOX_BUTTON_WIDTH, (HEIGHT_TABBAR - CHATBOX_BUTTON_WIDTH) / 2, CHATBOX_BUTTON_WIDTH, CHATBOX_BUTTON_WIDTH)];
        [_moreButton setImage:[UIImage imageNamed:@"TypeSelectorBtn_Black"] forState:UIControlStateNormal];
        [_moreButton setImage:[UIImage imageNamed:@"TypeSelectorBtnHL_Black"] forState:UIControlStateHighlighted];
        [_moreButton addTarget:self action:@selector(moreButtonDown:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreButton;
}

- (UIButton *) faceButton
{
    if (_faceButton == nil) {
        _faceButton = [[UIButton alloc] initWithFrame:CGRectMake(self.moreButton.x - CHATBOX_BUTTON_WIDTH, (HEIGHT_TABBAR - CHATBOX_BUTTON_WIDTH) / 2, CHATBOX_BUTTON_WIDTH, CHATBOX_BUTTON_WIDTH)];
        [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:UIControlStateNormal];
        [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotionHL"] forState:UIControlStateHighlighted];
        [_faceButton addTarget:self action:@selector(faceButtonDown:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _faceButton;
}

- (UITextView *) textView
{
    if (_textView == nil) {
        _textView = [[HQChatTextView alloc] initWithFrame:self.talkButton.frame];
        [_textView setFont:[UIFont systemFontOfSize:16.0f]];
        [_textView.layer setMasksToBounds:YES];
        [_textView.layer setCornerRadius:4.0f];
        [_textView.layer setBorderWidth:0.5f];
        [_textView.layer setBorderColor:self.topLine.backgroundColor.CGColor];
        [_textView setScrollsToTop:NO];
        [_textView setReturnKeyType:UIReturnKeySend];
        [_textView setDelegate:self];
        [_textView setCusDelegate:self];
    }
    return _textView;
}

- (UIButton *) talkButton{
    if (_talkButton == nil) {
        _talkButton = [[UIButton alloc] initWithFrame:CGRectMake(self.voiceButton.x + self.voiceButton.width + 4, self.height * 0.13, self.faceButton.x - self.voiceButton.x - self.voiceButton.width - 8, HEIGHT_TEXTVIEW)];
        [_talkButton setTitle:@"按住 说话" forState:UIControlStateNormal];
        [_talkButton setTitleColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0] forState:UIControlStateNormal];
        [_talkButton setBackgroundImage:[UIImage gxz_imageWithColor:[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:0.5]] forState:UIControlStateHighlighted];
        [_talkButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
        [_talkButton.layer setMasksToBounds:YES];
        [_talkButton.layer setCornerRadius:4.0f];
        [_talkButton.layer setBorderWidth:0.5f];
        [_talkButton.layer setBorderColor:self.topLine.backgroundColor.CGColor];
        [_talkButton setHidden:YES];
        [_talkButton addTarget:self action:@selector(talkButtonDown:) forControlEvents:UIControlEventTouchDown];
        [_talkButton addTarget:self action:@selector(talkButtonUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [_talkButton addTarget:self action:@selector(talkButtonUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
        [_talkButton addTarget:self action:@selector(talkButtonTouchCancel:) forControlEvents:UIControlEventTouchCancel];
        [_talkButton addTarget:self action:@selector(talkButtonDragOutside:) forControlEvents:UIControlEventTouchDragOutside];
        [_talkButton addTarget:self action:@selector(talkButtonDragInside:) forControlEvents:UIControlEventTouchDragInside];
    }
    return _talkButton;
}

#pragma mark ----------- UITextViewDelegate ---------

- (void) textViewDidBeginEditing:(UITextView *)textView{
    self.boxStatus = HQChatBoxStatusShowKeyboard;
}
- (void) textViewDidChange:(UITextView *)textView{
//    CGFloat height = [textView sizeThatFits:CGSizeMake(self.textView.width, MAXFLOAT)].height;
    if (textView.text.length > 5000) { // 限制5000字内
        textView.text = [textView.text substringToIndex:5000];
    }
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){
        if (self.textView.text.length > 0) {
            if (_delegate && [_delegate respondsToSelector:@selector(chatBox:sendTextMessage:)]) {
                [_delegate chatBox:self sendTextMessage:self.textView.text];
            }
        }
        [self.textView setText:@""];
        return NO;
    }
    return YES;
}
- (void)HQTextView:(HQTextView *)textView textViewHeightDidChange:(CGFloat)height{
    self.height = height+ (HEIGHT_TABBAR-HEIGHT_TEXTVIEW);
    if (_delegate && [_delegate respondsToSelector:@selector(chatBox:changeChatBoxHeight:)]) {
        [_delegate chatBox:self changeChatBoxHeight:self.height];
    }
}
- (void)setBoxStatus:(HQChatBoxStatus)boxStatus{
    _boxStatus = boxStatus;
}
#pragma mark - Event Response

// 录音按钮点击事件
- (void) voiceButtonDown:(UIButton *)sender{
    HQChatBoxStatus lastStatus = self.boxStatus;
    if (lastStatus == HQChatBoxStatusShowVoice) {//正在显示talkButton，改为键盘状态
        [self.talkButton setHidden:YES];
        [self.textView setHidden:NO];
        [self.textView becomeFirstResponder];
        [_voiceButton setImage:[UIImage imageNamed:@"ToolViewInputVoice"] forState:UIControlStateNormal];
        self.boxStatus = HQChatBoxStatusShowKeyboard;
    }else{     //变成talkButton的状态
        [self.textView resignFirstResponder];
        [self.textView setHidden:YES];
        [self.talkButton setHidden:NO];
        [_voiceButton setImage:[UIImage imageNamed:@"ToolViewKeyboard"] forState:UIControlStateNormal];
        self.boxStatus = HQChatBoxStatusShowVoice;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(chatBox:changeStatusForm:to:)]) {
        [_delegate chatBox:self changeStatusForm:lastStatus to:self.boxStatus];
    }
}
// 更多（+）按钮
- (void) moreButtonDown:(UIButton *)sender{
    HQChatBoxStatus lastStatus = self.boxStatus;
    if (lastStatus == HQChatBoxStatusShowMore) { // 当前显示的就是more页面
        self.boxStatus = HQChatBoxStatusShowKeyboard;
        [self.textView becomeFirstResponder];
    } else {
        [self.talkButton setHidden:YES];
        [self.textView setHidden:NO];
        [_voiceButton setImage:[UIImage imageNamed:@"ToolViewInputVoice"] forState:UIControlStateNormal];
        
        self.boxStatus = HQChatBoxStatusShowMore;
        if (lastStatus == HQChatBoxStatusShowFace) {  // 改变按钮样式
            [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:UIControlStateNormal];
        } else if (lastStatus == HQChatBoxStatusShowVoice) {
            [_talkButton setHidden:YES];
            [_textView setHidden:NO];
            [_voiceButton setImage:[UIImage imageNamed:@"ToolViewInputVoice"] forState:UIControlStateNormal];
        } else if (lastStatus == HQChatBoxStatusShowKeyboard) {
            [self.textView resignFirstResponder];
            self.boxStatus = HQChatBoxStatusShowMore;
        }
    }
    if (_delegate && [_delegate respondsToSelector:@selector(chatBox:changeStatusForm:to:)]) {
        [_delegate chatBox:self changeStatusForm:lastStatus to:self.boxStatus];
    }
}

// 表情按钮
- (void) faceButtonDown:(UIButton *)sender{
    HQChatBoxStatus lastStatus = self.boxStatus;
    if (lastStatus == HQChatBoxStatusShowFace) {       // 正在显示表情,改为现实键盘状态
        self.boxStatus = HQChatBoxStatusShowKeyboard;
        [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:UIControlStateNormal];
        [self.textView becomeFirstResponder];
    } else {
        [self.talkButton setHidden:YES];
        [self.textView setHidden:NO];
        [_voiceButton setImage:[UIImage imageNamed:@"ToolViewInputVoice"] forState:UIControlStateNormal];
        self.boxStatus = HQChatBoxStatusShowFace;
        [_faceButton setImage:[UIImage imageNamed:@"ToolViewKeyboard"] forState:UIControlStateNormal];
        if (lastStatus == HQChatBoxStatusShowMore) {
        } else if (lastStatus == HQChatBoxStatusShowVoice) {
            [_voiceButton setImage:[UIImage imageNamed:@"ToolViewInputVoice"] forState:UIControlStateNormal];
            [_talkButton setHidden:YES];
            [_textView setHidden:NO];
        }  else if (lastStatus == HQChatBoxStatusShowKeyboard) {
            [self.textView resignFirstResponder];
            self.boxStatus = HQChatBoxStatusShowFace;
        } else if (lastStatus == HQChatBoxStatusShowVoice) {
            [self.talkButton setHidden:YES];
            [self.textView setHidden:NO];
            [_voiceButton setImage:[UIImage imageNamed:@"ToolViewInputVoice"] forState:UIControlStateNormal];
            self.boxStatus = HQChatBoxStatusShowFace;
        }
        
    }
    if (_delegate && [_delegate respondsToSelector:@selector(chatBox:changeStatusForm:to:)]) {
        [_delegate chatBox:self changeStatusForm:lastStatus to:self.boxStatus];
    }
}

#pragma mark ------- 开始录音 ------
- (void)talkButtonDown:(UIButton *)sender{
    WEAKSELF;
    self.recordPermissionGranted = NO;
    __block BOOL firstUseMicrophone = NO;
    [[HQRecordManager sharedManager] requestRecordPermission:^(AVAudioSessionRecordPermission recordPermission) {
        if (recordPermission == AVAudioSessionRecordPermissionUndetermined) {
            firstUseMicrophone = YES;
        }else if (recordPermission == AVAudioSessionRecordPermissionGranted) {
            //第一次录音时，会请求麦克风权限。
            //1、用户抬离手指后同意访问麦克风，这种情况不继续录音，因为用户已经离开录音按钮了
            //2、用户保持手指按压录音按钮，用其他手指同意访问麦克风，则从获取授权的时间点开始录音
            if (!firstUseMicrophone || ![weakSelf recordButtonTouchEventEnded]) {
                weakSelf.recordPermissionGranted = YES;
                [weakSelf setRecordButtonBackground:YES];
                STRONG_SELF;
                
                strongSelf->_touchDownTime = CACurrentMediaTime();
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(chatBoxDidStartRecordingVoice:)]) {
                    strongSelf->_block = dispatch_block_create(0, ^{
                        [weakSelf setRecordButtonTitle:YES];
                        [weakSelf.delegate chatBoxDidStartRecordingVoice:self];
                    });
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), strongSelf->_block);
                }
            }
        }
    }];
}
#pragma mark -------- 结束录音 -------
- (void)talkButtonUpInside:(UIButton *)sender{
    if (!self.recordPermissionGranted)
        return;
    CFTimeInterval currentTime = CACurrentMediaTime();
    if (currentTime - _touchDownTime < MIN_RECORD_TIME_REQUIRED + 0.25) {
        self.talkButton.enabled = NO;
        if (!dispatch_block_testcancel(_block))
            dispatch_block_cancel(_block);
        _block = nil;
        
        if ([self.delegate respondsToSelector:@selector(chatBoxRecordTooShort)]) {
            [self.delegate chatBoxRecordTooShort];
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MIN_RECORD_TIME_REQUIRED * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.talkButton.enabled = YES;
            [self recordActionEnd];
        });
    }else{
        [self recordActionEnd];
        if ([self.delegate respondsToSelector:@selector(chatBoxDidStopRecordingVoice:)]) {
            [self.delegate chatBoxDidStopRecordingVoice:self];
        }
    }
}
#pragma mark----- 取消录音 -----
- (void)talkButtonUpOutside:(UIButton *)sender{
    if (!self.recordPermissionGranted)
        return;
    if (!dispatch_block_testcancel(_block))
        dispatch_block_cancel(_block);
    _block = nil;
     [self recordActionEnd];
    if (_delegate && [_delegate respondsToSelector:@selector(chatBoxDidCancelRecordingVoice:)]) {
        [_delegate chatBoxDidCancelRecordingVoice:self];
    }
}
////拖拽到外面
- (void)talkButtonDragOutside:(UIButton *)sender{
    [self setRecordButtonTitilIsCancel:YES];
    if (!self.recordPermissionGranted)
        return;
    if ([_delegate respondsToSelector:@selector(chatBoxDidDrag:)]) {
        [_delegate chatBoxDidDrag:NO];
    }
}
///拖拽到里面
- (void)talkButtonDragInside:(UIButton *)sender{
    [self setRecordButtonTitilIsCancel:NO];
    if (!self.recordPermissionGranted)
        return;
    if ([_delegate respondsToSelector:@selector(chatBoxDidDrag:)]) {
        [_delegate chatBoxDidDrag:YES];
    }
}
- (void)talkButtonTouchCancel:(UIButton *)sender{
    if (!self.recordPermissionGranted)
        return;
    [self talkButtonDragInside:sender];
}

- (void)recordActionEnd {
    [self setRecordButtonTitle:NO];
    [self setRecordButtonBackground:NO];
    _recordEvent = nil;
}
- (void)cancelRecordButtonTouchEvent {
    [self.voiceButton cancelTrackingWithEvent:nil];
    [self recordActionEnd];
}

- (void)setRecordButtonTitle:(BOOL)isRecording {
    if (isRecording) {
        [self.talkButton setTitle:@"松开 结束" forState:UIControlStateNormal];
    }else {
        [self.talkButton setTitle:@"按住 说话" forState:UIControlStateNormal];
    }
}
- (void)setRecordButtonTitilIsCancel:(BOOL)isCancel{
    if (isCancel) {
        [self.talkButton setTitle:@"松开 取消" forState:UIControlStateNormal];
    }else{
        [self.talkButton setTitle:@"松开 结束" forState:UIControlStateNormal];
    }
}
- (void)setRecordButtonBackground:(BOOL)isRecording {
    if (isRecording) {
        self.talkButton.backgroundColor = UIColorHexRGB(@"#C6C7CB");
    }else {
        self.talkButton.backgroundColor = UIColorHexRGB(@"#F3F4F8");
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self.talkButton) {
        _recordEvent = event;
    }
//    else if (view == self.textView) {
//        _canBecomeFirstResponder = YES;
//    }
    return view;
}

#pragma mark - Private

- (void)emotionDidSelected:(NSNotification *)notifi{
//    XZEmotion *emotion = notifi.userInfo[GXSelectEmotionKey];
//    if (emotion.code) {
//        [self.textView insertText:emotion.code.emoji];
//        [self.textView scrollRangeToVisible:NSMakeRange(self.textView.text.length, 0)];
//    } else if (emotion.face_name) {
//        [self.textView insertText:emotion.face_name];
//    }
}

// 删除
- (void)deleteBtnClicked{
    [self.textView deleteBackward];
}

- (void)sendMessage{
    if (self.textView.text.length > 0) {     // send Text
        if (_delegate && [_delegate respondsToSelector:@selector(chatBox:sendTextMessage:)]) {
            [_delegate chatBox:self sendTextMessage:self.textView.text];
        }
    }
    [self.textView setText:@""];
}

#pragma mark - Public Methods

- (BOOL)resignFirstResponder{
    [self.textView resignFirstResponder];
    [_moreButton setImage:[UIImage imageNamed:@"TypeSelectorBtn_Black"] forState:UIControlStateNormal];
    [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:UIControlStateNormal];
    return [super resignFirstResponder];
}
- (BOOL)recordButtonTouchEventEnded {
    UITouch *touch = [_recordEvent.allTouches anyObject];
    if (touch == nil || touch.phase == UITouchPhaseCancelled || touch.phase == UITouchPhaseEnded) {
        return YES;
    }
    
    return NO;
}
@end
