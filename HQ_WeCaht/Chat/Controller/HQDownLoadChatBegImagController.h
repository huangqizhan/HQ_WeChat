//
//  HQDownLoadChatBegImagController.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/29.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQBaseViewController.h"

@interface HQDownLoadChatBegImagController : HQBaseViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,weak) ChatListModel *listModel;
@property (nonatomic,copy) void (^chatDetailCallBack)(NSString *titleType);


@end
