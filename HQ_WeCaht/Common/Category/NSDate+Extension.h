//
//  NSDate+Extension.h
//  XZ_WeChat
//
//  Created by 郭现壮 on 16/9/27.
//  Copyright © 2016年 gxz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Extension)

+ (NSDate *)dateWithTimeIntervalInMilliSecondSince1970:(double)timeIntervalInMilliSecond;

+ (NSTimeInterval)returnTheTimeralFrom1970;

+ (NSTimeInterval)returnTheTimeralFrom1970NoScale;

+ (NSString *)getCurrnetSendImageName;

/*
 * 过去时间距离当前时间的时间间隔的描述,本方法返回长字符串
 * 时间格式为,支持多语言:
 * 1、当天的消息直接显示: HH:MM
 * 2、昨天的消息显示为:  昨天 HH:MM
 * 3、本周内的消息显示为: 星期几 HH:MM ~ Friday HH:MM
 * 4、超过一周的消息显示为: 2016年7月1日 19:20 ~ Jul 12 2016 11:47
 * */
- (NSString *)timeIntervalBeforeNowLongDescription;


/*
 * 过去时间距离当前时间的时间间隔的描述, 本方法返回短字符串
 * 时间格式为:
 * 1、当天的消息直接显示:  HH:MM
 * 2、昨天的消息显示为:    昨天
 * 3、本周内的消息显示为:  星期几 ~ Friday
 * 4、超过一周的消息显示为: 6/16/16
 * */
- (NSString *)timeIntervalBeforeNowShortDescription;


/*
 * SDK返回的时间戳单位是毫秒,Client使用的时间戳单位是秒
 * */
- (double)timeIntervalSince1970InMilliSecond;


+ (NSString *)currentTimevalDescriptionWith:(double )timeral;

@end
