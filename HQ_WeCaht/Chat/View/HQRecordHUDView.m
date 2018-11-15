//
//  HQRecordHUDView.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/1.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HQRecordHUDView.h"

#define HQVoiceNoteText_ToRecord @"手指上滑，取消发送"
#define HQVoiceNoteText_ToCancel @"松开手指，取消发送"
#define HQVoiceNoteText_TooShort @"说话时间太短"
#define HQVoiceNoteText_TooLong @"说话时间超长"
#define HQVoiceNoteText_VolumeTooLow @"请调大音量后播放"

#define ImageNamed_Cancel @"RecordCancel"
#define ImageNamed_TimeTooShortOrLong @"MessageTooShort"
#define ImageNamed_VolumeTooLow @"volume_smalltipsicon"

@interface HQRecordHUDView ()

@property (weak, nonatomic) IBOutlet UIImageView *begImageView;

@property (nonatomic) NSInteger countDown;
@property (weak, nonatomic) IBOutlet UILabel *countDownLabel;

@end


@implementation HQRecordHUDView{
    BOOL _canCancelByTouch;
}
@synthesize canCancelByTouch = _canCancelByTouch;


- (void)awakeFromNib{
    [super awakeFromNib];
    _countDown = 0;
}

- (void)setStyle:(HQVoiceIndicatorStyle)style{
    _style = style;
    if (_style == HQVoiceIndicatorStyleRecord) {
        self.begImageView.image = [UIImage imageNamed:@"voice_3"];
        self.countDownLabel.text = @"";
        self.canCancelByTouch = NO;
    }else if (_style == HQVoiceIndicatorStyleCancel){
        self.begImageView.image = [UIImage imageNamed:@"cancelVoice"];
        self.countDownLabel.text = @"";
        self.canCancelByTouch = NO;
    }else if (_style == HQVoiceIndicatorStyleTooShort){
        self.begImageView.image = [UIImage imageNamed:@"voiceShort"];
        self.countDownLabel.text = @"";
        self.canCancelByTouch = NO;
    }else if (_style == HQVoiceIndicatorStyleTooLong){
        self.countDownLabel.text = @"!";
        self.canCancelByTouch = YES;
    }else if (_style == HQVoiceIndicatorStyleVolumeTooLow){
        self.countDownLabel.text = @"^";
        self.canCancelByTouch = YES;
    }
}
- (void)setCountDown:(NSInteger)countDown{
    _countDown = countDown;
    if (_countDown < 0) {
         [self setStyle:HQVoiceIndicatorStyleTooLong];
    }else{
        self.countDownLabel.text = [NSString stringWithFormat:@"%ld",_countDown];
    }
    ///
}
//更新麦克风的音量大小
- (void)updateMetersValue:(CGFloat)value {
    NSInteger index = round(value);
    index = index > 6 ? 6 : index;
    index = index < 1 ? 1 : index;
    if (self.style == HQVoiceIndicatorStyleRecord) {
        NSString *imageName = [NSString stringWithFormat:@"voice_%ld", (long)index];
        self.begImageView.image = [UIImage imageNamed:imageName];
    }
}

- (void)didRemoveFromTipLayer {
//    self.countDown = 0;
}
@end
