//
//  LocalStatusModel+Action.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/11/16.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "LocalStatusModel+Action.h"

@implementation LocalStatusModel (Action)

+ (LocalStatusModel *)customerInit{
    return [[LocalStatusModel alloc] initWithContext:[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext];
}
////异步保存
- (void)saveToDBChatLisModelAsyThread:(void (^)(BOOL result))complite{
    [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext performBlock:^{
        NSError *error;
        [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext save:&error];
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (error) {
                if (complite) complite(NO);
            }else{
                if (complite) complite(YES);
            }
        });
    }];
}
///异步检索
+ (void)searchChatListModelOnAsyThreadComplite:(void (^)(NSArray<LocalStatusModel * > *resultList))resultBack{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([LocalStatusModel class])];
    ////异步线程
    [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext performBlock:^{
        NSError *error;
        NSArray *arrays = [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext executeFetchRequest:request error:&error];
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (resultBack) resultBack(arrays);
        });
    }];
}


@end
