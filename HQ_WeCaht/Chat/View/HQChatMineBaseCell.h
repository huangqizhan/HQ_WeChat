//
//  HQChatMineBaseCell.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/8.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

//#import <UIKit/UIKit.h>
#import "HQChaRootCell.h"
#import "HQChatTableViewCellDelegate.h"
#import "HQBaseCellLayout.h"
#import "ImageControll.h"

@interface HQChatMineBaseCell : HQChaRootCell

///消息模型
@property (nonatomic,strong)ChatMessageModel *messageModel;
///layout
@property (nonatomic,strong) HQBaseCellLayout *layout;
// 头像
@property (nonatomic, strong) ImageControll *headImageView;
// 菊花视图所在的view
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
//选择按钮
@property (nonatomic,strong) UIImageView *selectControl;

@property (nonatomic,strong) NSIndexPath *indexPath;

@property (nonatomic,assign) id <HQChatTableViewCellDelegate>delegate;
//
//- (void)longPressRecognizer:(UILongPressGestureRecognizer *)sender;



@property (nonatomic,strong) NSArray<NSString *> *menuItemActionNames;

@property (nonatomic,strong) NSArray<NSString *> *menuItemNames;

////长按开始
- (void)contentLongPressedBeganInView:(UIView *)view;
///长按结束
- (void)contentLongPressedEndedInView:(UIView *)view;
///tap 手势
//- (UIView *)hitTestForTapGestureRecognizer:(CGPoint)aPoint;
/////长按手势
//- (UIView *)hitTestForlongPressedGestureRecognizer:(CGPoint)aPoint;






- (void)showMenuControllerInRect:(CGRect)rect inView:(UIView *)view;

- (void)menuControllerDidHidden;

- (void)copyAction:(id)sender;

- (void)transforAction:(id)sender;

- (void)favoriteAction:(id)sender;

- (void)translateAction:(id)sender;

- (void)deleteAction:(id)sender;

- (void)moreAction:(id)sender;

- (void)addToEmojiAction:(id)sender;

- (void)forwardAction:(id)sender;

- (void)showAlbumAction:(id)sender;

- (void)playAction:(id)sender;

- (void)translateToWordsAction:(id)sender;

@end
