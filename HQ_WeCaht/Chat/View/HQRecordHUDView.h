//
//  HQRecordHUDView.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/1.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HQTipView.h"


typedef NS_ENUM(NSInteger, HQVoiceIndicatorStyle) {
    HQVoiceIndicatorStyleRecord = 0,
    HQVoiceIndicatorStyleCancel,
    HQVoiceIndicatorStyleTooShort,
    HQVoiceIndicatorStyleTooLong,
    HQVoiceIndicatorStyleVolumeTooLow, 
};

@interface HQRecordHUDView : UIView <HQTipViewDelegate>

@property (nonatomic) HQVoiceIndicatorStyle style;

- (void)setCountDown:(NSInteger)countDown;

- (void)updateMetersValue:(CGFloat)value;



@end
