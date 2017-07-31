//
//  HQChatTableViewCellDelegate.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/5/26.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HQTextView,ChatMessageModel;

@protocol HQChatTableViewCellDelegate <NSObject>

@optional

////长按手势menuController 按钮事件
- (void)HQChatMineBaseCell:(UITableViewCell *)cell MenuActionTitle:(NSString *)menuActionTitle andIndexPath:(NSIndexPath *)indexPath andChatModel:(ChatMessageModel *)model;

////查看大图
- (void)HQChatMineBaseCell:(UITableViewCell *)cell didScanOriginePictureWith:(ChatMessageModel *)messageModel andPicBtn:(UIButton *)picButton;

///双击浏览文本消息
- (void)HQChatDoubleClick:(UITableViewCell *)cell WithChatMessage:(ChatMessageModel *)messageModel;
////点击链接
- (void)HQChatClickLink:(UITableViewCell *)cell withChatMessage:(ChatMessageModel *)message andLinkUrl:(NSURL *)linkUrl;
////当前的聊天输入框
- (HQTextView *)getCurentTextViewWhenShowMenuController;
/////menuController将要消失
- (void)MenuViewControllerDidHidden;

////修改扬声器
- (void)changeSpeakerStatus;


@end
