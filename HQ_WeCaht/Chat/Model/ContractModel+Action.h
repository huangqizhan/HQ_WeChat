//
//  ContractModel+Action.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/4/14.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "ContractModel+CoreDataClass.h"

@interface ContractModel (Action)

@property (nonatomic,strong)UIImage *tempImage;



+ (ContractModel *)customerInit;


#pragma mark ------- 数据库管理   ------

///同步保存
- (void)saveToDBUserModelOnMainThread:(void (^)())success andError:(void (^)())errorCallBack;

////异步保存
- (void)saveToDBUserModelAsyThread:(void (^)())success andError:(void (^)())faild;

////同步保存
+ (void)searchUserModelOnAsyThread:(void (^)(NSArray *resultList,NSArray *locaArr))resultBack;

////主线程  要求等待
+ (void)searchUserOnMainThreadPerformWait:(void (^)(NSArray *resultArray))result;

///根据id获取联系人 主线程
+ (ContractModel *)seachContractModelWith:(NSString *)contractId;

/////检索联系人  异步线程
+ (void)searchContractModelWithContractModelWith:(NSString *)contractId complite:(void (^)(ContractModel *contractModel))complite;

////检索object数量 异步
+ (void)countForUserToDBAsyThread:(void (^)(NSInteger count))success andError:(void (^)())errorBack;

/////同步删除
- (void)removeFromDBOnMainThread:(void (^)())success andError:(void (^)())faild;

////异步删除
- (void)removeFromDBOnOtherThread:(void(^)())success andError:(void (^)())faild;

////同步修改
- (void)UpDateFromDBONMainThread:(void(^)())success andError:(void (^)())faild;

////异步修改
- (void)UPDateFromDBOnOtherThread:(void(^)())success andError:(void (^)())faild;



@end
