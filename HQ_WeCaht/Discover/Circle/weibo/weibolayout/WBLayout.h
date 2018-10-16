//
//  WBLayout.h
//  YYStudyDemo
//
//  Created by hqz on 2018/9/26.
//  Copyright © 2018年 hqz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WBHeader.h"

NS_ASSUME_NONNULL_BEGIN

// 宽高
// cell 顶部灰色留白
#define kWBCellTopMargin 8
// cell 标题高度 (例如"仅自己可见")
#define kWBCellTitleHeight 36
// cell 内边距
#define kWBCellPadding 12
// cell 文本与其他元素间留白
#define kWBCellPaddingText 10
// cell 多张图片中间留白
#define kWBCellPaddingPic 4
// cell 名片高度
#define kWBCellProfileHeight 56
// cell card 视图高度
#define kWBCellCardHeight 70
// cell 名字和 avatar 之间留白
#define kWBCellNamePaddingLeft 14
// cell 内容宽度
#define kWBCellContentWidth (kScreenWidth - 2 * kWBCellPadding)
// cell 名字最宽限制
#define kWBCellNameWidth (kScreenWidth - 110)
// tag 上下留白
#define kWBCellTagPadding 8
// 一般 tag 高度
#define kWBCellTagNormalHeight 16
// 地理位置 tag 高度
#define kWBCellTagPlaceHeight 24
// cell 下方工具栏高度
#define kWBCellToolbarHeight 35
// cell 下方灰色留白
#define kWBCellToolbarBottomMargin 2

// 名字字体大小
#define kWBCellNameFontSize 16
// 来源字体大小
#define kWBCellSourceFontSize 12
// 文本字体大小
#define kWBCellTextFontSize 17
// 转发字体大小
#define kWBCellTextFontRetweetSize 16
// 卡片标题文本字体大小
#define kWBCellCardTitleFontSize 16
// 卡片描述文本字体大小
#define kWBCellCardDescFontSize 12
// 标题栏字体大小
#define kWBCellTitlebarFontSize 14
// 工具栏字体大小
#define kWBCellToolbarFontSize 14

// 颜色

// 名字颜色
#define kWBCellNameNormalColor UIColorHex(333333)
// 橙名颜色 (VIP)
#define kWBCellNameOrangeColor UIColorHex(f26220)
// 时间颜色
#define kWBCellTimeNormalColor UIColorHex(828282)
// 橙色时间 (最新刷出)
#define kWBCellTimeOrangeColor UIColorHex(f28824)
// 一般文本色
#define kWBCellTextNormalColor UIColorHex(333333)
// 次要文本色
#define kWBCellTextSubTitleColor UIColorHex(5d5d5d)
// Link 文本色
#define kWBCellTextHighlightColor UIColorHex(527ead)
// Link 点击背景色
#define kWBCellTextHighlightBackgroundColor UIColorHex(bfdffe)
// 工具栏文本色
#define kWBCellToolbarTitleColor UIColorHex(929292)
// 工具栏文本高亮色
#define kWBCellToolbarTitleHighlightColor UIColorHex(df422d)
// Cell背景灰色
#define kWBCellBackgroundColor UIColorHex(f2f2f2)
// Cell高亮时灰色
#define kWBCellHighlightColor UIColorHex(f0f0f0)
// Cell内部卡片灰色
#define kWBCellInnerViewColor UIColorHex(f7f7f7)
// Cell内部卡片高亮时灰色
#define kWBCellInnerViewHighlightColor  UIColorHex(f0f0f0)
//线条颜色
#define kWBCellLineColor [UIColor colorWithWhite:0.000 alpha:0.09]
//NSString
#define kWBLinkHrefName @"href"
//WBURL
#define kWBLinkURLName @"url"
//WBTag
#define kWBLinkTagName @"tag"
//WBTopic
#define kWBLinkTopicName @"topic"
//NSString
#define kWBLinkAtName @"at"
/// 风格
typedef NS_ENUM(NSUInteger, WBLayoutStyle) {
    WBLayoutStyleTimeline = 0, ///< 时间线 (目前只支持这一种)
    WBLayoutStyleDetail,       ///< 详情页
};

/// 卡片类型 (这里随便写的，只适配了微博中常见的类型)
typedef NS_ENUM(NSUInteger, WBStatusCardType) {
    WBStatusCardTypeNone = 0, ///< 没卡片
    WBStatusCardTypeNormal,   ///< 一般卡片布局
    WBStatusCardTypeVideo,    ///< 视频
};

/// 最下方Tag类型，也是随便写的，微博可能有更多类型同时存在等情况
typedef NS_ENUM(NSUInteger, WBStatusTagType) {
    WBStatusTagTypeNone = 0, ///< 没Tag
    WBStatusTagTypeNormal,   ///< 文本
    WBStatusTagTypePlace,    ///< 地点
};



