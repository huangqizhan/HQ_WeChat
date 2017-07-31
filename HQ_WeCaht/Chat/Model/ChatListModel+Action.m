//
//  ChatListModel+Action.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/2/20.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "ChatListModel+Action.h"

@implementation ChatListModel (Action)


+ (ChatListModel *)customerInit{
    return [[ChatListModel alloc] initWithContext:[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext];
}
- (NSString *)chatContent{
    if (self.chatListType == 100) {
        return @"暂无消息";
    }else if (self.chatListType == 101){
        return @"暂无消息";
    }else if (self.chatListType == 1){
        return self.message.contentString;
    }else if (self.chatListType == 2){
        return @"图片";
    }else if (self.chatListType == 3){
        return self.message.fileName;
    }else if (self.chatListType == 4){
        return @"语音";
    }else if (self.chatListType == 8){
        return @"位置";
    }else{
        return @"";
    }
}
- (int32_t)chatListType{
    return self.message.messageType;
}
- (int64_t)messageTime{
    return self.message.messageTime;
}
- (void)refershChatListModelWith:(ChatMessageModel *)messageModel{
    self.message = messageModel;
    self.messageTime = messageModel.messageTime;
}
/**
 异步检索 查找一条非user chatListModel
 
 @param chatListType chatListType
 @param complite 回调
 */

+ (void)ASselectNoUserChatListMOdelWith:(NSInteger )chatListType complite:(void (^)(ChatListModel *listModel))complite{
    if (chatListType <=  0) return;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([ChatListModel class])];
    NSString *filter = [NSString stringWithFormat:@"chatListType = %ld",chatListType];
    NSPredicate *pre = [NSPredicate predicateWithFormat:filter];
    request.predicate = pre;
    [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext performBlock:^{
       NSError *error;
       NSArray *result = [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext executeFetchRequest:request error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complite){
                if (result.count) {
                    complite([result firstObject]);
                }
            }
        });
    }];
}
/**
 同步检索 查找一条非user chatListModel
 
 @param chatListType chatListType chatListType
 @param complite complite 回调
 */
+ (void)mainThreadNoUserChatListModelWith:(NSInteger) chatListType complite:(void (^) (ChatListModel *listModel))complite{
    if (chatListType <= 0) return;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([ChatListModel class])];
    NSString *filter = [NSString stringWithFormat:@"chatListType = %ld",chatListType];
    NSPredicate *pre = [NSPredicate predicateWithFormat:filter];
    request.predicate = pre;
    [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext performBlockAndWait:^{
        NSError *error;
        NSArray *result = [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext executeFetchRequest:request error:&error];
        if (result.count) {
            if (complite) complite(result.firstObject);
        }
    }];
}
/**
 同步检索user同步 chatListModel
 
 @param chatListId listId
 @param complite chatListModel
 */
+ (void)searchAnUserChatListOnMainThreadWith:(NSInteger)chatListId  complite:(void (^)(ChatListModel *listModel))complite{
    if (chatListId <=  0) return;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([ChatListModel class])];
    NSString *filter = [NSString stringWithFormat:@"chatListId = %ld",chatListId];
    NSPredicate *pre = [NSPredicate predicateWithFormat:filter];
    request.predicate = pre;

    [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext performBlockAndWait:^{
        NSError *error;
        NSArray *result = [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext executeFetchRequest:request error:&error];
        if (result.count) {
            if (complite) complite(result.firstObject);
        }
    }];
}
+ (void)customerSearchAnUserChatListWith:(NSInteger)chatListId  complite:(void (^)(ChatListModel *listModel))complite{
    if (chatListId <=  0) return;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([ChatListModel class])];
    NSString *filter = [NSString stringWithFormat:@"chatListId = %ld",chatListId];
    NSPredicate *pre = [NSPredicate predicateWithFormat:filter];
    request.predicate = pre;
    
    NSError *error;
    NSArray *result = [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext executeFetchRequest:request error:&error];
    if (result.count) {
        if (complite) complite(result.firstObject);
    }
}

/**
 异步检索user异步  chatListModel
 
 @param chatListId chatListId listId
 @param complite chatListModel
 */
+ (void)searchAnUserChatListOnOtherThreadWith:(NSInteger)chatListId complite:(void (^)(ChatListModel *listModel))complite{
    if (chatListId <= 0) return;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([ChatListModel class])];
    NSString *filter = [NSString stringWithFormat:@"chatListId = %ld",chatListId];
    NSPredicate *pre = [NSPredicate predicateWithFormat:filter];
    request.predicate = pre;
    [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext performBlock:^{
        NSError *error;
        NSArray *result = [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext executeFetchRequest:request error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complite){
                if (result.count) {
                    complite([result firstObject]);
                }
            }
        });
    }];
}

/**
 同步 查询消息列表的数据
 
 @param resultCallBack 回调
 */
+ (void)selectChatListShowOnMainThreadWith:(void (^)(NSArray *resulr))resultCallBack{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([ChatListModel class])];
    NSString *filter = [NSString stringWithFormat:@"isShow = YES"];
    NSPredicate *pre = [NSPredicate predicateWithFormat:filter];
    request.predicate = pre;
    [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext performBlockAndWait:^{
        NSError *error;
        NSArray *result = [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext executeFetchRequest:request error:&error];
        if (resultCallBack) resultCallBack(result);
    }];

}

