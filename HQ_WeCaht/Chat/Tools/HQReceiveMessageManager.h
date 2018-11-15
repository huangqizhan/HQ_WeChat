//
//  HQReceiveMessageManager.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/13.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HQReceiveMessageManager : NSObject


+ (instancetype)shareInstance;


/**
 接收消息队列
 */
@property (nonatomic,readonly,retain) dispatch_queue_t queue;





@end
