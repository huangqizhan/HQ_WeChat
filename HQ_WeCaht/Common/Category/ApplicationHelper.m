//
//  ApplicationHelper.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/5/25.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "ApplicationHelper.h"

@implementation ApplicationHelper




+ (NSString *)getApplicationScheme{
    NSDictionary *bundleInfo    = [[NSBundle mainBundle] infoDictionary];
    NSString *bundleIdentifier  = [[NSBundle mainBundle] bundleIdentifier];
    NSArray *URLTypes           = [bundleInfo valueForKey:@"CFBundleURLTypes"];
    
    NSString *scheme;
    for (NSDictionary *dic in URLTypes)
    {
        NSString *URLName = [dic valueForKey:@"CFBundleURLName"];
        if ([URLName isEqualToString:bundleIdentifier])
        {
            scheme = [[dic valueForKey:@"CFBundleURLSchemes"] objectAtIndex:0];
            break;
        }
    }
    
    return scheme;
}

+ (NSString *)appName {    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleName"];
    return app_Name;
}
+ (void)callPhoneNumber:(NSString *)phone{
    NSString * str=[[NSString alloc] initWithFormat:@"telprompt://%@",phone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}
+ (void)copyToPasteboard:(NSString *)string {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = string;
    
}

+ (void)setNetworkActivityIndicatorVisible:(BOOL)visible {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = visible;
}


/*
 // 获取手机网络类型
 CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
 NSString *currentStatus = info.currentRadioAccessTechnology;
 
 if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyGPRS"]) {
 //                netconnType = @"GPRS";
 netconnType = kLLNetconnectionTypeOther;
 }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyEdge"]) {
 //                netconnType = @"2.75G EDGE";
 netconnType = kLLNetconnectionType2G;
 }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyWCDMA"]){
 //                netconnType = @"3G";
 netconnType = kLLNetconnectionType3G;
 }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSDPA"]){
 //                netconnType = @"3.5G HSDPA";
 netconnType = kLLNetconnectionType3G;
 }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSUPA"]){
 //                netconnType = @"3.5G HSUPA";
 netconnType = kLLNetconnectionType3G;
 }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMA1x"]){
 //                netconnType = @"2G";
 netconnType = kLLNetconnectionType2G;
 }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORev0"]){
 //                netconnType = @"3G";
 netconnType = kLLNetconnectionType3G;
 }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevA"]){
 //                netconnType = @"3G";
 netconnType = kLLNetconnectionType3G;
 }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevB"]){
 //                netconnType = @"3G";
 netconnType = kLLNetconnectionType3G;
 }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyeHRPD"]){
 //                netconnType = @"HRPD";
 netconnType = kLLNetconnectionTypeOther;
 }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyLTE"]){
 //                netconnType = @"4G";
 netconnType = kLLNetconnectionType4G;
 }

 
 */
@end
