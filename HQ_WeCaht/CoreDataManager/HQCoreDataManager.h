//
//  HQCoreDataManager.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/2/20.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ChatListModel+CoreDataClass.h"





@interface HQCoreDataManager : NSObject

+ (instancetype)shareCoreDataManager;




/**
 保存 object context 
 */
@property (nonatomic,strong) NSManagedObjectContext *asyManagerSaveObjextContext;


/**
 同步保存
 */
@property (nonatomic,strong) NSManagedObjectContext *syManagerSaveObjectContext;

/**
 删除 object context
 */
@property (nonatomic,strong) NSManagedObjectContext *asyMangerDeleteObjectContext;

/**
 编辑 object context
 */
@property (nonatomic,strong) NSManagedObjectContext *asyMangerEdiateObjectContext;

/**
 检索 object context
 */
@property (nonatomic,strong) NSManagedObjectContext *asyMangerSearchObjectContext;


/**
  持久化存储协调者 ，包含数据存储的名字和位置，
 */
@property (nonatomic,strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;


/**
 实体
 */
@property (nonatomic,strong) NSManagedObjectModel *managerObjectModel;





#pragma mark ------- Action ------


/**
 保存

 @param dataList model list
 @param callBack result
 */
- (void)asySaveDataList:(NSMutableArray *)dataList andCallBlock:(void (^)(BOOL result))callBack;

/**
 保存
 
 @param dataList model list
 @param callBack result
 */
- (void)sySaveDataList:(NSMutableArray *)dataList andCallBlock:(void (^)(BOOL result))callBack;





- (void)saveTextAction:(ChatListModel *)listMdoel;

@end
