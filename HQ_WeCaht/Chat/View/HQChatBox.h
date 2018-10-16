//
//  HQChatBox.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/1.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HQChatTextView.h"




@class HQChatBox;
@protocol HQChatBoxDelegate <NSObject>

@optional
/**
 *  输入框状态(位置)改变
 *
 *  @param chatBox    chatBox
 *  @param fromStatus 起始状态
 *  @param toStatus   目的状态
 */
- (void)chatBox:(HQChatBox *)chatBox changeStatusForm:(HQChatBoxStatus)fromStatus to:(HQChatBoxStatus)toStatus;

/**
 *  发送消息
 *
 *  @param chatBox     chatBox
 *  @param textMessage 消息
 */
- (void)chatBox:(HQChatBox *)chatBox sendTextMessage:(NSString *)textMessage;

/**
 *  输入框高度改变
 *
 *  @param chatBox chatBox
 *  @param height  height
 */
- (void)chatBox:(HQChatBox *)chatBox changeChatBoxHeight:(CGFloat)height;

/**
 *  开始录音
 *
 *  @param chatBox chatBox
 */
- (void)chatBoxDidStartRecordingVoice:(HQChatBox *)chatBox;

/**
 结束录音

 @param chatBox self
 */
- (void)chatBoxDidStopRecordingVoice:(HQChatBox *)chatBox;

/**
 取消录音

 @param chatBox self
 */
- (void)chatBoxDidCancelRecordingVoice:(HQChatBox *)chatBox;

/**
 移动的状态

 @param inside 1在里面   0在外面
 */
- (void)chatBoxDidDrag:(BOOL)inside;

/**
  录音太短
 */
- (void)chatBoxRecordTooShort;

@end



@interface HQChatBox : UIView <UITextViewDelegate>

@property (nonatomic,assign) id <HQChatBoxDelegate>delegate;

///输入框状态
@property (nonatomic,assign) HQChatBoxStatus boxStatus;

///输入框
@property (nonatomic,strong) HQChatTextView *textView;

//当录音时间过长时，由APP主动取消录音按钮的按压事件，结束录音

- (void)cancelRecordButtonTouchEvent ;

@end
