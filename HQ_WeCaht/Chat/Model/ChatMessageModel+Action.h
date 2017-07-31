//
//  ChatMessageModel+Action.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/8.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "ChatMessageModel+CoreDataClass.h"
#import "ChatListModel+Action.h"
#import <ImageIO/ImageIO.h>
#import <CoreLocation/CoreLocation.h>


typedef void (^ChatMessageCallBack) ();

typedef void (^ChatMessageSendStatusCallBack)(HQMessageDeliveryState status);


@interface ChatMessageModel (Action)

/////  messageStatus 0等待  1 正在加载 下载  2完成  3失败

///// messageType 1 文本    2 图片  3GIF 4语音  5正在录音  6视频  7文件  8定位  99时间  100 系统消息  101 工作通知

/**
 自定义初始化

 @return ChatMessageModel
 */
+ (ChatMessageModel *)customerInit;


/**
 创建一条发送的文本消息

 @param contentString 文本消息内容
 @return ChatMessageModel
 */
+ (ChatMessageModel *)creatAnSnedMesssageWith:(NSString *)contentString andReceiverId:(NSInteger)receiverId andUserName:(NSString *)userName andUserPic:(NSString *)headPic;


/**
 创建一条收到的文本消息

 @param contentStr 文本内容
 @param speakerId 发送人
 @return 消息体
 */
+ (ChatMessageModel *)creatAnReceiveTextMessageWith:(NSString *)contentStr andSpeakerId:(NSInteger )speakerId andUserName:(NSString *)userName andUserPic:(NSString *)headPic;
/**
 创建一条发送的图片消息

 @param image image
 @parm 路径
 @return self
 */
+ (ChatMessageModel *)creatAnSendImageMessageWith:(UIImage *)image andImagePath:(NSString *)imagePath andImageName:(NSString *)imageName andReceiverId:(NSInteger)receiverId andUserName:(NSString *)userName andUserPic:(NSString *)headPic;

/**
 创建一条GIF发送消息

 @param fileName 文件名
 @param receiveid 接收人id
 @return self
 */
+ (ChatMessageModel *)creatAnSendGifMessageWith:(NSString *)fileName andReceiveId:(NSInteger )receiveid andUserName:(NSString *)userName andUserPic:(NSString *)headPic;

/**
 创建一条GIF接收消息

 @param fileName 文件地址
 @param speakerId 发送人id
 @return 消息体
 */
+ (ChatMessageModel *)creatAnReceiveGifMessageWith:(NSString *)fileName andSpeakerId:(NSInteger )speakerId andUserName:(NSString *)userName andUserPic:(NSString *)headPic;

/**
 创建一条发送的语音消息

 @param filePath 路径
 @param receiveId 接收人
 @return 消息体
 */
+ (ChatMessageModel *)createAnSendAudioMessageWith:(NSString *)filePath andReceiveId:(NSInteger)receiveId andUserName:(NSString *)userName andUserPic:(NSString *)headPic;

/**
 创建一条接受的语音消息

 @param filePath 文件名
 @param speakerId 发消息人
 @return 消息体
 */
+ (ChatMessageModel *)createAnReceiveAudioMessageWith:(NSString *)filePath andSpearkerId:(NSInteger )speakerId andFileSize:(NSString *)fileSize andUserName:(NSString *)userName andUserPic:(NSString *)headPic;

/**
 创建一条正在录音的消息

 @param filePath filePath
 @param receiveId 接收人
 @return 消息体
 */
+ (ChatMessageModel *)creatAnRecordingMessageWith:(NSString *)filePath andReceiveId:(NSInteger)receiveId andUserName:(NSString *)userName andUserPic:(NSString *)headPic;

/**
 创建一条发送的定位消息

 @param image 定位图片
 @param coor2d 经纬度
 @param address 地址
 @param userName 接收人姓名
 @param headPic 头像
 @param reveiveId 接收人id
 @return 消息体
 @fileName 文件名
 */
+ (ChatMessageModel *)creatAnSendLoactionMessageWith:(UIImage *)image andLocation:(CLLocationCoordinate2D )coor2d andAddress:(NSString *)address andUserName:(NSString *)userName andPic:(NSString *)headPic andFileName:(NSString *)fileName  andReceived:(NSInteger )reveiveId;


/**
 创建一条接收的定位消息

 @param image 位置图片
 @param coor2d 经纬度
 @param address 地址
 @param userName 发送人姓名
 @param headPic 发送人头像
 @param fileName 文件名
 @param speakerId 发送人id
 @return 消息体
 */
