//
//  PublicCaculateManager.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/4/17.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PublicCaculateManager : NSObject

////清除聊天界面的内存数据
+ (void)clearChatViewControllerManagers;
/////联系人分组
+ (NSDictionary *)groupContractWith:(NSArray *)dataSourse;

+ (NSDictionary *)dictionaryOrderByCharacterWithOriginalArray:(NSArray *)array;



@end
