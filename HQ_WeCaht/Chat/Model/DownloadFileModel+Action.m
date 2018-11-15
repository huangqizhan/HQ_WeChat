//
//  DownloadFileModel+Action.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/29.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "DownloadFileModel+Action.h"

@implementation DownloadFileModel (Action)

+ (DownloadFileModel *)customerInit{
    return [[DownloadFileModel alloc] initWithContext:[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext];
}

///同步保存
- (void)saveToDBChatListModelOnMainThread:(void (^)(BOOL result))complite{
    
    [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext performBlockAndWait:^{
        NSError *error;
        [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext save:&error];
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (error) {
               if (complite)  complite(NO);
            }else{
               if (complite)  complite(YES);
            }
        });
    }];
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
+ (void)searchChatListModelOnAsyThreadWithSearchType:(NSString *)type andComplite:(void (^)(NSArray *resultList))resultBack{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([DownloadFileModel class])];
    NSString *filterStr = [NSString stringWithFormat:@"downLoadType = '%@'",type];
    NSPredicate *pre = [NSPredicate predicateWithFormat:filterStr];
    request.predicate = pre;
    ////异步线程
    [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext performBlock:^{
        NSError *error;
        NSArray *arrays = [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext executeFetchRequest:request error:&error];
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (resultBack) resultBack(arrays);
        });
    }];
}
////主线程  要求等待
+ (void)searchChatLstOnMainThreadPerformWaitWithType:(NSString *)type andComplite:(void (^)(NSArray *resultArray))resultBack{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([DownloadFileModel class])];
    NSString *filterStr = [NSString stringWithFormat:@"downLoadType = '%@'",type];
    NSPredicate *pre = [NSPredicate predicateWithFormat:filterStr];
    request.predicate = pre;
    [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext performBlockAndWait:^{
        NSError *error;
        NSArray *arrays = [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext executeFetchRequest:request error:&error];
        if (resultBack) resultBack(arrays);
    }];
}
////同步修改
- (void)UpDateFromDBONMainThread:(void(^)(BOOL result))complite{
    [[HQCoreDataManager shareCoreDataManager] .asyManagerSaveObjextContext performBlockAndWait:^{
        [[HQCoreDataManager shareCoreDataManager] .asyManagerSaveObjextContext refreshObject:self mergeChanges:YES];
        NSError *error;
        [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext save:&error];
        if (error) {
            if(complite) complite(NO);
        }else{
            if (complite) complite(YES);
        }
    }];
}
////异步修改
- (void)UPDateFromDBOnOtherThread:(void(^)())success andError:(void (^)())faild{
    [[HQCoreDataManager shareCoreDataManager] .asyManagerSaveObjextContext performBlock:^{
        [[HQCoreDataManager shareCoreDataManager] .asyManagerSaveObjextContext refreshObject:self mergeChanges:YES];
        NSError *error;
        [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext save:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                if(faild) faild();
            }else{
                if (success) success();
            }
        });
    }];
}
/////同步删除
- (void)removeFromDBOnMainThread:(void (^)(BOOL rsult))complite{
    [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext performBlockAndWait:^{
        NSError *error;
        [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext deleteObject:self];
        [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext save:&error];
        if (error) {
            if (complite) complite(NO);
        }else{
            if (complite) complite(YES);
        }
    }];
}
////异步删除
- (void)removeFromDBOnOtherThread:(void(^)(BOOL result))complite{
    [[HQCoreDataManager shareCoreDataManager] .asyManagerSaveObjextContext performBlock:^{
        NSError *error;
        [[HQCoreDataManager shareCoreDataManager] .asyManagerSaveObjextContext deleteObject:self];
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


@end
