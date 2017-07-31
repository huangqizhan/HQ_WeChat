//
//  HQPlayGifImageView.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/5/8.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatMessageModel+Action.h"

@interface HQPlayGifImageView : UIImageView


@property (nonatomic,strong) ChatMessageModel *messageModel;
/////GIF 文件名
//@property (nonatomic,copy) NSString *fileName;
///////gif 数据
//@property (nonatomic, strong) NSData *gifData;
////size
@property (nonatomic, assign, readonly) CGSize  gifPixelSize;
@property (nonatomic, assign) BOOL unRepeat;
////播放完成回调
@property (copy, nonatomic) void(^playingComplete)();

////tableView cell 调用GIF开始播放
- (void)startGifAnimationWithChatMessage:(ChatMessageModel *)message;

///停止播放
- (void)stopGifAnimation;

////播放当前GIF
- (void)playCurrnetGifAnnimation;

@end
