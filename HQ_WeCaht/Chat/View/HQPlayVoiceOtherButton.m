//
//  HQPlayVoiceOtherButton.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/5.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HQPlayVoiceOtherButton.h"
#import "HQAudioPlayerManager.h"



@interface HQPlayVoiceOtherButton ()<HQAudioPlayDelegate>

@property (strong, nonatomic) NSArray *animationImagesArray;
@property (nonatomic,strong) UILabel *durationLabel;


@end


@implementation HQPlayVoiceOtherButton
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}
- (void)initialize{
    self.backgroundColor = [UIColor clearColor];

    _begImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    UIImage *image = [UIImage imageNamed:@"ReceiverTextNodeBkg"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height*0.5, image.size.width*0.5, image.size.width*0.5, image.size.width*0.5) resizingMode:UIImageResizingModeStretch];
    _begImageView.image = image;
    _begImageView.userInteractionEnabled = YES;
    UIImage *hightedImage = [UIImage imageNamed:@"ReceiverTextNodeBkgHL"];
    hightedImage = [hightedImage  resizableImageWithCapInsets:UIEdgeInsetsMake(hightedImage.size.height*0.5, hightedImage.size.width*0.5, hightedImage.size.width*0.5, hightedImage.size.width*0.5) resizingMode:UIImageResizingModeStretch];
    _begImageView.highlightedImage = hightedImage;
    [self addSubview:_begImageView];

    _contentButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 80, 40)];
    [_contentButton setImage:[UIImage imageNamed:@"ReceiverVoiceNodePlaying"] forState:UIControlStateNormal];
    [_contentButton addTarget:self action:@selector(playVoiceAction:) forControlEvents:UIControlEventTouchUpInside];
    _contentButton.backgroundColor = [UIColor clearColor];
    [_contentButton setImageEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    _contentButton.adjustsImageWhenHighlighted  = YES;
    _contentButton.imageView.animationDuration = 2.0;
    _contentButton.imageView.animationRepeatCount = 30;
    _contentButton.imageView.clipsToBounds = NO;
    _contentButton.imageView.contentMode = UIViewContentModeCenter;
    _contentButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self addSubview:_contentButton];

    _durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 40)];
    _durationLabel.backgroundColor = [UIColor clearColor];
    _durationLabel.font = [UIFont systemFontOfSize:13];
    _durationLabel.textColor = [UIColor colorWithRed:125/255.0 green:125/255.0 blue:125/255.0 alpha:1];
    _durationLabel.textAlignment = NSTextAlignmentLeft;
    _durationLabel.text = @"0\"";
    [self addSubview:_durationLabel];
}
- (void)setMessageModel:(ChatMessageModel *)messageModel{
    _messageModel = messageModel;
    _begImageView.width = _messageModel.chatImageRect.width;
    _contentButton.width = _messageModel.chatImageRect.width-20;
    _durationLabel.left = self.begImageView.right+2;
    if (_messageModel.fileSize.length != 0 || _messageModel.fileSize) {
        _durationLabel.text = [NSString stringWithFormat:@"%@\"",_messageModel.fileSize];
    }
    if (_messageModel.isPlaying) {
        [self startPlayBttonAnimations];
    }
}
- (void)playVoiceAction:(UIButton *)sender{
    if (self.contentButton.imageView.isAnimating) {
        [self stopPlayButtonAnimations];
        [[HQAudioPlayerManager sharedManager] stopPlaying];
    }else{
        [self startPlayBttonAnimations];
        [[HQAudioPlayerManager sharedManager] startPlayingWithPath:_messageModel.fileName delegate:self userinfo:nil continuePlaying:YES];
    }
}
- (void)startPlayBttonAnimations{
    if (self.contentButton.imageView.animationImages.count == 0) {
        self.contentButton.imageView.animationImages = self.animationImagesArray;
    }
    self.messageModel.isPlaying = YES;
    [self.contentButton.imageView startAnimating];
}
- (void)stopPlayButtonAnimations{
    self.messageModel.isPlaying = NO;
    [self.contentButton.imageView stopAnimating];
}
- (void)audioPlayDidStarted:(id)userinfo{
    NSLog(@"audioPlayDidStarted");
}
//播放录音时，系统声音太小
- (void)audioPlayVolumeTooLow{
    NSLog(@"audioPlayVolumeTooLow");
}
//发生播放错误时，播放Session同时结束
- (void)audioPlayDidFailed:(id)userinfo{
    NSLog(@"audioPlayDidFailed");
    [self stopPlayButtonAnimations];
}
//播放结束时考虑到连续播放的需求，仅仅停止了当前播放，没有
//停止播放session
- (void)audioPlayDidFinished:(id)userinfo{
    NSLog(@"audioPlayDidFinished");
    [self stopPlayButtonAnimations];
}
//播放停止时考虑到连续播放的需求，仅仅停止了当前播放，没有
//停止播放session
- (void)audioPlayDidStopped:(id)userinfo{
    NSLog(@"audioPlayDidStopped");
    [self stopPlayButtonAnimations];
}
///切换扬声器模式
- (void)changeSpeakerStatus{
    if (_delegate && [_delegate respondsToSelector:@selector(changeSpeakerStatus)]) {
        [_delegate changeSpeakerStatus];
    }
}
- (NSArray *)animationImagesArray{
    if (_animationImagesArray == nil) {
        _animationImagesArray = @[[UIImage imageNamed:@"ReceiverVoiceNodePlaying001"],
                                  [UIImage imageNamed:@"ReceiverVoiceNodePlaying002"],
                                  [UIImage imageNamed:@"ReceiverVoiceNodePlaying003"]
                                  ];
    }
    return _animationImagesArray;
}




@end
