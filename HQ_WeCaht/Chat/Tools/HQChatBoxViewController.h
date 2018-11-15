//
//  HQChatBoxViewController.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/1.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HQChatBox.h"


@class HQChatBoxViewController;

@protocol ICChatBoxViewControllerDelegate <NSObject>

@optional;

/**
 输入框高度变化

 @param chatboxViewController HQChatBoxViewController
 @param height 变化高度
 */
- (void) chatBoxViewController:(HQChatBoxViewController *)chatboxViewController
        didChangeChatBoxHeight:(CGFloat)height;

/**
 输入框状态发生变化

 @param chatboxViewController self
 @param height 不同状态的不同高度
 */
- (void)chatBoxInputStatusController:(HQChatBoxViewController *)chatboxViewController
        ChatBoxHeight:(CGFloat)height;
/**
 *  发送文本消息
 *
 *  @param chatboxViewController self
 *  @param messageStr            text
 */
- (void) chatBoxViewController:(HQChatBoxViewController *)chatboxViewController
               sendTextMessage:(NSString *)messageStr;
/**
 *  发送图片消息
 *
 *  @param chatboxViewController self
 *  @param image                 image
 *  @param imgPath               image path
 */
- (void) chatBoxViewController:(HQChatBoxViewController *)chatboxViewController
              sendImageMessage:(NSArray<UIImage *> *)image
                     imagePath:(NSArray<NSString *> *)imgPath
                   andFileName:(NSArray<NSString *> *)fileName;

/**
 发送表情

 @param chatboxViewController self
 @param gifFileName 文件名
 */
- (void) chatBoxViewController:(HQChatBoxViewController *)chatboxViewController
              sendGifMessage:(NSString *)gifFileName;

/**
 创建一条语音消息显示在聊天消息列表上

 @param chatboxViewController self
 @param filePath filePath
 */
- (void) chatBoxViewControllerCreateAudioMessage:(HQChatBoxViewController *)chatboxViewController andFilePath:(NSString *)filePath;


/**
 语音录制完成

 @param chatboxViewController self
 @param filePath filePath
 */
- (void) chatBoxViewControllerDidFinishRecord:(HQChatBoxViewController *)chatboxViewController andFilePath:(NSString *)filePath andVoiceDuration:(CFTimeInterval)duration;

/**
 删除当前正在录音的消息

 @param chatboxViewController self
 @param filePath filePath
 */
- (void) chatBoxViewControllerRemoveAudioMessage:(HQChatBoxViewController *)chatboxViewController andFilePath:(NSString *)filePath;


/**
 更新当前正在录音的消息体的录音时间

 @param chatboxViewController self
 @param filePath filePath
 @param duration 时间
 */
- (void) chatBoxViewControllerUpdateAudioMessage:(HQChatBoxViewController *)chatboxViewController andFilePath:(NSString *)filePath andTimeral:(NSTimeInterval )duration;

/**
 发送定位消息

 @param chatBoxViewController self
 @param image 定位图片
 @param coor2D coordinate
 @param address 位置
 */
- (void) chatBoxViewControllerSendlocationMessage:(HQChatBoxViewController *)chatBoxViewController andImage:(UIImage *)image andLocation:(CLLocationCoordinate2D )coor2D andAddress:(NSString *)address andFileName:(NSString *)fileName;



@end



@interface HQChatBoxViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate>


@property (nonatomic,strong) HQChatBox *chatBox;

@property (nonatomic,assign)id <ICChatBoxViewControllerDelegate>delegate;


@end
