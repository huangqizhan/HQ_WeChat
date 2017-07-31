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



@end
