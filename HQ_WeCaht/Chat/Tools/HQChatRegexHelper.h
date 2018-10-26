//
//  HQChatRegexHelper.h
//  HQ_WeChat
//
//  Created by 黄麒展 on 2018/10/21.
//  Copyright © 2018年 黄麒展. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface HQChatRegexHelper : NSObject

///表情正则
+ (NSRegularExpression *)regexEmoticon;

///HTTP链接
+ (NSRegularExpression *)regexHttpLink;

/// 链接 (例如 www.baidu.com/s?wd=test ):
+ (NSRegularExpression *)regexLink;

///匹配单个字符 (中英文数字下划线连字符)
+ (NSRegularExpression *)regexCharLink;

///电话
+ (NSRegularExpression *)regexPhoneNumber;

@end

