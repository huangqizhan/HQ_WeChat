//
//  DownloadFileModel+Action.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/29.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "DownloadFileModel+CoreDataClass.h"

@interface DownloadFileModel (Action)
///自定义初始化
+ (DownloadFileModel *)customerInit;

///同步保存
- (void)saveToDBChatListModelOnMainThread:(void (^)(BOOL result))complite;

////异步保存
- (void)saveToDBChatLisModelAsyThread:(void (^)(BOOL result))complite;

///异步检索
+ (void)searchChatListModelOnAsyThreadWithSearchType:(NSString *)type andComplite:(void (^)(NSArray *resultList))resultBack;

////主线程  要求等待
+ (void)searchChatLstOnMainThreadPerformWaitWithType:(NSString *)type andComplite:(void (^)(NSArray *resultArray))resultBack;

////同步修改
- (void)UpDateFromDBONMainThread:(void(^)(BOOL result))complite;

////异步修改
- (void)UPDateFromDBOnOtherThread:(void(^)())success andError:(void (^)())faild;

/////同步删除
- (void)removeFromDBOnMainThread:(void (^)(BOOL rsult))complite;

////异步删除
- (void)removeFromDBOnOtherThread:(void(^)(BOOL result))complite;
@end
