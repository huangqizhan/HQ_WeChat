//
//  HQHUDTools.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/17.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"


@interface HQHUDTools : NSObject

@property (nonatomic,strong,readonly) MBProgressHUD *processHud;

+ (instancetype)shareInstance;


@end
