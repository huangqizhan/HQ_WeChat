//
//  WBModel.h
//  YYStudyDemo
//
//  Created by hqz  QQ 757618403 on 2018/9/25.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//

#import <Foundation/Foundation.h>


/// 认证方式
typedef NS_ENUM(NSUInteger, WBUserVerifyType){
    WBUserVerifyTypeNone = 0,     ///< 没有认证
    WBUserVerifyTypeStandard,     ///< 个人认证，黄V
    WBUserVerifyTypeOrganization, ///< 官方认证，蓝V
    WBUserVerifyTypeClub,         ///< 达人认证，红星
};


/// 图片标记
typedef NS_ENUM(NSUInteger, WBPictureBadgeType) {
    WBPictureBadgeTypeNone = 0, ///< 正常图片
    WBPictureBadgeTypeLong,     ///< 长图
    WBPictureBadgeTypeGIF,      ///< GIF
};



///
@interface WBPictureMetaModel : NSObject
///原图地址
@property (nonatomic, strong) NSURL *url;
///宽
@property (nonatomic, assign) int width;
///高
@property (nonatomic, assign) int height;
///图片类型 "WEBP" "JPEG" "GIF"
@property (nonatomic, strong) NSString *type;
///裁剪类型 Default 1
@property (nonatomic, assign) int cutType;
/// 图片标记
@property (nonatomic, assign) WBPictureBadgeType badgeType;
@end



/**
 图片
 */
@interface WBPicture : NSObject
@property (nonatomic, strong) NSString *picID;
@property (nonatomic, strong) NSString *objectID;
@property (nonatomic, assign) int photoTag;
@property (nonatomic, assign) BOOL keepSize; ///< YES:固定为方形 NO:原始宽高比
///最小的缩略图 w:180
@property (nonatomic, strong) WBPictureMetaModel *thumbnail;
///列表中的缩略图 w:360
@property (nonatomic, strong) WBPictureMetaModel *bmiddle;
///不大不小 w:480
@property (nonatomic, strong) WBPictureMetaModel *middlePlus;
/// 放大查看 w:720
@property (nonatomic, strong) WBPictureMetaModel *large;
///<       (查看原图)
@property (nonatomic, strong) WBPictureMetaModel *largest;
@property (nonatomic, strong) WBPictureMetaModel *original;   ///<
@property (nonatomic, assign) WBPictureBadgeType badgeType;
@end


/// 链接

@interface WBURL : NSObject

@property (nonatomic, assign) BOOL result;
///< 短域名 (原文)
@property (nonatomic, strong) NSString *shortURL;
///< 原始链接
@property (nonatomic, strong) NSString *oriURL;
///< 显示文本，例如"网页链接"，可能需要裁剪(24)
@property (nonatomic, strong) NSString *urlTitle;
///< 链接类型的图片URL
@property (nonatomic, strong) NSString *urlTypePic;
///< 0:一般链接 36地点 39视频/图片
@property (nonatomic, assign) int32_t urlType;
@property (nonatomic, strong) NSString *log;
@property (nonatomic, strong) NSDictionary *actionLog;
///< 对应着 WBPageInfo
@property (nonatomic, strong) NSString *pageID;
@property (nonatomic, strong) NSString *storageType;
//如果是图片，则会有下面这些，可以直接点开看
@property (nonatomic, strong) NSArray<NSString *> *picIds;
@property (nonatomic, strong) NSDictionary<NSString *, WBPicture *> *picInfos;
@property (nonatomic, strong) NSArray<WBPicture *> *pics;

@end

/**
 话题
 */
@interface WBTopic : NSObject
///< 话题标题
@property (nonatomic, strong) NSString *topicTitle;
///< 话题链接 sinaweibo://
@property (nonatomic, strong) NSString *topicURL;
@end

/**
 标签
 */
@interface WBTag : NSObject
///< 标签名字，例如"上海·上海文庙"
@property (nonatomic, strong) NSString *tagName;
///< 链接 sinaweibo://...
@property (nonatomic, strong) NSString *tagScheme;
///< 1 地点 2其他
@property (nonatomic, assign) int32_t tagType;
@property (nonatomic, assign) int32_t tagHidden;
///< 需要加 _default
@property (nonatomic, strong) NSURL *urlTypePic;
@end

/**
 按钮
 */
@interface WBButtonLink : NSObject
@property (nonatomic, strong) NSURL *pic;  ///< 按钮图片URL (需要加_default)
@property (nonatomic, strong) NSString *name; ///< 按钮文本，例如"点评"
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSDictionary *params;
@end

