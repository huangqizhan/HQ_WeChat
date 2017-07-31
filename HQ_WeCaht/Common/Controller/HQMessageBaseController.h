//
//  HQMessageBaseController.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/8.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQBaseViewController.h"

@interface HQMessageBaseController : HQBaseViewController


///消息分发
- (void)messageHandleWith:(ChatMessageModel *)messageModel;

///界面跳转
- (void)contactPushToChatViewControllerWith:(HQMessageBaseController *)messsVC andChatMessage:(ChatListModel *)listModel;

///当程序将要推出的时候保存界面的数据
- (void)saveUIDataWhenApplicationWillDissmiss;

@end
