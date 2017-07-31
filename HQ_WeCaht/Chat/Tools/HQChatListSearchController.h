//
//  HQSearchResultController.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/1.
//  Copyright © 2017年 黄麒展. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "HQChatListSearchResultDelegate.h"


typedef NS_ENUM(NSInteger,ChatListSearchControllerTableViewShowType) {
    
    ChatListSearchControllerShowOriginalStatus,       ///最开始状态  选择搜索类型
    ChatListSearchControllerShowSearchResultStatus,   ///显示搜索结果
};

@class HQBaseViewController,HQSearchBar;

@interface HQChatListSearchController : UIViewController <UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>

///更新消息列表回调
@property (nonatomic,copy)void (^refershChatListMessage)();


///动画显示搜索控制器
- (void)showInViewController:(HQBaseViewController *)controller fromSearchBar:(HQSearchBar *)SearchBar;





@end














@interface HQSearchResultRecentilyCell : UITableViewCell

@property (nonatomic,copy) ChatListModel *listMOdel;

@end
