//
//  ChatListModel+Action.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/2/20.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "ChatListModel+CoreDataClass.h"

@interface ChatListModel (Action)


/////chatListType  1好友或者群   100系统消息   101工作通知   
/////chatListId   如果chatListType = 1      chatListId 是好友或者群的id

/**
 自定义初始化
 @return ChatListModel
 */
+ (ChatListModel *)customerInit;



/**
 更新ChatListModel 的消息体

 @param messageModel 聊天消息
 */
- (void)refershChatListModelWith:(ChatMessageModel *)messageModel;






#pragma mark ------- 数据库管理   ------


/**
  异步检索 查找一条非user chatListModel

 @param chatListType chatListType
 @param complite 回调
 */
+ (void)ASselectNoUserChatListMOdelWith:(NSInteger )chatListType complite:(void (^)(ChatListModel *listModel))complite;

/**
 同步检索 查找一条非user chatListModel

 @param chatListType chatListType chatListType
 @param complite complite 回调
 */
+ (void)mainThreadNoUserChatListModelWith:(NSInteger) chatListType complite:(void (^) (ChatListModel *listModel))complite;


/**
 同步检索user同步 chatListModel

 @param chatListId listId
 @param complite chatListModel
 */
+ (void)searchAnUserChatListOnMainThreadWith:(NSInteger)chatListId  complite:(void (^)(ChatListModel *listModel))complite;


/**
 异步检索user异步  chatListModel

 @param chatListId chatListId listId
 @param complite chatListModel
 */
+ (void)searchAnUserChatListOnOtherThreadWith:(NSInteger)chatListId complite:(void (^)(ChatListModel *listModel))complite;

////接收消息查询
+ (void)customerSearchAnUserChatListWith:(NSInteger)chatListId  complite:(void (^)(ChatListModel *listModel))complite;
/**
 同步 查询消息列表的数据

 @param resultCallBack 回调
 */
+ (void)selectChatListShowOnMainThreadWith:(void (^)(NSArray *result))resultCallBack;

/**
 异步 查询消息列表的数据

 @param resultCallBack 回调
 */
+ (void)selectChatListShowOnOtherThreadWith:(void (^)(NSArray *resulr))resultCallBack;

///同步保存
- (void)saveToDBChatListModelOnMainThread:(void (^)())success andError:(void (^)())errorCallBack;
////异步保存
- (void)saveToDBChatLisModelAsyThread:(void (^)())success andError:(void (^)())faild;
////同步保存
+ (void)searchChatListModelOnAsyThread:(void (^)(NSArray *resultList))resultBack;
////主线程  要求等待
+ (void)searchChatLstOnMainThreadPerformWait:(void (^)(NSArray *resultArray))result;
////检索object数量 异步
+ (void)countForChatListToDBAsyThread:(void (^)(NSInteger count))success andError:(void (^)())errorBack;


/**
 update  同步

 @param success 回调
 @param faild 回调
 */
- (void)UpDateFromDBONMainThread:(void(^)())success andError:(void (^)())faild;


/**
 update  异步

 @param success 回调
 @param faild 回调
 */
- (void)UPDateFromDBOnOtherThread:(void(^)())success andError:(void (^)())faild;




/**
 消息置顶

 @param isOn 开关状态
 @param complite 完成回调
 */
- (void)chatListPlaceToTopWithIsOn:(BOOL )isOn Complite:(void (^)())complite;

/**
 模糊搜索

 @param searchKey 关键字
 @param complite 完成回调
 */
+ (void)fuzzySearchWithSearchKey:(NSString *)searchKey andComplite:(void (^)(NSArray *result , NSArray *messages))complite;
@end
