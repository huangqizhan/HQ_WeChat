//
//  HQCoreDataManager.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/2/20.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HQCoreDataManager.h"

@implementation HQCoreDataManager

+ (instancetype)shareCoreDataManager{
    
    static HQCoreDataManager *manger;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manger = [[HQCoreDataManager alloc] init];
    });
    return manger;
}

/*
 Confinement (confinementConcurrencyType)：每个线程一个独立的Context，主要是为了兼容之前的设计。
 Private queue (privateQueueConcurrencyType)：私有队列，不会阻塞主线程。
 Main queue (mainQueueConcurrencyType)：主线程，会阻塞。
 其中confinementConcurrencyType已被弃用。
 */


#pragma mark -----  异步保存  ----context
- (NSManagedObjectContext *)asyManagerSaveObjextContext{
    if (_asyManagerSaveObjextContext == nil) {
        _asyManagerSaveObjextContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_asyManagerSaveObjextContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    }
    return _asyManagerSaveObjextContext;
}
#pragma mark ------  同步保存  ---- context
- (NSManagedObjectContext *)syManagerSaveObjectContext{
    if (_syManagerSaveObjectContext == nil) {
        _syManagerSaveObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_syManagerSaveObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    }
    return _syManagerSaveObjectContext;
}
#pragma mark -----  删除----- context
- (NSManagedObjectContext *)mangerDeleteObjectContext{
    if (_asyMangerDeleteObjectContext == nil) {
        _asyMangerDeleteObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_asyMangerDeleteObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    }
    return _asyMangerDeleteObjectContext;
}
#pragma mark ------ 修改  ------ context 
- (NSManagedObjectContext *)mangerEdiateObjectContext{
    if (_asyMangerEdiateObjectContext == nil) {
        _asyMangerEdiateObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_asyMangerEdiateObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    }
    return _asyMangerEdiateObjectContext;
}
#pragma mark ------- 搜索 -----context -
- (NSManagedObjectContext *)mangerSearchObjectContext{
    if (_asyMangerSearchObjectContext == nil) {
        _asyMangerSearchObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_asyMangerSearchObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    }
    return _asyMangerSearchObjectContext;
}
#pragma mark ----- 持久化存储协调者 ，包含数据存储的名字和位置， ------

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator{
    if (_persistentStoreCoordinator == nil) {
        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"mySqlite.sqlite"];
        NSDictionary *optionsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES],NSInferMappingModelAutomaticallyOption, nil];
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managerObjectModel];
         NSError *error = nil;
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:optionsDictionary error:&error]){
            NSLog(@"数据库创建失败 error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    return _persistentStoreCoordinator;
}
- (NSManagedObjectModel *)managerObjectModel{
    
    if (_managerObjectModel == nil) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"HQChatModel" withExtension:@"momd"];
        _managerObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        
    }
    return _managerObjectModel;
}
#pragma mark ------- 文件目录  --------
- (NSURL *)applicationDocumentsDirectory{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
#pragma mark ----- Action ------
- (void)asySaveDataList:(NSMutableArray *)dataList andCallBlock:(void (^)(BOOL result))callBack{
//    ChatListModel *model = [[ChatListModel alloc] initWithContext:self.asyManagerSaveObjextContext];
//    [self.asyManagerSaveObjextContext ]
//    NSEntityDescription
}

- (void)sySaveDataList:(NSMutableArray *)dataList andCallBlock:(void (^)(BOOL result))callBack{
    
}


- (void)saveTextAction:(ChatListModel *)listMdoel{
    
}
@end


/*
 NSManagedObjectContext：被管理的对象上下文，对对象的操作（增删改），由我来进行
 
 NSEntityDescription：表，即数据库中一张表
 
 NSManagedObject：数据，表中一行数据，
 
 NSAttributeDescription：表中的一个字段信息，即表中的每个列的字段
 
 NSPersistentStoreCoordinator：持久化的助理，将对象保存到数据库中由我来完成，我只是个助理，所以操作都由我来完成，我上面还有老大
 
 NSPersistentStore：持久化的老板，即数据库文件
 
 NSManagedObjectModel：对象模型，包含了表和表之间的关系，即编译后生成的momd文件
 
 NSFetchedRequest：一个查询请求
 
 NSPredicate：谓词，即where条件语句
 
 */
