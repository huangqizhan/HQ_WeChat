//
//  HQMessageBaseController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/8.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HQMessageBaseController.h"

@interface HQMessageBaseController ()

@end

@implementation HQMessageBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone; //UIRectEdgeAll
    }

}

- (void)messageHandleWith:(ChatMessageModel *)messageModel{
    NSLog(@"HQMessageBaseController = %@",messageModel.contentString);
}
- (void)contactPushToChatViewControllerWith:(HQMessageBaseController *)messsVC andChatMessage:(ChatListModel *)listModel{
    
}
- (void)saveUIDataWhenApplicationWillDissmiss{
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
