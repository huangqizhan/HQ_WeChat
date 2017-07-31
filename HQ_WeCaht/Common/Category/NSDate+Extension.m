//
//  NSDate+Extension.m
//  XZ_WeChat
//
//  Created by   on 16/9/27.
//  Copyright © 2016年  . All rights reserved.
//

#import "NSDate+Extension.h"

static NSInteger SEC_PER_DAY = 24 * 60 * 60;


@implementation NSDate (Extension)

+ (NSDate *)dateWithTimeIntervalInMilliSecondSince1970:(double)timeIntervalInMilliSecond{
    NSDate *ret = nil;
    double timeInterval = timeIntervalInMilliSecond;
    // judge if the argument is in secconds(for former data structure).
    if(timeIntervalInMilliSecond > 140000000000) {
        timeInterval = timeIntervalInMilliSecond / 1000;
    }
    ret = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    return ret;
}

+ (NSTimeInterval)returnTheTimeralFrom1970{
    return  [[NSDate date] timeIntervalSince1970]*1000;
}
+ (NSTimeInterval)returnTheTimeralFrom1970NoScale{
    return  [[NSDate date] timeIntervalSince1970];
}
+ (NSString *)getCurrnetSendImageName{
    return  [NSString stringWithFormat:@"%ld",(long )[[NSDate date] timeIntervalSince1970]];
}

- (NSString *)timeIntervalBeforeNowLongDescription {
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
    }
    
    //格式化日期字符串,只保留年、月、日信息
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *selfDateFormatString = [dateFormatter stringFromDate:self];
    NSString *nowDateFormatString = [dateFormatter stringFromDate:[NSDate date]];
    
    //当天
    if ([selfDateFormatString isEqualToString:nowDateFormatString]) {
        [dateFormatter setDateFormat:@"HH:mm"];
        return [dateFormatter stringFromDate:self];
    }else {
        //格式化日期,将日期格式化为日期当天的0时0分0秒
        NSDate *selfDateFormatDate = [dateFormatter dateFromString:selfDateFormatString];
        NSDate *nowDateFormatDate = [dateFormatter dateFromString:nowDateFormatString];
        
        NSTimeInterval timeInterval = [nowDateFormatDate timeIntervalSinceDate:selfDateFormatDate];
        
        //昨天
        if (timeInterval == SEC_PER_DAY) {
            [dateFormatter setDateFormat:@"HH:mm"];
            return [NSString stringWithFormat:@"昨天 %@",[dateFormatter stringFromDate:self]];
        }
        //一周内
        else if (timeInterval < 7 * SEC_PER_DAY) {
            [dateFormatter setDateFormat:@"EEEE HH:mm"];
            return [dateFormatter stringFromDate:self];
        }
        //一周以前的时间
        else {
            [dateFormatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
            return [dateFormatter stringFromDate:self];
        }
        
    }
    
}


- (NSString *)timeIntervalBeforeNowShortDescription {
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
    }
    
    //格式化日期字符串,只保留年、月、日信息
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *selfDateFormatString = [dateFormatter stringFromDate:self];
    NSString *nowDateFormatString = [dateFormatter stringFromDate:[NSDate date]];
    
    //当天
    if ([selfDateFormatString isEqualToString:nowDateFormatString]) {
        [dateFormatter setDateFormat:@"HH:mm"];
        return [dateFormatter stringFromDate:self];
    } else {
        //格式化日期,将日期格式化为日期当天的0时0分0秒
        NSDate *selfDateFormatDate = [dateFormatter dateFromString:selfDateFormatString];
        NSDate *nowDateFormatDate = [dateFormatter dateFromString:nowDateFormatString];
        
        NSTimeInterval timeInterval = [nowDateFormatDate timeIntervalSinceDate:selfDateFormatDate];
        
        //昨天
        if (timeInterval == SEC_PER_DAY) {
            return @"昨天";
        }
        //一周内
        else if (timeInterval < 7 * SEC_PER_DAY) {
            [dateFormatter setDateFormat:@"EEEE"];
            return [dateFormatter stringFromDate:self];
        }
        //一周以前的时间
        else {
            [dateFormatter setDateFormat:@"M/d/yy"];
            return [dateFormatter stringFromDate:self];
        }
        
    }
}
- (double)timeIntervalSince1970InMilliSecond {
    double ret;
    ret = [self timeIntervalSince1970] * 1000;
    
    return ret;
}


+ (NSString *)currentTimevalDescriptionWith:(double )timeral{
    NSDate *date = [NSDate dateWithTimeIntervalInMilliSecondSince1970:timeral];
    return [date timeIntervalBeforeNowLongDescription];
}
@end
