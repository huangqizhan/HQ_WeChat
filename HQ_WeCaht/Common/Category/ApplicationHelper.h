//
//  ApplicationHelper.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/5/25.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApplicationHelper : NSObject

+ (NSString *)getApplicationScheme;

+ (NSString *)appName ;

+ (void)callPhoneNumber:(NSString *)phone;

+ (void)copyToPasteboard:(NSString *)string ;

+ (void)setNetworkActivityIndicatorVisible:(BOOL)visible;

@end
