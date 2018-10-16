//
//  AnimatedImageView.h
//  YYStudyDemo
//
//  Created by hqz on 2018/7/4.
//  Copyright © 2018年 hqz. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN


/**
 在播放之前会有一个异步的操作 来填充每一帧的动画数据   填充完之后 就会开始播放
 每一个animatedImageView 都会有一个 CADisplayLink 屏幕刷新定时器 来刷新播放下一帧数据 
 */
@interface AnimatedImageView : UIImageView

/**
 If the image has more than one frame, set this value to `YES` will automatically
 play/stop the animation when the view become visible/invisible.
 
 The default value is `YES`.
 */
@property (nonatomic) BOOL autoPlayAnimatedImage;

/**
 Index of the currently displayed frame (index from 0).
 
 Set a new value to this property will cause to display the new frame immediately.
 If the new value is invalid, this method has no effect.
 
 You can add an observer to this property to observe the playing status.
 */
@property (nonatomic) NSUInteger currentAnimatedImageIndex;

/**
 Whether the image view is playing animation currently.
 
 You can add an observer to this property to observe the playing status.
 */
@property (nonatomic, readonly) BOOL currentIsPlayingAnimation;

/**
 The animation timer's runloop mode, default is `NSRunLoopCommonModes`.
 
 Set this property to `NSDefaultRunLoopMode` will make the animation pause during
 UIScrollView scrolling.
 */
@property (nonatomic, copy) NSString *runloopMode;

/**
 The max size (in bytes) for inner frame buffer size, default is 0 (dynamically).
 
 When the device has enough free memory, this view will request and decode some or
 all future frame image into an inner buffer. If this property's value is 0, then
 the max buffer size will be dynamically adjusted based on the current state of
 the device free memory. Otherwise, the buffer size will be limited by this value.
 
 When receive memory warning or app enter background, the buffer will be released
 immediately, and may grow back at the right time.
 */
@property (nonatomic) NSUInteger maxBufferSize;
@end

@protocol YYAnimatedImage <NSObject>
@required
/// Total animated frame count.
/// It the frame count is less than 1, then the methods below will be ignored.
- (NSUInteger)animatedImageFrameCount;

/// Animation loop count, 0 means infinite looping.
- (NSUInteger)animatedImageLoopCount;

/// Bytes per frame (in memory). It may used to optimize memory buffer size.
- (NSUInteger)animatedImageBytesPerFrame;

/// Returns the frame image from a specified index.
/// This method may be called on background thread.
/// @param index  Frame index (zero based).
- (nullable UIImage *)animatedImageFrameAtIndex:(NSUInteger)index;

/// Returns the frames's duration from a specified index.
/// @param index  Frame index (zero based).
- (NSTimeInterval)animatedImageDurationAtIndex:(NSUInteger)index;

@optional
/// A rectangle in image coordinates defining the subrectangle of the image that
/// will be displayed. The rectangle should not outside the image's bounds.
/// It may used to display sprite animation with a single image (sprite sheet).
- (CGRect)animatedImageContentsRectAtIndex:(NSUInteger)index;


@end

NS_ASSUME_NONNULL_END
