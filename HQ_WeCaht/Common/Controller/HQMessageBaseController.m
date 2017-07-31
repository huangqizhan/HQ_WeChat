//
//  HQMessageBaseController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/8.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQMessageBaseController.h"

@interface HQMessageBaseController ()

@end

@implementation HQMessageBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
