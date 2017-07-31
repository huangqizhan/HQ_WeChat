//
//  HQChatListSecondSearchController.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/19.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQBaseViewController.h"

typedef NS_ENUM(NSInteger,ChatListSecondSearchType) {
    
    ChatListSecondSearchAsnsType,     ///朋友圈搜索
    ChatListSecondSearchArircleType,  ///文章搜索
    ChatListSecondSearchPubCallType   ///公众号搜索
};

@interface HQChatListSecondSearchController : HQBaseViewController

@end