@interface WBTextLinePositionModifier : NSObject <TextLinePositionModifier>
@property (nonatomic, strong) UIFont *font; // 基准字体 (例如 Heiti SC/PingFang SC)
@property (nonatomic, assign) CGFloat paddingTop; //文本顶部留白
@property (nonatomic, assign) CGFloat paddingBottom; //文本底部留白
@property (nonatomic, assign) CGFloat lineHeightMultiple; //行距倍数
- (CGFloat)heightForLineCount:(NSUInteger)lineCount;
@end


@interface WBLayout : NSObject

- (instancetype)initWithStatus:(WBModel *)model style:(WBLayoutStyle)style;
///< 计算布局
- (void)layout;
///< 更新时间字符串
- (void)updateDate;



// 以下是数据
@property (nonatomic, strong) WBModel *wbModel;
@property (nonatomic, assign) WBLayoutStyle style;

//以下是布局结果

// 顶部留白

//顶部灰色留白
@property (nonatomic, assign) CGFloat marginTop;

// 标题栏

//标题栏高度，0为没标题栏
@property (nonatomic, assign) CGFloat titleHeight;

// 标题栏
@property (nonatomic, strong) TextLayout *titleTextLayout;

// 个人资料

//个人资料高度(包括留白)
@property (nonatomic, assign) CGFloat profileHeight;
// 名字
@property (nonatomic, strong) TextLayout *nameTextLayout;
//时间/来源
@property (nonatomic, strong) TextLayout *sourceTextLayout;

// 文本

//文本高度(包括下方留白)
@property (nonatomic, assign) CGFloat textHeight;

//文本
@property (nonatomic, strong) TextLayout *textLayout;

// 图片

//图片高度，0为没图片
@property (nonatomic, assign) CGFloat picHeight;
@property (nonatomic, assign) CGSize picSize;

// 转发

//转发高度，0为没转发
@property (nonatomic, assign) CGFloat retweetHeight;
@property (nonatomic, assign) CGFloat retweetTextHeight;
//被转发文本
@property (nonatomic, strong) TextLayout *retweetTextLayout;
@property (nonatomic, assign) CGFloat retweetPicHeight;
@property (nonatomic, assign) CGSize retweetPicSize;
@property (nonatomic, assign) CGFloat retweetCardHeight;
@property (nonatomic, assign) WBStatusCardType retweetCardType;
//被转发文本
@property (nonatomic, strong) TextLayout *retweetCardTextLayout;
@property (nonatomic, assign) CGRect retweetCardTextRect;

// 卡片

//卡片高度，0为没卡片
@property (nonatomic, assign) CGFloat cardHeight;
@property (nonatomic, assign) WBStatusCardType cardType;
//卡片文本
@property (nonatomic, strong) TextLayout *cardTextLayout;
@property (nonatomic, assign) CGRect cardTextRect;

// Tag

//Tip高度，0为没tip
@property (nonatomic, assign) CGFloat tagHeight;
@property (nonatomic, assign) WBStatusTagType tagType;
//最下方tag
@property (nonatomic, strong) TextLayout *tagTextLayout; 

// 工具栏

@property (nonatomic, assign) CGFloat toolbarHeight;
///转发
@property (nonatomic, strong) TextLayout *toolbarRepostTextLayout;
///评论
@property (nonatomic, strong) TextLayout *toolbarCommentTextLayout;
///点赞
@property (nonatomic, strong) TextLayout *toolbarLikeTextLayout;
@property (nonatomic, assign) CGFloat toolbarRepostTextWidth;
@property (nonatomic, assign) CGFloat toolbarCommentTextWidth;
@property (nonatomic, assign) CGFloat toolbarLikeTextWidth;

// 下边留白
@property (nonatomic, assign) CGFloat marginBottom; //下边留白

// 总高度
@property (nonatomic, assign) CGFloat height;



/*
 
 用户信息  status.user
 文本      status.text
 图片      status.pics
 转发      status.retweetedStatus
 文本       status.retweetedStatus.user + status.retweetedStatus.text
 图片       status.retweetedStatus.pics
 卡片       status.retweetedStatus.pageInfo
 卡片      status.pageInfo
 Tip       status.tagStruct
 
 1.根据 urlStruct 中每个 URL.shortURL 来匹配文本，将其替换为图标+友好描述
 2.根据 topicStruct 中每个 Topic.topicTitle 来匹配文本，标记为话题
 2.匹配 @用户名
 4.匹配 [表情]
 
 一条里，图片|转发|卡片不能同时存在，优先级是 转发->图片->卡片
 如果不是转发，则显示Tip
 
 
 文本
 文本 图片/卡片
 文本 Tip
 文本 图片/卡片 Tip
 
 文本 转发[文本]  /Tip
 文本 转发[文本 图片] /Tip
 文本 转发[文本 卡片] /Tip
 
 话题                                 #爸爸去哪儿#
 电影 timeline_card_small_movie       #冰雪奇缘[电影]#
 图书 timeline_card_small_book        #纸牌屋[图书]#
 音乐 timeline_card_small_music       #Let It Go[音乐]#
 地点 timeline_card_small_location    #理想国际大厦[地点]#
 股票 timeline_icon_stock             #腾讯控股 kh00700[股票]#
 */



@end

NS_ASSUME_NONNULL_END
