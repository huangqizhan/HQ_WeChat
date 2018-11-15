//
//  HQPublicManager.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/4/24.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HQPublicManager.h"

@implementation HQPublicManager

+ (instancetype)shareManagerInstance{
    static HQPublicManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HQPublicManager alloc] init];
    });
    return manager;
}

- (HQUserInfoModel *)userinfoModel{
    if (_userinfoModel == nil) {
        _userinfoModel = [[HQUserInfoModel alloc] init];
        _userinfoModel.userId = 10001;
        _userinfoModel.userName = @"黄麒展  QQ 757618403";
    }
    return _userinfoModel;
}

@end
