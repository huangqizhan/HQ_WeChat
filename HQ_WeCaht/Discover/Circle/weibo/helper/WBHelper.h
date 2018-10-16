//
//  WBHelper.h
//  YYStudyDemo
//
//  Created by hqz on 2018/9/25.
//  Copyright © 2018年 hqz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WBHeader.h"

@interface WBHelper : NSObject

///image  from bundle
+ (UIImage *)imageWithNamed:(NSString *)name;
///image from path
+ (UIImage *)imageWithPath:(NSString *)path;
///头像管理
+ (WebImageManager *)avatarImageManager;
///时间处理
+ (NSString *)stringWithTimelineDate:(NSDate *)date ;
///图片地址处理
+ (NSURL *)defaultURLForImageURL:(id)imageURL;
///数量显示处理
+ (NSString *)shortedNumberDesc:(NSUInteger)number;
///At 正则
+ (NSRegularExpression *)regexAt;
///主题正则
+ (NSRegularExpression *)regexTopic;
///表情正则
+ (NSRegularExpression *)regexEmoticon;
///表情
+ (NSDictionary *)emoticonDic;
///多组表情
+ (NSArray<WBEmoticonGroup *> *)emoticonGroups;
@end


