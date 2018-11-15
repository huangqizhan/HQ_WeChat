//
//  HQPublicManager.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/4/24.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HQUserInfoModel.h"

@interface HQPublicManager : NSObject

+ (instancetype)shareManagerInstance;

@property (nonatomic,strong) HQUserInfoModel *userinfoModel;


@end
