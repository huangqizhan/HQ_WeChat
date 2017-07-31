//
//  HQPlayVoiceMineButton.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/5.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HQPlayVoiceMineButtonDelegate <NSObject>

- (void)changeSpeakerStatus;

@end



@interface HQPlayVoiceMineButton : UIView


@property (nonatomic,assign) id <HQPlayVoiceMineButtonDelegate>delegate;
////背景图片
@property (nonatomic,strong) UIImageView *begImageView;
////播放按钮
@property (nonatomic,strong) UIButton *contentButton;
////消息体
@property (nonatomic,strong)ChatMessageModel *messageModel;


@end



//@interface HQPlayVoiceOtherButton : UIView
//
////@property (nonatomic,assign) id <HQPlayVoiceMineButtonDelegate>delegate;
//////背景图片
//@property (nonatomic,strong) UIImageView *begImageView;
//////播放按钮
//@property (nonatomic,strong) UIButton *contentButton;
//////消息体
//@property (nonatomic,strong)ChatMessageModel *messageModel;
//
//
//@end



//@interface TestView : UIView
//
//@end
