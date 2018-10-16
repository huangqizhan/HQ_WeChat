//
//  HQHUDHelper.m
//  HQ_WeChat
//
//  Created by hqz on 2018/3/17.
//  Copyright © 2018年 黄麒展. All rights reserved.
//

#import "HQHUDHelper.h"
#import "MBProgressHUD.h"

@interface  HQHUDHelper  ()
@property (nonatomic,strong) MBProgressHUD *MBHUD;
@end

@implementation HQHUDHelper

+ (instancetype)helperInstance{
    static HQHUDHelper *helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[HQHUDHelper alloc] init];
    });
    return helper;
}

+ (void)showHUDForView:(UIView *)view{
    [[HQHUDHelper helperInstance].MBHUD hideAnimated:NO];
    [HQHUDHelper helperInstance].MBHUD = [MBProgressHUD showHUDAddedTo:view animated:YES];
    [HQHUDHelper helperInstance].MBHUD.contentColor = [UIColor whiteColor];
    [HQHUDHelper helperInstance].MBHUD.bezelView.color = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.9];
}
+ (void)hiddenHUD{
    [[HQHUDHelper helperInstance].MBHUD hideAnimated:YES];
}


@end
