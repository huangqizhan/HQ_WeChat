//
//  HQWebJsManager.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/23.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WKWebViewJavascriptBridge.h"

@import WebKit;


#define Device @"device.notification."
#define Util @"biz.util."
#define Navigation @"biz.navigation."
#define Input @"ui.input."
#define Connection @"device.connection."
#define Location @"device.geolocation."

///UT打点
#define UTPoint Util@"ut"
///alert
#define Alert Device@"alert"
///Confirm
#define Confirm Device@"confirm"
///提示
#define Prompt Device@"prompt"
///震动
#define Vibrate Device@"vibrate"
///启动摇一摇
#define WatchShake @"device.accelerometer.watchShake"
///停止摇一摇
#define ClearShake @"device.accelerometer.clearShake"
///打开
#define Open Util@"open"
///打开外部URL
#define OpenLink Util@"openLink"
///分享
#define Share Util@"share"

///日期选择
#define Datepicker Util@"datepicker"
///时间选择
#define Timepicker Util@"timepicker"
///设置左侧导航栏
#define SetLeft Navigation@"setLeft"
///设置右侧导航栏
#define SetRight Navigation@"setRight"

///设置标题
#define SetTitle Navigation@"setTitle"
///页面后退
#define Back Navigation@"back"
///toast
#define Toast Device@"toast"
///显示loading
#define ShowPreloader Device@"showPreloader"
///隐藏loading
#define HidePreloader Device@"hidePreloader"
//获取定位信息 包括反编码
#define LocationAddress Location@"get"
///上传图片(单图)
#define UploadImage Util@"uploadImage"
////浏览图片
#define PreviewImage Util@"previewImage"
///评论内容
#define Plain Input@"plain"
///ActionSheet
#define ActionSheet Device@"actionSheet"
///网络类型
#define  GetNetworkType Connection@"getNetworkType"
////runtime.info容器信息
#define RunTimeInfo @"runtime.info"
////发钉(应用内类型)  未实现
#define DingPost @"biz.ding.post"
///打电话
#define TelePohone @"biz.telephone.call"
////创建群聊天
#define CreatGroup @"biz.contact.createGroup"
///日期+时间选择器
#define DateTimePicker @"biz.util.datetimepicker"
///下拉组件   未实现
#define XiaLaChosen @"biz.util.chosen"
///获取唯一识别码
#define GetUUID @"device.base.getUUID"
///获取热点接入信息  未实现
#define GetInterface @"device.base.getInterface"
///检测应用是否安装
#define CheckInstalledApp @"device.launcher.checkInstalledApps"
///启动第三方app
#define LaunchApp @"device.launcher.launchApp"
///设置进度条颜色  未实现
#define SetProcessColor @"ui.progressBar.setColors"
///启用下拉刷新功能
#define PullToRefreshEnable @"ui.pullToRefresh.enable"
///收起下拉刷新控件
#define  StopRefersh @"ui.pullToRefresh.stop"
///禁用下拉刷新功能
#define ForbidRefersh @"ui.pullToRefresh.disable"
///启用webview下拉弹性效果
#define WebViewBounceAbled @"ui.webViewBounce.enable"
///禁用webview下拉弹性效果
#define ForbidWebViewRefersh @"ui.webViewBounce.disable"
////获取会话信息             未实现
#define GetConversationInfo @"biz.chat.getConversationInfo"
///地图搜索
#define MapSearch @"biz.map.search"
///地图定位
#define MapLocation @"biz.map.locate"
///扫码   文档上市scan  但代码中是qcode
#define DevoiceScan @"biz.util.qrcode"
///企业通讯录选人
#define ConstractChoosen @"biz.contact.choose"
////企业通讯录同时选人，选部门
#define complexChoose @"biz.contact.complexChoose"
///选群组
#define PickConversation @"biz.chat.pickConversation"
///选择会话
#define SelectConversation @"biz.chat.chooseConversation"
////设置导航icon
#define SetNaviIcon @"biz.navigation.setIcon"
///关闭webview
#define ShutWebView @"biz.navigation.close"
///上传照片（限制只能拍照）
#define UploadImageFromCamera @"biz.util.uploadImageFromCamera"
///弹层                  未实现
#define Danmodal @"device.notification.modal"
///检测是否安装微应用     未实现
#define CheckInstalledMicroapp @"internal.microapp.checkInstalled"
////可扩展弹层           未实现
#define ExtendModal @"device.notification.extendModal"
/// 自定义选人控件（多选）
#define MultipleChoose @"biz.customContact.multipleChoose"
//// 自定义选人控件      未实现
#define CustomerChooseMember @"biz.customContact.choose"
///根据corpId选择会话(2.6新增)  未实现
#define ChooseConversationByCorpId @"biz.chat.chooseConversationByCorpId"
///根据chatId调整到对应会话(2.6新增)   未实现
#define ToConversation @"biz.chat.toConversation"
//自加省市区
#define AreaActionSheet Device@"areaActionSheet"
//自加多选
#define MultiActionSheet Device@"multiActionSheet"
//自定义添加附件
#define UploadAttachment @"biz.util.uploadAttachment"


@interface HQWebJsManager : NSObject

+ (instancetype)shareInstanceJSManager;

@property (nonatomic,strong)WKWebViewJavascriptBridge *bridge;

- (void)registerJsHandlsWithWkWebVieW:(WKWebView *)webView;


@end
