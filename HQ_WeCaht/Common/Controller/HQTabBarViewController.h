//
//  HQTabBarViewController.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/2/20.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HQTabBarViewController : UITabBarController


- (void)receiveNewMessage:(ChatMessageModel *)messageModel;


@end