///卡片
@interface WBPageInfo : NSObject
///< 页面标题，例如"上海·上海文庙"
@property (nonatomic, strong) NSString *pageTitle;
@property (nonatomic, strong) NSString *pageID;
///< 页面描述，例如"上海市黄浦区文庙路215号"
@property (nonatomic, strong) NSString *pageDesc;
@property (nonatomic, strong) NSString *content1;
@property (nonatomic, strong) NSString *content2;
@property (nonatomic, strong) NSString *content3;
@property (nonatomic, strong) NSString *content4;
///< 提示，例如"4222条微博"
@property (nonatomic, strong) NSString *tips;
///< 类型，例如"place" "video"
@property (nonatomic, strong) NSString *objectType;
@property (nonatomic, strong) NSString *objectID;
///< 真实链接，例如 http://v.qq.com/xxx
@property (nonatomic, strong) NSString *scheme;
@property (nonatomic, strong) NSArray<WBButtonLink *> *buttons;

@property (nonatomic, assign) int32_t isAsyn;
@property (nonatomic, assign) int32_t type;
///< 链接 sinaweibo://...
@property (nonatomic, strong) NSString *pageURL;
///< 图片URL，不需要加(_default) 通常是左侧的方形图片
@property (nonatomic, strong) NSURL *pagePic;
///< Badge 图片URL，不需要加(_default) 通常放在最左上角角落里
@property (nonatomic, strong) NSURL *typeIcon; @property (nonatomic, assign) int32_t actStatus;
@property (nonatomic, strong) NSDictionary *actionlog;
@property (nonatomic, strong) NSDictionary *mediaInfo;
@end


/**
 微博标题
 */
@interface WBStatusTitle : NSObject
@property (nonatomic, assign) int32_t baseColor;
@property (nonatomic, strong) NSString *text; ///< 文本，例如"仅自己可见"
@property (nonatomic, strong) NSString *iconURL; ///< 图标URL，需要加Default
@end

/**
 用户
 */
@interface WBUser : NSObject
///< id (int)
@property (nonatomic, assign) uint64_t userID;
///< id (string)
@property (nonatomic, strong) NSString *idString;
/// 0:none 1:男 2:女
@property (nonatomic, assign) int32_t gender;
/// "m":男 "f":女 "n"未知
@property (nonatomic, strong) NSString *genderString;
///< 个人简介
@property (nonatomic, strong) NSString *desc;
///< 个性域名
@property (nonatomic, strong) NSString *domain;
///< 昵称
@property (nonatomic, strong) NSString *name;
///< 友好昵称
@property (nonatomic, strong) NSString *screenName;
///< 备注
@property (nonatomic, strong) NSString *remark;
///< 粉丝数
@property (nonatomic, assign) int32_t followersCount;
///< 关注数
@property (nonatomic, assign) int32_t friendsCount;
///< 好友数 (双向关注)
@property (nonatomic, assign) int32_t biFollowersCount;
///< 收藏数
@property (nonatomic, assign) int32_t favouritesCount;
///< 微博数
@property (nonatomic, assign) int32_t statusesCount;
///< 话题数
@property (nonatomic, assign) int32_t topicsCount;
///< 屏蔽数
@property (nonatomic, assign) int32_t blockedCount;
@property (nonatomic, assign) int32_t pagefriendsCount;
@property (nonatomic, assign) BOOL followMe;
@property (nonatomic, assign) BOOL following;
///< 省
@property (nonatomic, strong) NSString *province;
///< 市
@property (nonatomic, strong) NSString *city;
///< 博客地址
@property (nonatomic, strong) NSString *url;
///< 头像 50x50 (FeedList)
@property (nonatomic, strong) NSURL *profileImageURL;
///< 头像 180*180
@property (nonatomic, strong) NSURL *avatarLarge;
///< 头像 原图
@property (nonatomic, strong) NSURL *avatarHD;
///< 封面图 920x300
@property (nonatomic, strong) NSURL *coverImage;
@property (nonatomic, strong) NSURL *coverImagePhone;

@property (nonatomic, strong) NSString *profileURL;
@property (nonatomic, assign) int32_t type;
@property (nonatomic, assign) int32_t ptype;
@property (nonatomic, assign) int32_t mbtype;
///< 微博等级 (LV)
@property (nonatomic, assign) int32_t urank;
@property (nonatomic, assign) int32_t uclass;
@property (nonatomic, assign) int32_t ulevel;
///< 会员等级 (橙名 VIP)
@property (nonatomic, assign) int32_t mbrank;
@property (nonatomic, assign) int32_t star;
@property (nonatomic, assign) int32_t level;
///< 注册时间
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, assign) BOOL allowAllActMsg;
@property (nonatomic, assign) BOOL allowAllComment;
@property (nonatomic, assign) BOOL geoEnabled;
@property (nonatomic, assign) int32_t onlineStatus;
///< 所在地
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, NSString *> *> *icons;
@property (nonatomic, strong) NSString *weihao;
@property (nonatomic, strong) NSString *badgeTop;
@property (nonatomic, assign) int32_t blockWord;
@property (nonatomic, assign) int32_t blockApp;
@property (nonatomic, assign) int32_t hasAbilityTag;
///< 信用积分
@property (nonatomic, assign) int32_t creditScore;
///< 勋章
@property (nonatomic, strong) NSDictionary<NSString *, NSNumber *> *badge;
@property (nonatomic, strong) NSString *lang;
@property (nonatomic, assign) int32_t userAbility;
@property (nonatomic, strong) NSDictionary *extend;
///< 微博认证 (大V)
@property (nonatomic, assign) BOOL verified;
@property (nonatomic, assign) int32_t verifiedType;
@property (nonatomic, assign) int32_t verifiedLevel;
@property (nonatomic, assign) int32_t verifiedState;
@property (nonatomic, strong) NSString *verifiedContactEmail;
@property (nonatomic, strong) NSString *verifiedContactMobile;
@property (nonatomic, strong) NSString *verifiedTrade;
@property (nonatomic, strong) NSString *verifiedContactName;
@property (nonatomic, strong) NSString *verifiedSource;
@property (nonatomic, strong) NSString *verifiedSourceURL;
 ///< 微博认证描述
