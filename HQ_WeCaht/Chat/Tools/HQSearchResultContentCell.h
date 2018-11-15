//
//  HQSearchResultContentCell.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/21.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HQSearchResultContentCell : UITableViewCell

@property(nonatomic,copy) void (^ButtonItemDidClick)(NSString *title);

@end



@interface HQSearchResultRecentlyContactCell : UITableViewCell

@property (nonatomic,strong) ChatListModel *listModel;

@end




@interface HQSearchResultChatMessageCell  : UITableViewCell

@property (nonatomic,strong) ChatMessageModel *messageModel;

@end
