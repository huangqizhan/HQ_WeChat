//
//  WBTableViewCell.h
//  YYStudyDemo
//
//  Created by hqz  QQ 757618403 on 2018/9/27.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HQLabel.h"
#import "WBHeader.H"
#import "WBLayout.h"
#import "WBHelper.h"


NS_ASSUME_NONNULL_BEGIN

@class  WBTableViewCell;

#pragma mark ---- 标题部分
@interface WBTitleView : UIView

@property (nonatomic, strong) HQLabel *titleLabel;
@property (nonatomic, weak) WBTableViewCell *cell;

@end

#pragma mark  头像 用户信息部分
@interface WBProfileView : UIView
///< 头像
@property (nonatomic, strong) UIImageView *avatarView;
///< 徽章
@property (nonatomic, strong) UIImageView *avatarBadgeView;
@property (nonatomic, strong) HQLabel *nameLabel;
@property (nonatomic, strong) HQLabel *sourceLabel;
@property (nonatomic, strong) UIImageView *backgroundImageView;
//@property (nonatomic, strong) UIButton *followButton;
@property (nonatomic, assign) WBUserVerifyType verifyType;
@property (nonatomic, weak) WBTableViewCell *cell;
@end


@interface WBCardView : UIView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *badgeImageView;
@property (nonatomic, strong) HQLabel *label;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, weak) WBTableViewCell *cell;

@end

///底部工具栏   转发 评论 赞
@interface WBToolbarView : UIView
@property (nonatomic, strong) UIButton *repostButton;
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) UIButton *likeButton;

@property (nonatomic, strong) UIImageView *repostImageView;
@property (nonatomic, strong) UIImageView *commentImageView;
@property (nonatomic, strong) UIImageView *likeImageView;

@property (nonatomic, strong) HQLabel *repostLabel;
@property (nonatomic, strong) HQLabel *commentLabel;
@property (nonatomic, strong) HQLabel *likeLabel;

@property (nonatomic, strong) CAGradientLayer *line1;
@property (nonatomic, strong) CAGradientLayer *line2;
@property (nonatomic, strong) CALayer *topLine;
@property (nonatomic, strong) CALayer *bottomLine;
@property (nonatomic, weak) WBTableViewCell *cell;

- (void)setWithLayout:(WBLayout *)layout;
// set both "liked" and "likeCount"
- (void)setLiked:(BOOL)liked withAnimation:(BOOL)animation;
@end

///内容视图
#warning ------
@interface WBTagView : UIView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) HQLabel *label;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, weak) WBTableViewCell *cell;

@end




@interface WBContentView : UIView
@property (nonatomic, strong) UIView *contentView;              // 容器
@property (nonatomic, strong) WBTitleView *titleView;     // 标题栏
@property (nonatomic, strong) WBProfileView *profileView; // 用户资料
@property (nonatomic, strong) HQLabel *textLabel;               // 文本
@property (nonatomic, strong) NSArray<UIView *> *picViews;      // 图片
@property (nonatomic, strong) UIView *retweetBackgroundView;    //转发容器
@property (nonatomic, strong) HQLabel *retweetTextLabel;        // 转发文本
@property (nonatomic, strong) WBCardView *cardView;       // 卡片
@property (nonatomic, strong) WBTagView *tagView;         // 下方Tag
@property (nonatomic, strong) WBToolbarView *toolbarView; // 工具栏
@property (nonatomic, strong) UIImageView *vipBackgroundView;   // VIP 自定义背景
@property (nonatomic, strong) UIButton *menuButton;             // 菜单按钮
@property (nonatomic, strong) UIButton *followButton;           // 关注按钮

@property (nonatomic, strong) WBLayout *layout;
@property (nonatomic, weak) WBTableViewCell *cell;
@end


@protocol WBTableViewCellDelegate ;

@interface WBTableViewCell : UITableViewCell

@property (nonatomic, strong) WBContentView *statusView;
@property (nonatomic,weak) id <WBTableViewCellDelegate>delegate;
- (void)setLayout:(WBLayout *)layout;

@end


@protocol WBTableViewCellDelegate <NSObject>
@optional
/// 点击了 Cell
- (void)cellDidClick:(WBTableViewCell *)cell;
/// 点击了 Card
- (void)cellDidClickCard:(WBTableViewCell *)cell;
/// 点击了转发内容
- (void)cellDidClickRetweet:(WBTableViewCell *)cell;
/// 点击了Cell菜单
- (void)cellDidClickMenu:(WBTableViewCell *)cell;
/// 点击了关注
- (void)cellDidClickFollow:(WBTableViewCell *)cell;
/// 点击了转发
- (void)cellDidClickRepost:(WBTableViewCell *)cell;
/// 点击了下方 Tag
- (void)cellDidClickTag:(WBTableViewCell *)cell;
/// 点击了评论
- (void)cellDidClickComment:(WBTableViewCell *)cell;
/// 点击了赞
- (void)cellDidClickLike:(WBTableViewCell *)cell;
/// 点击了用户
- (void)cell:(WBTableViewCell *)cell didClickUser:(WBUser *)user;
/// 点击了图片
- (void)cell:(WBTableViewCell *)cell didClickImageAtIndex:(NSUInteger)index;
/// 点击了 Label 的链接
- (void)cell:(WBTableViewCell *)cell didClickInLabel:(HQLabel *)label textRange:(NSRange)textRange;
@end


NS_ASSUME_NONNULL_END
