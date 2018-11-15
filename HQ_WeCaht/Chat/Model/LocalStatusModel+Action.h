//
//  LocalStatusModel+Action.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/11/16.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "LocalStatusModel+CoreDataClass.h"

@interface LocalStatusModel (Action)

///自定义初始化
+ (LocalStatusModel *)customerInit;

///异步保存 
- (void)saveToDBChatLisModelAsyThread:(void (^)(BOOL result))complite;

////异步检索
+ (void)searchChatListModelOnAsyThreadComplite:(void (^)(NSArray<LocalStatusModel *> *resultList))resultBack;




@end
