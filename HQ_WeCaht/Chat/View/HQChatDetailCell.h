//
//  HQChatDetailCell.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/27.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatListModel+Action.h"
#import "ContractModel+Action.h"


@interface HQChatDetailCell : UITableViewCell

@property (nonatomic,weak) ChatListModel *listModel;

@property (nonatomic,copy) void (^headImageViewDidClick)();

@end




@interface HQChatDetailSwitchCell : UITableViewCell
@property (nonatomic,copy) NSString *titleString;
@property (nonatomic,assign) BOOL ison;
@property (nonatomic,copy) void (^switchDidClick)(NSString *titleTyep , BOOL isOn);

@end

@interface HQChatDetailAccessCell : UITableViewCell

@end

@interface HQChatDetailNoAccessCell : UITableViewCell

@end