/**
 异步 查询消息列表的数据
 
 @param resultCallBack 回调
 */
+ (void)selectChatListShowOnOtherThreadWith:(void (^)(NSArray *result))resultCallBack{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([ChatListModel class])];
    NSSortDescriptor *des2 = [[NSSortDescriptor alloc] initWithKey:@"topMessageNum" ascending:NO];
    NSSortDescriptor *des1 = [[NSSortDescriptor alloc] initWithKey:@"messageTime" ascending:NO];
    request.sortDescriptors = @[des1,des2];
    NSString *filter = [NSString stringWithFormat:@"isShow = YES"];
    NSPredicate *pre = [NSPredicate predicateWithFormat:filter];
    request.predicate = pre;
    [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext performBlock:^{
        NSError *error;
        NSArray *result = [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext executeFetchRequest:request error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (resultCallBack) resultCallBack(result);
        });
    }];
}

///同步保存
- (void)saveToDBChatListModelOnMainThread:(void (^)())success andError:(void (^)())errorCallBack{
    
    [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext performBlockAndWait:^{
        NSError *error;
        [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext save:&error];
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (error) {
                if (errorCallBack) errorCallBack();
            }else{
                if (success) success();
            }
        });
    }];
}
////异步保存
- (void)saveToDBChatLisModelAsyThread:(void (^)())success andError:(void (^)())faild{    
    [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext performBlock:^{
        NSError *error;
        [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext save:&error];
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (error) {
               if (faild)  faild();
            }else{
                if (success) success();
            }
        });
    }];
}
///异步检索
+ (void)searchChatListModelOnAsyThread:(void (^)(NSArray *resultList))resultBack{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([ChatListModel class])];
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
+ (void)searchChatLstOnMainThreadPerformWait:(void (^)(NSArray *resultArray))resultBack{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([ChatListModel class])];
    [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext performBlockAndWait:^{
        NSError *error;
        NSArray *arrays = [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext executeFetchRequest:request error:&error];
        if (resultBack) resultBack(arrays);
    }];
}
////检索object数量  异步
+ (void)countForChatListToDBAsyThread:(void (^)(NSInteger count))success andError:(void (^)())errorBack{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([ChatListModel class])];
    [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext performBlock:^{
        NSError *error;
        NSInteger count = [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext countForFetchRequest:request error:&error];
        if (error) {
            if (errorBack) errorBack();
        }else{
            if (errorBack) success(count);
        }
    }];
}

////同步修改
- (void)UpDateFromDBONMainThread:(void(^)())success andError:(void (^)())faild{
    [[HQCoreDataManager shareCoreDataManager] .asyManagerSaveObjextContext performBlockAndWait:^{
        [[HQCoreDataManager shareCoreDataManager] .asyManagerSaveObjextContext refreshObject:self mergeChanges:YES];
        NSError *error;
        [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext save:&error];
        if (error) {
            if(faild) faild();
        }else{
            if (success) success();
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
///消息置顶
- (void)chatListPlaceToTopWithIsOn:(BOOL )isOn Complite:(void (^)())complite{
    if (isOn) {
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([ChatListModel class])];
        NSSortDescriptor *des2 = [[NSSortDescriptor alloc] initWithKey:@"topMessageNum" ascending:NO];
        request.sortDescriptors = @[des2];
        request.fetchOffset = 0;
        request.fetchLimit = 1;
        //    NSString *filter = [NSString stringWithFormat:@"isShow = YES"];
        //    NSPredicate *pre = [NSPredicate predicateWithFormat:filter];
        //    request.predicate = pre;
        [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext performBlock:^{
            NSError *error;
            NSArray *result = [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext executeFetchRequest:request error:&error];
            self.isPlaceTop = isOn;
            if (result.count) {
                ChatListModel *listModel = [result firstObject];
                self.isShow = YES;
                self.topMessageNum = listModel.topMessageNum+1;
            }else{
                self.isShow = YES;
                self.topMessageNum = 2;
            }
            [self UpDateFromDBONMainThread:nil andError:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (complite) {
                    complite();
                }
            });
        }];
    }else{
        self.topMessageNum = 0;
        self.isPlaceTop = isOn;
        [self UPDateFromDBOnOtherThread:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (complite) {
                    complite();
                }
            });
        } andError:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (complite) {
                    complite();
                }
            });
        }];
    }
}
///模糊查询
+ (void)fuzzySearchWithSearchKey:(NSString *)searchKey andComplite:(void (^)(NSArray *result,NSArray *messages))complite{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([ChatListModel class])];

    NSString *filter = [NSString stringWithFormat:@"userName CONTAINS '%@'",searchKey];
    NSPredicate *pre = [NSPredicate predicateWithFormat:filter];
    request.predicate = pre;
    
    NSFetchRequest *messageRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([ChatMessageModel class])];
    NSString *messageFilter=  [NSString stringWithFormat:@"contentString  CONTAINS '%@'",searchKey];
    NSPredicate *messagePre = [NSPredicate predicateWithFormat:messageFilter];
    messageRequest.predicate = messagePre;
    
    [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext performBlock:^{
        NSError *error;
        NSArray *result = [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext executeFetchRequest:request error:&error];
        NSError *messgeError;
        NSArray *messageResult = [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext executeFetchRequest:messageRequest error:&messgeError];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complite) complite(result,messageResult);
        });
    }];
}
@end
