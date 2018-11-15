//
//  AnimatedImageView.h
//  YYStudyDemo
//
//  Created by hqz  QQ 757618403 on 2018/7/4.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN


/**
 在播放之前会有一个异步的操作 来填充每一帧的动画数据   填充完之后 就会开始播放
 每一个animatedImageView 都会有一个 CADisplayLink 屏幕刷新定时器 来刷新播放下一帧数据 
 */
@interface AnimatedImageView : UIImageView
///是否自动播放
@property (nonatomic) BOOL autoPlayAnimatedImage;
///提前解析数据
@property (nonatomic) NSUInteger currentAnimatedImageIndex;
///当前是否在播放
@property (nonatomic, readonly) BOOL currentIsPlayingAnimation;
///当前runloop
@property (nonatomic, copy) NSString *runloopMode;
///当前最大size
@property (nonatomic) NSUInteger maxBufferSize;
@end

@protocol YYAnimatedImage <NSObject>
@required
///总帧数
- (NSUInteger)animatedImageFrameCount;
///已经播的次数
- (NSUInteger)animatedImageLoopCount;
///每帧的size
- (NSUInteger)animatedImageBytesPerFrame;
///index frame
- (nullable UIImage *)animatedImageFrameAtIndex:(NSUInteger)index;
///每一帧的播放时间
- (NSTimeInterval)animatedImageDurationAtIndex:(NSUInteger)index;

@optional

///每一帧的frame
- (CGRect)animatedImageContentsRectAtIndex:(NSUInteger)index;


@end

NS_ASSUME_NONNULL_END
