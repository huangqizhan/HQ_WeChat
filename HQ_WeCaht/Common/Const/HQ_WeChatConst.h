//
//  HQ_WeChatConst.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/1.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MessageFont [UIFont systemFontOfSize:16.0]

/************ Rect Const *************/

extern CGFloat const HEIGHT_STATUSBAR;
extern CGFloat const HEIGHT_NAVBAR;
extern CGFloat const HEIGHT_CHATBOXVIEW;
extern CGFloat const CHATHEADIMAGEWIDTH;






/************ Event Const *************/

extern NSString *const GXRouterEventVoiceTapEventName;
extern NSString *const GXRouterEventImageTapEventName;
extern NSString *const GXRouterEventTextUrlTapEventName;
extern NSString *const GXRouterEventMenuTapEventName;
extern NSString *const GXRouterEventVideoTapEventName;
extern NSString *const GXRouterEventShareTapEvent;

extern NSString *const GXRouterEventVideoRecordExit;
extern NSString *const GXRouterEventVideoRecordCancel;
extern NSString *const GXRouterEventVideoRecordFinish;
extern NSString *const GXRouterEventVideoRecordStart;
extern NSString *const GXRouterEventURLSkip;
extern NSString *const GXRouterEventScanFile;



/************ Name Const *************/

extern NSString *const MineTextCellId;
extern NSString *const MineImageCellId;
extern NSString *const MineGifCellId;
extern NSString *const MineVidioCellId;
extern NSString *const MineVoiceCellId;
extern NSString *const MineFileCellId;
extern NSString *const DateMessageCellId;
extern NSString *const MineRecordingCellId;
extern NSString *const MineLocationCellId;

extern NSString *const OtherTextCellid;
extern NSString *const OtherImageCellId;
extern NSString *const OtherGifCellId;
extern NSString *const OtherVidioCellId;
extern NSString *const OtherVoiceCellId;
extern NSString *const OtherFileCellid;
extern NSString *const OtherLocationCellId;







/************Notification Const *************/

extern NSString *const GXEmotionDidSelectNotification;
extern NSString *const GXEmotionDidDeleteNotification;
extern NSString *const GXEmotionDidSendNotification;
//extern NSString *const NotificationReceiveUnreadMessage;
extern NSString *const NotificationDidCreatedConversation;
extern NSString *const NotificationFirstMessage;
extern NSString *const NotificationDidUpdateDeliver;
extern NSString *const NotificationPushDidReceived;
extern NSString *const NotificationDeliverChanged;
extern NSString *const NotificationBackMsgNotification;
extern NSString *const NotificationGPhotoDidChanged;
extern NSString *const NotificationReloadDataIMSource;
extern NSString *const NotificationUserHeadImgChangedNotification;
extern NSString *const NotificationKickUserNotification;
extern NSString *const NotificationShareExitNotification;
extern NSString *const NotificationReceiveNewMessageNotification;




// 取消分享
extern NSString *const ICShareCancelNotification ;
// 确认分享
extern NSString *const ICShareConfirmNotification;
extern NSString *const ICShareStayInAppNotification;
extern NSString *const ICShareBackOtherAppNotification;



extern NSString *const HQ_WeChatAMapKey;
extern NSString *const HQ_WeIsFirstInstallKey;
extern NSString *const allPOISearchTypes;



