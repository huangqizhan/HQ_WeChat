//
//  HQReceiveMessageManager.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/13.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HQReceiveMessageManager.h"
#import "ChatMessageModel+Action.h"
#import "AppDelegate.h"
#import "HQTabBarViewController.h"
#import "HQAudioTools.h"
#import "NSDate+Extension.h"


@interface HQReceiveMessageManager ()

@property (nonatomic,strong) NSOperationQueue *receiveMessageQueue;
@property (nonatomic,assign) NSTimeInterval lastSoundTime;

@end


@implementation HQReceiveMessageManager


+ (instancetype)shareInstance{
    static HQReceiveMessageManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HQReceiveMessageManager alloc] init];
    });
    return manager;
}
- (instancetype)init{
    self = [super init];
    if (self) {
        _receiveMessageQueue = [[NSOperationQueue alloc] init];
        ///一次执行一个操作
        _receiveMessageQueue.maxConcurrentOperationCount = 1;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReceiveMessage:) name:NotificationReceiveNewMessageNotification object:nil];
        _lastSoundTime = [NSDate returnTheTimeralFrom1970NoScale];
    }
    return self;
}

- (void)handleReceiveMessage:(NSNotification *)info{
    HQTabBarViewController *tabbar = (HQTabBarViewController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    NSDictionary *diction = info.object;
    [_receiveMessageQueue addOperationWithBlock:^{
        ChatMessageModel *message = [ChatMessageModel creatAnReceiveTextMessageWith:[diction objectForKey:@"contentString"] andSpeakerId:[[diction objectForKey:@"speakerId"] integerValue] andUserName:[diction objectForKey:@"userName"] andUserPic:[diction objectForKey:@"userHeadImageString"]];
        [message saveToDBChatListModelOnMainThread:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (([NSDate returnTheTimeralFrom1970NoScale] - _lastSoundTime) > 1) {
                    _lastSoundTime = [NSDate returnTheTimeralFrom1970NoScale];
                    [HQAudioTools playNewMessageSound];
                }
                [tabbar receiveNewMessage:message];
            });
        } andError:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (([NSDate returnTheTimeralFrom1970NoScale] - _lastSoundTime) > 1) {
                    _lastSoundTime = [NSDate returnTheTimeralFrom1970NoScale];
                    [HQAudioTools playNewMessageSound];
                }
                [tabbar receiveNewMessage:message];
            });
        }];

    }];
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationReceiveNewMessageNotification object:nil];
}
@end
