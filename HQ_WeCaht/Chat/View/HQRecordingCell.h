//
//  HQRecordingCell.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/5.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HQChatMineBaseCell.h"


@interface HQRecordingCell : HQChatMineBaseCell

///跟新录音时间
- (void)updateDurationLabel:(int)duration;
///录音结束后更新界面
- (void)removeAnimationAndUpdateVoiceCell:(void (^)())complite;
///回置原来的状态
- (void)resetRecordingOrigeStatus;


@end