+ (ChatMessageModel *)createAnReceiveLocationMessageWith:(UIImage *)image andLocation:(CLLocationCoordinate2D )coor2d andAddress:(NSString *)address andUserName:(NSString *)userName andPic:(NSString *)headPic andFileName:(NSString *)fileName  andSpeakerId:(NSInteger )speakerId;
/**
 创建一条发送的时间消息

 @param receiveId 接收人id
 @return 消息体
 */
+ (ChatMessageModel *)creatAnSendDateMessageWithReceiveId:(NSInteger)receiveId;

/**
 创建一条接收时间消息

 @param speakerId 消息发送人
 @return 消息体
 */
+ (ChatMessageModel *)creatAnReceiveDataMessageWithSpeakerId:(NSInteger)speakerId;
/**
 创建聊天cell时的 cellid

 @return string
 */
- (NSString *)messageCellTypeId;

////计算语音播放条长度
- (CGFloat)caculateVoiceViewWidth:(NSString *)fileSize;
/**
 重新定义消息的发送状态
 */
@property (nonatomic,assign)HQMessageDeliveryState deliverStatus; 

@property (nonatomic,copy)void (^ChatMessageSendStatusCallBack)(HQMessageDeliveryState status);

////文本消息的属性字符串  
@property (nonatomic,strong) NSMutableAttributedString *muAttributeString;

////存放临时的图片数据
@property (nonatomic,strong) UIImage *tempImage;

#pragma mark -------- GIF ----
////GIF数据
@property (nonatomic,strong) NSData *gifImageData;
///GIF数据源
@property (nonatomic,assign) CGImageSourceRef sourseRef;
////当前播放的索引
@property (nonatomic,assign) int  gifPlyIndex;
////gif 总的帧数
@property (nonatomic,assign) int  gifFrameCount;
///播放时间
@property (nonatomic,assign)float gifTimestamp;
///当前播放时间进度
@property (nonatomic,assign)float currentPlayProgress;
////播放队列
@property (strong, nonatomic) NSOperationQueue *gifPlayQueue;
////是否正在播放  语音 视频
@property (nonatomic,assign) BOOL isPlaying;
////消息cell 是否被选中
@property (nonatomic,assign) BOOL isSeleted;

#pragma mark ----- 网络 ---------
////待处理
- (void)sendTextMessage:(ChatMessageCallBack)callBack;
///语音消息
- (void)sendVoiceMessageWithCallBack:(ChatMessageCallBack)callBack;



























#pragma mark ------- 数据库管理   ------

///同步保存
- (void)saveToDBChatListModelOnMainThread:(void (^)())success andError:(void (^)())errorCallBack;

////异步保存
- (void)saveToDBChatLisModelAsyThread:(void (^)())success andError:(void (^)())faild;


/**
 进入聊天界面时检索聊天数据

 @param listModel chatListModel
 @param resultBack 回调
 */
+ (void)searchChatListModelOnAsyThreadWith:(ChatListModel *)listModel andCallBack:(void (^)(NSArray *resultList))resultBack;

////主线程  要求等待
+ (void)searchChatLstOnMainThreadPerformWait:(void (^)(NSArray *resultArray))result;

///  异步检索更多聊天数据
+ (void)searchMoreChatListModelOnAsyThreadWith:(ChatListModel *)listModel WithModel:(ChatMessageModel *)model andCallBack:(void (^)(NSArray *resultList))resultBack;

////检索object数量 异步
+ (void)countForChatListToDBAsyThread:(void (^)(NSInteger count))success andError:(void (^)())errorBack;

/////同步删除
- (void)removeFromDBOnMainThread:(void (^)())success andError:(void (^)())faild;

////异步删除
- (void)removeFromDBOnOtherThread:(void(^)())success andError:(void (^)())faild;

////同步修改
- (void)UpDateFromDBONMainThread:(void(^)())success andError:(void (^)())faild;

////异步修改
- (void)UPDateFromDBOnOtherThread:(void(^)())success andError:(void (^)())faild;


////异步删除多条消息
+ (void)removeMoreMessgaeModels:(NSArray <ChatMessageModel *>*)models andSuccess:(void (^)())success andFaild:(void (^)())faild;


////异步删除一组聊天数据
+ (void)deleteChatGroupMessageWith:(ChatListModel *)listModel andComplite:(void (^)(BOOL isSuccess))complite;
@end
