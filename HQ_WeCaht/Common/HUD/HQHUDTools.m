//
//  HQHUDTools.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/17.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQHUDTools.h"

@implementation HQHUDTools

+ (instancetype)shareInstance{
    static HQHUDTools *hudTools = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hudTools = [[HQHUDTools alloc] init];
    });
    return hudTools;
}
- (instancetype)init{
    self = [super init];
    if (self) {
//        _processHud = [[MBProgressHUD alloc] ini ]
    }
    return self;
        
}

@end