@property (nonatomic, strong) NSString *verifiedReason;
@property (nonatomic, strong) NSString *verifiedReasonURL;
@property (nonatomic, strong) NSString *verifiedReasonModified;

@property (nonatomic, assign) WBUserVerifyType userVerifyType;

@end




///  cell data  
@interface WBModel : NSObject
///< id (number)
@property (nonatomic, assign) uint64_t statusID;
///< id (string)
@property (nonatomic, strong) NSString *idstr;
@property (nonatomic, strong) NSString *mid;
@property (nonatomic, strong) NSString *rid;
///< 发布时间
@property (nonatomic, strong) NSDate *createdAt;

@property (nonatomic, strong) WBUser *user;
@property (nonatomic, assign) int32_t userType;
///< 标题栏 (通常为nil)
@property (nonatomic, strong) WBStatusTitle *title;
///< 微博VIP背景图，需要替换 "os7"
@property (nonatomic, strong) NSString *picBg;
///< 正文
@property (nonatomic, strong) NSString *text;
///< 缩略图
@property (nonatomic, strong) NSURL *thumbnailPic;
///< 中图
@property (nonatomic, strong) NSURL *bmiddlePic;
///< 大图
@property (nonatomic, strong) NSURL *originalPic;
///转发微博
@property (nonatomic, strong) WBModel *retweetedStatus;

@property (nonatomic, strong) NSArray<NSString *> *picIds;
@property (nonatomic, strong) NSDictionary<NSString *, WBPicture *> *picInfos;
////自加界面字段  
@property (nonatomic, strong) NSArray<WBPicture *> *pics;
@property (nonatomic, strong) NSArray<WBURL *> *urlStruct;
@property (nonatomic, strong) NSArray<WBTopic *> *topicStruct;
@property (nonatomic, strong) NSArray<WBTag *> *tagStruct;
@property (nonatomic, strong) WBPageInfo *pageInfo;
///< 是否收藏
@property (nonatomic, assign) BOOL favorited;
///< 是否截断
@property (nonatomic, assign) BOOL truncated;
///< 转发数
@property (nonatomic, assign) int32_t repostsCount;
///< 评论数
@property (nonatomic, assign) int32_t commentsCount;
///< 赞数
@property (nonatomic, assign) int32_t attitudesCount;
///< 是否已赞 0:没有
@property (nonatomic, assign) int32_t attitudesStatus;
@property (nonatomic, assign) int32_t recomState;

@property (nonatomic, strong) NSString *inReplyToScreenName;
@property (nonatomic, strong) NSString *inReplyToStatusId;
@property (nonatomic, strong) NSString *inReplyToUserId;
///< 来自 XXX
@property (nonatomic, strong) NSString *source;
@property (nonatomic, assign) int32_t sourceType;
///< 来源是否允许点击
@property (nonatomic, assign) int32_t sourceAllowClick;

@property (nonatomic, strong) NSDictionary *geo;
///< 地理位置
@property (nonatomic, strong) NSArray *annotations;
@property (nonatomic, assign) int32_t bizFeature;
@property (nonatomic, assign) int32_t mlevel;
@property (nonatomic, strong) NSString *mblogid;
@property (nonatomic, strong) NSString *mblogTypeName;
@property (nonatomic, strong) NSString *scheme;
@property (nonatomic, strong) NSDictionary *visible;
@property (nonatomic, strong) NSArray *darwinTags;
@end


/**
 一次API请求的数据
 */
@interface WBTimelineItem : NSObject
@property (nonatomic, strong) NSArray *ad;
@property (nonatomic, strong) NSArray *advertises;
@property (nonatomic, strong) NSString *gsid;
@property (nonatomic, assign) int32_t interval;
@property (nonatomic, assign) int32_t uveBlank;
@property (nonatomic, assign) int32_t hasUnread;
@property (nonatomic, assign) int32_t totalNumber;
@property (nonatomic, strong) NSString *sinceID;
@property (nonatomic, strong) NSString *maxID;
@property (nonatomic, strong) NSString *previousCursor;
@property (nonatomic, strong) NSString *nextCursor;
@property (nonatomic, strong) NSArray<WBModel *> *statuses;
/*
 groupInfo
 trends
 */
@end
