//
//  NSDate+Extension.h
//  XZ_WeChat
//
//  Created by 郭现壮 on 16/9/27.
//  Copyright © 2016年 gxz. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MH_D_MINUTE        60
#define MH_D_HOUR        3600
#define MH_D_DAY        86400
#define MH_D_WEEK        604800
#define MH_D_YEAR        31556926



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
    
    
    
    /**
     *  是否为今天
     */
- (BOOL)mh_isToday;
    /**
     *  是否为昨天
     */
- (BOOL)mh_isYesterday;
    /**
     *  是否为今年
     */
- (BOOL)mh_isThisYear;
    /**
     *  是否本周
     */
- (BOOL) mh_isThisWeek;
    
    /**
     *  星期几
     */
- (NSString *)mh_weekDay;
    
    /**
     *  是否为在相同的周
     */
- (BOOL) mh_isSameWeekWithAnotherDate: (NSDate *)anotherDate;
    
    
    /**
     *  通过一个时间 固定的时间字符串 "2016/8/10 14:43:45" 返回时间
     *  @param timestamp 固定的时间字符串 "2016/8/10 14:43:45"
     */
+ (instancetype)mh_dateWithTimestamp:(NSString *)timestamp;
    
    /**
     *  返回固定的 当前时间 2016-8-10 14:43:45
     */
+ (NSString *)mh_currentTimestamp;
    
    /**
     *  返回一个只有年月日的时间
     */
- (NSDate *)mh_dateWithYMD;
    
    /**
     * 格式化日期描述
     */
- (NSString *)mh_formattedDateDescription;
    
    /** 与当前时间的差距 */
- (NSDateComponents *)mh_deltaWithNow;
    
    
    
    //////////// MVC&MVVM的商品的发布时间的描述 ////////////
- (NSString *)mh_string_yyyy_MM_dd;
- (NSString *)mh_string_yyyy_MM_dd:(NSDate *)toDate;


@end



@interface NSDateFormatter (Extension)
+ (instancetype)mh_dateFormatter;
    
+ (instancetype)mh_dateFormatterWithFormat:(NSString *)dateFormat;
    
+ (instancetype)mh_defaultDateFormatter;/*yyyy/MM/dd HH:mm:ss*/
    @end
