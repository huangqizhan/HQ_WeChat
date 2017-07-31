//
//  HQChatDetailController.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/27.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQBaseViewController.h"
#import "ChatListModel+Action.h"



@interface HQChatDetailController : HQBaseViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,weak) ChatListModel *listMOdel;
////设置聊天界面的回调
@property (nonatomic,copy) void (^chatDetailCallBack)(NSString *titleType);


@end
