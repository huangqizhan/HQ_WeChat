//
//  HQChatRegexHelper.m
//  HQ_WeChat
//
//  Created by 黄麒展 on 2018/10/21.
//  Copyright © 2018年 黄麒展. All rights reserved.
//

#import "HQChatRegexHelper.h"

@implementation HQChatRegexHelper

///表情正则
+ (NSRegularExpression *)regexEmoticon {
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"\\[[^ \\[\\]]+?\\]" options:kNilOptions error:NULL];
    });
    return regex;
}
///HTTP链接
+ (NSRegularExpression *)regexHttpLink{
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"([hH]ttp[s]{0,1})://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\-~!@#$%^&*+?:_/=<>.',;]*)?" options:kNilOptions error:nil];
    });
    return regex;
}

+ (NSRegularExpression *)regexLink{
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"^[a-zA-Z0-9]+(\\.[a-zA-Z0-9]+)+([-A-Z0-9a-z_\\$\\.\\+!\\*\(\\)/,:;@&=\?~#%]*)*" options:kNilOptions error:nil];
    });
    return regex;
}

///匹配单个字符 (中英文数字下划线连字符)
+ (NSRegularExpression *)regexCharLink{
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"[\\x{4e00}-\\x{9fa5}A-Za-z0-9_\\-]" options:kNilOptions error:nil];
    });
    return regex;
}
///At 正则
+ (NSRegularExpression *)regexAt {
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 微博的 At 只允许 英文数字下划线连字符，和 unicode 4E00~9FA5 范围内的中文字符，这里保持和微博一致。。
        // 目前中文字符范围比这个大
        regex = [NSRegularExpression regularExpressionWithPattern:@"@[-_a-zA-Z0-9\u4E00-\u9FA5]+" options:kNilOptions error:NULL];
    });
    return regex;
}

///主题正则
+ (NSRegularExpression *)regexTopic {
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"#[^@#]+?#" options:kNilOptions error:NULL];
    });
    return regex;
}
///电话
+ (NSRegularExpression *)regexPhoneNumber{
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"(13[0-9]|17[0-9]|15[0-35-9]|18[01235-9])\\d{8}" options:kNilOptions error:NULL];
    });
    return regex;
}

@end
