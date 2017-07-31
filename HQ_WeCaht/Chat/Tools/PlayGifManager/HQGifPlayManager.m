//
//  HQGifPlayManager.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/5/8.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQGifPlayManager.h"

@implementation HQGifPlayManager

+ (instancetype)shareInstance{
    static HQGifPlayManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[HQGifPlayManager alloc] init];
    });
    return _sharedInstance;
}
- (id)init{
    self = [super init];
    if (self) {
        _gifViewHashTable = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory];
    }
    return self;
}
- (void)playAllAnimationInMapTable{
    if (_gifViewHashTable.allObjects.count ==0 ) {
        [self stopDisplayLink];
    }
    @try {
        for (HQPlayGifImageView *imageView in _gifViewHashTable) {
            [imageView performSelector:@selector(playCurrnetGifAnnimation)];
        }
    } @catch (NSException *exception) {
        
    }
}
- (void)stopDisplayLink{
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}
- (void)stopAllGIFAnimationView{
    [_gifViewHashTable removeAllObjects];
    [self stopDisplayLink];
    NSLog(@"stopGIFView");
}
///暂停
- (void)pauseAllAnimation{
    self.displayLink.paused = YES;
}
///暂停后重新播放
- (void)restartAllAnimaiton{
    self.displayLink.paused = NO;
}
@end
