//
//  NSBundle+Add.h
//  YYStudyDemo
//
//  Created by hqz  QQ 757618403 on 2018/9/25.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSBundle (Add)

///scales
+ (NSArray *)preferredScales;
///subbundle  路径
+ (NSString *)pathForScaledResource:(NSString *)name ofType:(NSString *)ext inDirectory:(NSString *)bundlePath;
/// 路径
- (NSString *)pathForScaledResource:(NSString *)name ofType:(NSString *)ext;
///subpath  路径
- (NSString *)pathForScaledResource:(NSString *)name ofType:(NSString *)ext inDirectory:(NSString *)subpath;

@end


