//
//  HQWebJsManager.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/23.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQWebJsManager.h"


@implementation HQWebJsManager

+ (instancetype)shareInstanceJSManager{
    static HQWebJsManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HQWebJsManager alloc] init];
    });
    return manager;
}

- (void)registerJsHandlsWithWkWebVieW:(WKWebView *)webView{
     _bridge = [WKWebViewJavascriptBridge bridgeForWebView:webView];
    [WKWebViewJavascriptBridge enableLogging];
    ///UT打点   暂不实现
    [_bridge registerHandler:UTPoint handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@" UT打点  data %@",data);
    }];
    ///确认弹窗
    [_bridge registerHandler:Confirm handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@" 确认弹窗 data %@",data);

    }];
    ///alert
    [_bridge registerHandler:Alert handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@" Alert data %@",data);
    }];
    ///提示选择
    [_bridge registerHandler:Prompt handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@" 提示Plain data %@",data);
    }];
    //震动
    [_bridge registerHandler:Vibrate handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@" 震动 data %@",data);
    }];
    ///启动摇一摇     暂不实现
    [_bridge registerHandler:WatchShake handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@" 启动摇一摇 data %@",data);
    }];
    ///关闭摇一摇    暂不实现
    [_bridge registerHandler:ClearShake handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@" 关闭摇一摇 data %@",data);
    }];
    ///打开
    [_bridge registerHandler:Open handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@" 打开 data %@",data);
    }];
    ///打开外部URL     未找到接口
    [_bridge registerHandler:OpenLink handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@" 打开外部URL data %@",data);
    }];
    ///分享   暂不实现
    [_bridge registerHandler:Share handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@" 分享 data %@",data);
    }];
    ///显示londing
    [_bridge registerHandler:ShowPreloader handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@" 显示londing data %@",data);
    }];
    ///隐藏loading
    [_bridge registerHandler:HidePreloader handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"隐藏loading data %@",data);
    }];
    ///日期选择
    [_bridge registerHandler:Datepicker handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@" 日期选择 data %@",data);
    }];
    ///时间选择
    [_bridge registerHandler:Timepicker handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@" 时间选择 data %@",data);
    }];
    ///导航栏右侧按钮
    [_bridge registerHandler:SetRight handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@" 导航栏右侧按钮 data %@",data);
    }];
    ///导航栏左侧按钮
    [_bridge registerHandler:SetLeft handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@" 导航栏左侧按钮 data %@",data);
    }];
    
    ///设置导航栏title
    [_bridge registerHandler:SetTitle handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"设置导航栏title data %@",data);
    }];
    ///页面后退
    [_bridge registerHandler:Back handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"页面后退 %@",data);
    }];
    ///toast
    [_bridge registerHandler:Toast handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@" toast data %@",data);
    }];
    ///定位
    [_bridge registerHandler:LocationAddress handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@" 定位 data %@",data);
    }];
    ///上传图片
    [_bridge registerHandler:UploadImage handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@" 上传图片 data %@",data);
    }];
    ///浏览图片
    [_bridge registerHandler:PreviewImage handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@" 浏览图片 data %@",data);
    }];
    ///Plain
    [_bridge registerHandler:Plain handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@" Plain data %@",data);
    }];
    ///ACtionSheet
    [_bridge registerHandler:ActionSheet handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@" ACtionSheet data %@",data);
    }];
    ///网络类型
    [_bridge registerHandler:GetNetworkType handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@" 网络类型 data %@",data);
    }];
    ///容器信息   未实现
    [_bridge registerHandler:RunTimeInfo handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@" 容器信息 data %@",data);
    }];
    ///打电话
    [_bridge registerHandler:TelePohone handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@" 打电话 data %@",data);
    }];
    ///创建聊天   未实现
    [_bridge registerHandler:CreatGroup handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@" 创建聊天 data %@",data);
    }];
    ///  日期+时间选择器
    [_bridge registerHandler:DateTimePicker handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@" 日期+时间选择器 data %@",data);
    }];
    ///获取唯一标识码
    [_bridge registerHandler:GetUUID handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@" 获取唯一标识码 data %@",data);
    }];
    ///检测应用是否安装   未实现
    [_bridge registerHandler:CheckInstalledApp handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@" 检测应用是否安装 data %@",data);
    }];
    ///启动第三方app   未实现
    [_bridge registerHandler:LaunchApp handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@" 启动第三方app data %@",data);
    }];
    ///启用下拉刷新
    [_bridge registerHandler:PullToRefreshEnable handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"启用下拉刷新 data %@",data);
    }];
    ///收起下拉刷新控件
    [_bridge registerHandler:StopRefersh handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"收起下拉刷新控件 data %@",data);
    }];
    ///禁用下拉刷新
    [_bridge registerHandler:ForbidRefersh handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"禁用下拉刷新 data %@",data);
    }];
    ///启用bounce
    [_bridge registerHandler:WebViewBounceAbled handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"禁用下拉刷新 data %@",data);
    }];
    ///禁用bounce
    [_bridge registerHandler:ForbidWebViewRefersh handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"禁用下拉刷新 data %@",data);
    }];
    ///地图搜索
    [_bridge registerHandler:MapSearch handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"地图搜索 :data = %@",data);;
    }];
    ///地图定位
    [_bridge registerHandler:MapLocation handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"地图定位 data %@",data);
    }];
    ///扫码
    [_bridge registerHandler:DevoiceScan handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"扫码 data %@",data);
    }];
    ///通讯录选人
    [_bridge registerHandler:ConstractChoosen handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"通讯录选人 %@",data);
    }];
    ///部门选择
    [_bridge registerHandler:complexChoose handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@" 部门选择 data %@",data);
        //        [weekSelf selectMemeberFromCircle];
        //        _responseCallBack=responseCallback;
    }];
    ///选择组。
    [_bridge registerHandler:PickConversation handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@" 选择群 data %@",data);
        //        [weekSelf selectconverSation];
        //        _responseCallBack=responseCallback;
    }];
    ////选择会话
    [_bridge registerHandler:SelectConversation handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@" 选择会话 data %@",data);
        //        [weekSelf selectconverSation];
        //        _responseCallBack=responseCallback;
    }];
    ///设置导航栏icon
    [_bridge registerHandler:SetNaviIcon handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@" 设置导航栏icon data %@",data);

    }];
    ///关闭webView
    [_bridge registerHandler:ShutWebView handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"data %@",data);

    }];
    ///上传照片（限制只能拍照）
    [_bridge registerHandler:UploadImageFromCamera handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"上传照片（限制只能拍照） data %@",data);
    }];
    ///自定义选人控件  多选   未实现
    [_bridge registerHandler:MultipleChoose handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"自定义选人控件  多选 data %@",data);
    }];
    ////自加省市区选择
    [_bridge registerHandler:AreaActionSheet handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"data %@",data);
    }];
    //自加多选
    [_bridge registerHandler:MultiActionSheet handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"data %@",data);
    }];
    ///发钉   发送为自定义的消息类型
    [_bridge registerHandler:DingPost handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"发钉 data = %@",data);
    }];
    ///自定义添加附件
    [_bridge registerHandler:UploadAttachment handler:^(id data, WVJBResponseCallback responseCallback) {
    }];
}

@end
