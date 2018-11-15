//
//  HQEnumDefine.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/1.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#ifndef HQEnumDefine_h
#define HQEnumDefine_h

typedef NS_ENUM(NSInteger, HQChatBoxStatus) {
    HQChatBoxStatusNothing = 0,          // 默认状态
    HQChatBoxStatusShowVoice,            // 录音状态
    HQChatBoxStatusShowFace,             // 输入表情状态
    HQChatBoxStatusShowMore,             // 显示“更多”页面状态
    HQChatBoxStatusShowKeyboard,         // 正常键盘
    HQChatBoxStatusShowVideo             // 录制视频
};



// 消息类型
typedef enum {
    HQMessageType_Text  = 1,             // 文本
    HQMessageType_Voice,                 // 短录音
    HQMessageType_Image,                 // 图片
    HQMessageType_Video,                 // 短视频
    HQMessageType_Doc,                   // 文档
    HQMessageType_TextURL,               // 文本＋链接
    HQMessageType_ImageURL,              // 图片＋链接
    HQMessageType_URL,                   // 纯链接
    HQMessageType_DrtNews,               // 送达号
    HQMessageType_NTF ,                  // 通知
    HQMessageType_DTxt,                  // 纯文本
    HQMessageType_DPic,                  // 文本＋单图
    HQMessageType_DMPic,                 // 文本＋多图
    HQMessageType_DVideo,                // 文本＋视频
    HQMessageType_PicURL                 // 动态图文链接
    
}HQMessageType;


// 消息发送状态
typedef enum {
    HQMessageDeliveryState_Pending = 0,  // 待发送 待下载
    HQMessageDeliveryState_Delivering,   // 正在发送  正在下载
    HQMessageDeliveryState_Delivered,    // 已发送，下载 成功
    HQMessageDeliveryState_Failure,      // 发送 下载 失败
    
}HQMessageDeliveryState;





#endif /* HQEnumDefine_h */
