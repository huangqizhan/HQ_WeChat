//
//  HQChatViewController.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/2/20.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQMessageBaseController.h"

@class ChatListModel;

@interface HQChatViewController : HQMessageBaseController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong,readonly) HQChatTableView *tableView;
@property (nonatomic,strong,readonly) NSMutableArray <HQBaseCellLayout *> *dataArray;


@property (nonatomic,strong) ChatListModel *listModel;

@property (nonatomic,copy) void (^reloadChatListFromDBCallBack)();

@end



