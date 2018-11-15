//
//  UIMenuController+LongPress.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/30.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIMenuController (LongPress)

///消息体
@property (nonatomic,strong) ChatMessageModel *messageMdeol;
///
@property (nonatomic,strong) NSIndexPath *indexPath;
///显示menuitem 的视图
@property (nonatomic,strong) UIView *menuView;

@end
