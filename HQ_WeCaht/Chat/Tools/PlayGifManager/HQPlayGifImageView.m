//
//  HQPlayGifImageView.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/5/8.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQPlayGifImageView.h"
#import "HQGifPlayManager.h"
#import <QuartzCore/QuartzCore.h>
#import <ImageIO/ImageIO.h>


@interface HQPlayGifImageView (){
    size_t  _index;                    ////gif 总的帧数
    size_t  _frameCount;               ////当前播放的索引
    float _timestamp;                 ///播放时间
    float _currentProgress;           ///当前播放时间进度
    NSOperationQueue *_renderQueue;
}

@end

@implementation HQPlayGifImageView

- (void)removeFromSuperview{
    self.playingComplete = nil;
    [super removeFromSuperview];
    [self stopGifAnimation];
}
- (void)stopGifAnimation{
    [_renderQueue addOperationWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
//            [[HQGifPlayManager shareInstance] stopGIFAnimationViewWithFileName:self.fileName];
        });
    }];
}
- (void)startGifAnimationWithChatMessage:(ChatMessageModel *)message{
    _gifPixelSize = CGSizeZero;
    _index = message.gifPlyIndex;
    _frameCount = message.gifFrameCount;
    _timestamp = message.gifTimestamp;
    _currentProgress = message.currentPlayProgress;
    if (message.gifPlayQueue == nil) {
        message.gifPlayQueue = [[NSOperationQueue alloc] init];
        message.gifPlayQueue.maxConcurrentOperationCount = 1;
    }
    _renderQueue = message.gifPlayQueue;
    self.messageModel = message;
    self.image = message.tempImage;
    // 保证完全结束播放后，再开始新的播放
    [_renderQueue addOperationWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self startGIFWithImageName:message.fileName];
        });
    }];
}
- (void)startGIFWithImageName:(NSString *)fileName{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if (self.messageModel.sourseRef == nil) {
            CGImageSourceRef gifSourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)(self.messageModel.gifImageData), NULL);
            _gifPixelSize = [self GIFDimensionalSize:gifSourceRef];
            _frameCount = CGImageSourceGetCount(gifSourceRef);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!gifSourceRef) {
                    return;
                }
                if (![[HQGifPlayManager shareInstance].gifViewHashTable containsObject:self]) {
                    [[HQGifPlayManager shareInstance].gifViewHashTable addObject:self];
                }
                self.messageModel.sourseRef = gifSourceRef;
                self.messageModel.gifFrameCount = (int)_frameCount;
                if (![HQGifPlayManager shareInstance].displayLink) {
                    [HQGifPlayManager shareInstance].displayLink = [CADisplayLink displayLinkWithTarget:[HQGifPlayManager shareInstance] selector:@selector(playAllAnimationInMapTable)];
                    [[HQGifPlayManager shareInstance].displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
                }
            });
        }else{
            if (![[HQGifPlayManager shareInstance].gifViewHashTable containsObject:self]) {
                [[HQGifPlayManager shareInstance].gifViewHashTable addObject:self];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (![HQGifPlayManager shareInstance].displayLink) {
                    [HQGifPlayManager shareInstance].displayLink = [CADisplayLink displayLinkWithTarget:[HQGifPlayManager shareInstance] selector:@selector(playAllAnimationInMapTable)];
                    [[HQGifPlayManager shareInstance].displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
                }
            });
        }
    });
}
- (void)playCurrnetGifAnnimation{
    // 时间线达到当前帧，显示当前帧
    _frameCount = self.messageModel.gifFrameCount;
    _renderQueue = self.messageModel.gifPlayQueue;
    _timestamp = self.messageModel.gifTimestamp;
    _index = self.messageModel.gifPlyIndex;
    _currentProgress = self.messageModel.currentPlayProgress;
    CGImageSourceRef ref = self.messageModel.sourseRef;
    if (_frameCount == 0 || ref == nil) {
        return;
    }
    if (_timestamp >= _currentProgress) {
        if(_renderQueue.operationCount<=0) {
            [_renderQueue addOperationWithBlock:^{
                CGImageRef imageRef = CGImageSourceCreateImageAtIndex(ref, _index%_frameCount, NULL);
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.image = self.messageModel.tempImage = [UIImage imageWithCGImage:imageRef];
                    CGImageRelease(imageRef);
                });
            }];
        }else {
            NSLog(@"faild");
        }
        // 将下一帧更新为当前帧
        _index ++;
        self.messageModel.gifPlyIndex = (int)_index;
        float nextFrameDuration = [self frameDurationAtIndex:_index%_frameCount];
        self.messageModel.currentPlayProgress = _currentProgress += nextFrameDuration;
        // 声明本次播放结束
        if (_index%_frameCount == 0) {
            if (self.playingComplete) self.playingComplete();
            // 未开启重复播放，完成后停止
            if (self.unRepeat){
                [self stopGifAnimation];
                return;
            }
        }
    }
    self.messageModel.gifTimestamp = _timestamp += [HQGifPlayManager shareInstance].displayLink.duration;
}
- (BOOL)isGIFPlaying{
    return self.messageModel.sourseRef?YES:NO;
}
- (float)frameDurationAtIndex:(size_t)index{
//    CGImageSourceRef ref = (__bridge CGImageSourceRef)([[HQGifPlayManager shareInstance].gifSourceRefMapTable objectForKey:self.messageModel.fileName]);
    CGImageSourceRef ref = self.messageModel.sourseRef;
    if (ref == nil) {
        return 0;
    }
    CFDictionaryRef dictRef = CGImageSourceCopyPropertiesAtIndex(ref, index, NULL);
    NSDictionary *dict = (__bridge NSDictionary *)dictRef;
    NSDictionary *gifDict = (dict[(NSString *)kCGImagePropertyGIFDictionary]);
    NSNumber *unclampedDelayTime = gifDict[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    NSNumber *delayTime = gifDict[(NSString *)kCGImagePropertyGIFDelayTime];
    CFRelease(dictRef);
    if (unclampedDelayTime.floatValue) {
        return unclampedDelayTime.floatValue;
    }else if (delayTime.floatValue) {
        return delayTime.floatValue;
    }else{
        return 1/24.0;
    }
}
- (CGSize)GIFDimensionalSize:(CGImageSourceRef)imgSourceRef{
    if(!imgSourceRef){
        return CGSizeZero;
    }
    CFDictionaryRef dictRef = CGImageSourceCopyPropertiesAtIndex(imgSourceRef, 0, NULL);
    NSDictionary *dict = (__bridge NSDictionary *)dictRef;
    
    NSNumber* pixelWidth = (dict[(NSString*)kCGImagePropertyPixelWidth]);
    NSNumber* pixelHeight = (dict[(NSString*)kCGImagePropertyPixelHeight]);
    
    CGSize sizeAsInProperties = CGSizeMake([pixelWidth floatValue], [pixelHeight floatValue]);
    
    CFRelease(dictRef);
    
    return sizeAsInProperties;
}

@end
