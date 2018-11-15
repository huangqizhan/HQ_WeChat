//
//  ChatListTableViewCell.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/1.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChatListModel;

@interface ChatListTableViewCell : UITableViewCell

@property (nonatomic, strong) ChatListModel * model;

@property (nonatomic, weak) UIButton *unreadLabel;

+ (instancetype)cellWithTableView:(UITableView *)tableView;


@end
