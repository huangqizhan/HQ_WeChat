//
//  HQEdiateImageProtocal.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/8/1.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HQEdiateImageProtocal <NSObject>


@optional;

+ (UIImage*)defaultIconImage;   //图片

+ (NSString*)defaultTitle;      //工具名称

+ (NSArray*)subtools;           //包含的子工具

+ (NSUInteger)orderNum;         //显示顺序

@end
