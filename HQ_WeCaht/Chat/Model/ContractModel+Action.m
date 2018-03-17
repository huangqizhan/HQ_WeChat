//
//  ContractModel+Action.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/4/14.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "ContractModel+Action.h"

@implementation ContractModel (Action)


+ (ContractModel *)customerInit{
    return [[ContractModel alloc] initWithContext:[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext];
}

- (void)setTempImage:(UIImage *)tempImage{
    objc_setAssociatedObject(self, @selector(tempImage), tempImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)tempImage{
    return objc_getAssociatedObject(self, _cmd);
}

#pragma mark ---------- 数据库 ----

///同步保存
- (void)saveToDBUserModelOnMainThread:(void (^)())success andError:(void (^)())errorCallBack{
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
- (void)saveToDBUserModelAsyThread:(void (^)())success andError:(void (^)())faild{
    [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext performBlock:^{
        NSError *error;
        [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext save:&error];
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (error) {
                if (faild) faild();
            }else{
                if (success) success();
            }
        });
    }];
}
///  异步检索所有联系人
+ (void)searchUserModelOnAsyThread:(void (^)(NSArray *resultList ,NSArray *locaArr))resultBack{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([ContractModel class])];
    ////异步线程
    [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext performBlock:^{
        NSError *error;
        NSArray *arrays = [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext executeFetchRequest:request error:&error];
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSString *filter = [NSString stringWithFormat:@"userType = 'user'"];
            NSPredicate *pre = [NSPredicate predicateWithFormat:filter];
            NSArray *users = [arrays filteredArrayUsingPredicate:pre];
            NSString *filter1 = [NSString stringWithFormat:@"userType != 'user'"];
            NSPredicate *pre1 = [NSPredicate predicateWithFormat:filter1];
            NSArray *locaArr = [arrays filteredArrayUsingPredicate:pre1];
            NSSortDescriptor *des = [[NSSortDescriptor alloc] initWithKey:@"createTime" ascending:YES];
            locaArr = [locaArr sortedArrayUsingDescriptors:@[des]];
            if (resultBack) resultBack(users ,locaArr);
        });
    }];
}
//// 查询主线程 要求等待  所有联系人
+ (void)searchUserOnMainThreadPerformWait:(void (^)(NSArray *resultArray))resultBack{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([ContractModel class])];
    [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext performBlockAndWait:^{
        NSError *error;
        NSArray *arrays = [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext executeFetchRequest:request error:&error];
        if (resultBack) resultBack(arrays);
    }];
}
///根据id获取联系人 主线程
+ (ContractModel *)seachContractModelWith:(NSString *)contractId{
   __block ContractModel *contractModel;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([ContractModel class])];
    NSString *filter = [NSString stringWithFormat:@"userId = %@",contractId];
    NSPredicate *pre = [NSPredicate predicateWithFormat:filter];
    request.predicate = pre;
    [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext performBlockAndWait:^{
        NSError *error;
        NSArray *arrays = [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext executeFetchRequest:request error:&error];
        if (arrays.count) {
            contractModel = [arrays objectAtIndex:0];
        }
    }];
    return  contractModel;
}
/////检索联系人  异步线程
+ (void)searchContractModelWithContractModelWith:(NSString *)contractId complite:(void (^)(ContractModel *contractModel))complite{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([ContractModel class])];
    NSString *filter = [NSString stringWithFormat:@"userId = %@",contractId];
    NSPredicate *pre = [NSPredicate predicateWithFormat:filter];
    request.predicate = pre;
    ////异步线程
    [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext performBlock:^{
        NSError *error;
        NSArray *arrays = [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext executeFetchRequest:request error:&error];
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (complite) complite([arrays firstObject]);
        });
    }];

}
////检索object数量  异步
+ (void)countForUserToDBAsyThread:(void (^)(NSInteger count))success andError:(void (^)())errorBack{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([ContractModel class])];
    [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext performBlock:^{
        NSError *error;
        NSInteger count = [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext countForFetchRequest:request error:&error];
        if (error) {
            if (errorBack) errorBack();
        }else{
            if (success) success(count);
        }
    }];
}
/////同步删除
- (void)removeFromDBOnMainThread:(void (^)())success andError:(void (^)())faild{
    [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext performBlockAndWait:^{
        NSError *error;
        [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext deleteObject:self];
        [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext save:&error];
        if (error) {
            NSLog(@"delete faild");
            if (faild) faild();
        }else{
            NSLog(@"delete success");
            if (success) success();
        }
    }];
}
////异步删除
- (void)removeFromDBOnOtherThread:(void(^)())success andError:(void (^)())faild{
    [[HQCoreDataManager shareCoreDataManager] .asyManagerSaveObjextContext performBlock:^{
        [[HQCoreDataManager shareCoreDataManager] .asyManagerSaveObjextContext deleteObject:self];
        NSError *error;
        [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext save:&error];
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (error) {
                NSLog(@"delete faild");
                if (faild) faild();
            }else{
                NSLog(@"delete success");
                if (success) success();
            }
        });
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
    @synchronized (self) {
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
}


+ (void)applicationDidFinishLaunchedComplite:(void(^)(void))complite{
    [ContractModel searchUserModelOnAsyThread:^(NSArray *resultList, NSArray *locaArr) {
        
    }];
    NSMutableArray *modelArray = [NSMutableArray new];
    ContractModel *model1 = [ContractModel customerInit];
    model1.userName = @"阿弥陀福";
    model1.userId = 11;
    model1.userType = @"user";
    model1.userHeadImaeUrl = @"http://d.lanrentuku.com/down/png/1610/16young-avatar-collection/boy.png";
    model1.isGroupChat = NO;
    [modelArray addObject:model1];
    
    ContractModel *model2 = [ContractModel customerInit];
    model2.userId = 12;
    model2.userType = @"user";
    model2.userName = @"白超";
    model2.userHeadImaeUrl = @"http://d.lanrentuku.com/down/png/1610/16young-avatar-collection/boy-3.png";
    model2.isGroupChat = NO;
    [modelArray addObject:model2];
    
    ContractModel *model3 = [ContractModel customerInit];
    model3.userName = @"常";
    model3.userId = 13;
    model3.userType = @"user";
    model3.userHeadImaeUrl = @"http://d.lanrentuku.com/down/png/1610/16young-avatar-collection/boy-1.png";
    model3.isGroupChat = NO;
    [modelArray addObject:model3];
    
    ContractModel *model4 = [ContractModel customerInit];
    model4.userName = @"低调";
    model4.userType = @"user";
    model4.userId = 14;
    model4.userHeadImaeUrl = @"http://d.lanrentuku.com/down/png/1610/16young-avatar-collection/man-1.png";
    model4.isGroupChat = NO;
    [modelArray addObject:model4];
    
    ContractModel *model5 = [ContractModel customerInit];
    model5.userName = @"二转";
    model5.userId = 15;
    model5.userType = @"user";
    model5.userHeadImaeUrl = @"http://d.lanrentuku.com/down/png/1610/16young-avatar-collection/girl-7.png";
    model5.isGroupChat = NO;
    [modelArray addObject:model5];
    
    ContractModel *model6 = [ContractModel customerInit];
    model6.userName = @"古钱";
    model6.userType = @"user";
    model6.userId = 16;
    model6.userHeadImaeUrl = @"http://d.lanrentuku.com/down/png/1610/16young-avatar-collection/girl-1.png";
    model6.isGroupChat = NO;
    [modelArray addObject:model6];
    
    ContractModel *model7 = [ContractModel customerInit];
    model7.userName = @"黄麒展";
    model7.userType = @"user";
    model7.userId = 17;
    model7.userHeadImaeUrl = @"http://d.lanrentuku.com/down/png/1610/16young-avatar-collection/boy-2.png";
    model7.isGroupChat = NO;
    [modelArray addObject:model7];
    
    ContractModel *model8 = [ContractModel customerInit];
    model8.userName = @"姐姐";
    model8.userType = @"user";
    model8.userId = 18;
    model8.userHeadImaeUrl = @"http://d.lanrentuku.com/down/png/1610/16young-avatar-collection/girl-7.png";
    model8.isGroupChat = NO;
    [modelArray addObject:model8];
    
    ContractModel *model9 = [ContractModel customerInit];
    model9.userName = @"卡号";
    model9.userId = 19;
    model9.userType = @"user";
    model9.userHeadImaeUrl = @"http://d.lanrentuku.com/down/png/1610/16young-avatar-collection/man.png";
    model9.isGroupChat = NO;
    [modelArray addObject:model9];
    
    ContractModel *model10 = [ContractModel customerInit];
    model10.userName = @"刘威";
    model10.userType = @"user";
    model10.userId = 20;
    model10.userHeadImaeUrl = @"http://d.lanrentuku.com/down/png/1610/16young-avatar-collection/man.png";
    model10.isGroupChat = NO;
    [modelArray addObject:model10];
    
    ContractModel *model11 = [ContractModel customerInit];
    model11.userName = @"娜娜";
    model11.userId = 21;
    model11.userType = @"user";
    model11.userHeadImaeUrl = @"http://d.lanrentuku.com/down/png/1610/16young-avatar-collection/girl-3.png";
    model11.isGroupChat = NO;
    [modelArray addObject:model11];
    
    ContractModel *model12 = [ContractModel customerInit];
    model12.userName = @"强哥";
    model12.userId = 22;
    model12.userType = @"user";
    model12.userHeadImaeUrl = @"http://d.lanrentuku.com/down/png/1610/16young-avatar-collection/boy-5.png";
    model12.isGroupChat = NO;
    [modelArray addObject:model12];
    
    ContractModel *model13 = [ContractModel customerInit];
    model13.userName = @"搜索";
    model13.userId = 23;
    model13.userType = @"user";
    model13.userHeadImaeUrl = @"http://d.lanrentuku.com/down/png/1610/16young-avatar-collection/boy-4.png";
    model13.isGroupChat = NO;
    [modelArray addObject:model13];
    
    ContractModel *model14 = [ContractModel customerInit];
    model14.userName = @"兔子";
    model14.userId = 24;
    model14.userType = @"user";
    model14.userHeadImaeUrl = @"http://d.lanrentuku.com/down/png/1610/16young-avatar-collection/girl-4.png";
    model14.isGroupChat = NO;
    [modelArray addObject:model14];
    
    ContractModel *model15 = [ContractModel customerInit];
    model15.userName = @"组织";
    model15.userId = 25;
    model15.userType = @"user";
    model15.userHeadImaeUrl = @"http://d.lanrentuku.com/down/png/1610/16young-avatar-collection/girl-5.png";
    model15.isGroupChat = NO;
    [modelArray addObject:model15];
    
    ContractModel *newFriend = [ContractModel customerInit];
    newFriend.userName = @"新朋友";
    newFriend.userType = @"newUser";
    newFriend.createTime = 1;
    newFriend.userHeadImaeUrl = @"plugins_FriendNotify";
    
    ContractModel *group = [ContractModel customerInit];
    group.userName = @"群聊";
    group.userType = @"groupUser";
    group.createTime = 2;
    group.userHeadImaeUrl = @"add_friend_icon_addgroup";
    
    ContractModel *tag = [ContractModel customerInit];
    tag.userName = @"标签";
    tag.userType = @"tagUser";
    tag.createTime = 3;
    tag.userHeadImaeUrl = @"Contact_icon_ContactTag";
    
    ContractModel *publicNUm = [ContractModel customerInit];
    publicNUm.userName = @"公众号";
    publicNUm.userType = @"publicUser";
    publicNUm.createTime = 4;
    publicNUm.userHeadImaeUrl = @"add_friend_icon_offical";
    
    [ContractModel searchUserModelOnAsyThread:^(NSArray *resultList,NSArray *locaArr) {
        for (ContractModel *con in resultList) {
            ChatListModel *list = [ChatListModel customerInit];
            list.messageUser = con;
            list.chatListType = 1;
            list.chatListId = con.userId;
            list.isShow = NO;
            list.userName = con.userName;
        }
        [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext performBlock:^{
            NSError *error;
            [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext save:&error];
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (complite) complite();
            });
        }];
    }];
}


@end
