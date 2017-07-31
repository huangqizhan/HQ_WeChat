//
//  HQGifPlayManager.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/5/8.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HQPlayGifImageView.h"

@interface HQGifPlayManager : NSObject

+ (instancetype)shareInstance;

///界面刷新定时器
@property (nonatomic, strong) CADisplayLink  *displayLink;
////week 数组存放 cell
@property (nonatomic, strong) NSHashTable  *gifViewHashTable;

///清除所有的GIF动画
- (void)stopAllGIFAnimationView;

///开始播放所有的GIF
- (void)playAllAnimationInMapTable;

///暂停
- (void)pauseAllAnimation;

///暂停后重新播放
- (void)restartAllAnimaiton;

@end
