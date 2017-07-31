//
//  HQSetChatBegImageController.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/28.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQBaseViewController.h"

@interface HQSetChatBegImageController : HQBaseViewController<UITableViewDelegate,UITableViewDataSource>

////设置聊天界面的回调
@property (nonatomic,copy) void (^chatDetailCallBack)(NSString *titleType);
@property (nonatomic,weak) ChatListModel *listModel;

@end



@interface HQSetChatBegImageAccessCell : UITableViewCell

@property (nonatomic,copy) NSString *titleString;

@end
