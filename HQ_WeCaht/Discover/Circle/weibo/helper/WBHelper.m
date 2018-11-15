//
//  WBHelper.m
//  YYStudyDemo
//
//  Created by hqz  QQ 757618403 on 2018/9/25.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//

#import "WBHelper.h"


@implementation WBHelper

+ (NSBundle *)bundle{
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"ResourceWeibo" ofType:@"bundle"];
        bundle = [NSBundle bundleWithPath:path];
    });
    return bundle;
}
+ (NSBundle *)emtionBoundle{
    static NSBundle *boundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"EmoticonWeibo" ofType:@"bundle"];
        boundle = [NSBundle bundleWithPath:path];
    });
    return boundle;
}

+ (MemoryCache *)imageCache{
    static MemoryCache *imageCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imageCache = [MemoryCache new];
        imageCache.shouldRemoveAllObjectsOnMemoryWarning = NO;
        imageCache.shouldRemoveAllObjectsWhenEnteringBackground = NO;
        imageCache.name = @"weiboImageCache";
    });
    return imageCache;
}

+ (UIImage *)imageWithNamed:(NSString *)name{
    if (!name) return nil;
    UIImage *image = [[self imageCache] objectForKey:name];
    if (image) return image;
    NSString *ext = name.pathExtension;
    if (ext.length == 0) ext = @"png";
    
    NSString *path = [[self bundle] pathForScaledResource:name ofType:@"png"];
    if (!path) return nil;
    ///此处不使用 imageNamed  系统不会有缓存
    image = [UIImage imageWithContentsOfFile:path];
    ///把图片转成位图
    image = [image imageByDecoded];
    if(!image) return nil;
    [[self imageCache] setObject:image forKey:name];
    return image;
}

+ (UIImage *)imageWithPath:(NSString *)path {
    if (!path) return nil;
    UIImage *image = [[self imageCache] objectForKey:path];
    if (image) return image;
    if (path.pathScale == 1) {
        // 查找 @2x @3x 的图片
        NSArray *scales = [NSBundle preferredScales];
        for (NSNumber *scale in scales) {
            image = [UIImage imageWithContentsOfFile:[path stringByAppendingPathScale:scale.floatValue]];
            if (image) break;
        }
    } else {
        image = [UIImage imageWithContentsOfFile:path];
    }
    if (image) {
        image = [image imageByDecoded];
        [[self imageCache] setObject:image forKey:path];
    }
    return image;
}

+ (WebImageManager *)avatarImageManager{
    static WebImageManager *imageManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        WebImageCache *cache = [[WebImageCache alloc] initWithPath:[UIApplication sharedApplication].cachesPath];
        imageManager = [[WebImageManager alloc] initWithCache:cache queue:[WebImageManager sharedManager].queue];
        ///在把图片存入缓存之前处理圆角
        imageManager.sharedTransformBlock = ^UIImage * _Nullable(UIImage *image, NSURL *url) {
            if (!image) return image;
            image = [image imageByRoundCornerRadius:100];
            return image;
        };
    });
    return imageManager;
}

+ (NSString *)stringWithTimelineDate:(NSDate *)date {
    if (!date) return @"";
    
    static NSDateFormatter *formatterYesterday;
    static NSDateFormatter *formatterSameYear;
    static NSDateFormatter *formatterFullDate;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatterYesterday = [[NSDateFormatter alloc] init];
        [formatterYesterday setDateFormat:@"昨天 HH:mm"];
        [formatterYesterday setLocale:[NSLocale currentLocale]];
        
        formatterSameYear = [[NSDateFormatter alloc] init];
        [formatterSameYear setDateFormat:@"M-d"];
        [formatterSameYear setLocale:[NSLocale currentLocale]];
        
        formatterFullDate = [[NSDateFormatter alloc] init];
        [formatterFullDate setDateFormat:@"yy-M-dd"];
        [formatterFullDate setLocale:[NSLocale currentLocale]];
    });
    
    NSDate *now = [NSDate new];
    NSTimeInterval delta = now.timeIntervalSince1970 - date.timeIntervalSince1970;
    if (delta < -60 * 10) { // 本地时间有问题
        return [formatterFullDate stringFromDate:date];
    } else if (delta < 60 * 10) { // 10分钟内
        return @"刚刚";
    } else if (delta < 60 * 60) { // 1小时内
        return [NSString stringWithFormat:@"%d分钟前", (int)(delta / 60.0)];
    } else if (date.isToday) {
        return [NSString stringWithFormat:@"%d小时前", (int)(delta / 60.0 / 60.0)];
    } else if (date.isYesterday) {
        return [formatterYesterday stringFromDate:date];
    } else if (date.year == now.year) {
        return [formatterSameYear stringFromDate:date];
    } else {
        return [formatterFullDate stringFromDate:date];
    }
}

+ (NSURL *)defaultURLForImageURL:(id)imageURL {
    /*
     微博 API 提供的图片 URL 有时并不能直接用，需要做一些字符串替换：
     http://u1.sinaimg.cn/upload/2014/11/04/common_icon_membership_level6.png //input
     http://u1.sinaimg.cn/upload/2014/11/04/common_icon_membership_level6_default.png //output
     
     http://img.t.sinajs.cn/t6/skin/public/feed_cover/star_003_y.png?version=2015080302 //input
     http://img.t.sinajs.cn/t6/skin/public/feed_cover/star_003_os7.png?version=2015080302 //output
     http://img.t.sinajs.cn/t6/skin/public/feed_cover/star_003_os7.png?version=2015080302
     */
    
    if (!imageURL) return nil;
    NSString *link = nil;
    if ([imageURL isKindOfClass:[NSURL class]]) {
        link = ((NSURL *)imageURL).absoluteString;
    } else if ([imageURL isKindOfClass:[NSString class]]) {
        link = imageURL;
    }
    if (link.length == 0) return nil;
    
    if ([link hasSuffix:@".png"]) {
        // add "_default"
        if (![link hasSuffix:@"_default.png"]) {
            NSString *sub = [link substringToIndex:link.length - 4];
            link = [sub stringByAppendingFormat:@"_default.png"];
        }
    } else {
        // replace "_y.png" with "_os7.png"
        NSRange range = [link rangeOfString:@"_y.png?version"];
        if (range.location != NSNotFound) {
            NSMutableString *mutable = link.mutableCopy;
            [mutable replaceCharactersInRange:NSMakeRange(range.location + 1, 1) withString:@"os7"];
            link = mutable;
        }
    }
    
    return [NSURL URLWithString:link];
}
+ (NSString *)shortedNumberDesc:(NSUInteger)number {
    // should be localized
    if (number <= 9999) return [NSString stringWithFormat:@"%d", (int)number];
    if (number <= 9999999) return [NSString stringWithFormat:@"%d万", (int)(number / 10000)];
    return [NSString stringWithFormat:@"%d千万", (int)(number / 10000000)];
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
///表情正则
+ (NSRegularExpression *)regexEmoticon {
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"\\[[^ \\[\\]]+?\\]" options:kNilOptions error:NULL];
    });
    return regex;
}

+ (NSDictionary *)emoticonDic {
    static NSMutableDictionary *dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *emoticonBundlePath = [[NSBundle mainBundle] pathForResource:@"EmoticonWeibo" ofType:@"bundle"];
        dic = [self _emoticonDicFromPath:emoticonBundlePath];
    });
    return dic;
}
+ (NSMutableDictionary *)_emoticonDicFromPath:(NSString *)path {
    NSMutableDictionary *dic = [NSMutableDictionary new];
    WBEmoticonGroup *group = nil;
    NSString *jsonPath = [path stringByAppendingPathComponent:@"info.json"];
    NSData *json = [NSData dataWithContentsOfFile:jsonPath];
    if (json.length) {
        group = [WBEmoticonGroup modelWithJSON:json];
    }
    if (!group) {
        NSString *plistPath = [path stringByAppendingPathComponent:@"info.plist"];
        NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        if (plist.count) {
            group = [WBEmoticonGroup modelWithJSON:plist];
        }
    }
    for (EmotionModel *emoticon in group.emoticons) {
        if (emoticon.png.length == 0) continue;
        NSString *pngPath = [path stringByAppendingPathComponent:emoticon.png];
        if (emoticon.chs) dic[emoticon.chs] = pngPath;
        if (emoticon.cht) dic[emoticon.cht] = pngPath;
    }
    
    NSArray *folders = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    for (NSString *folder in folders) {
        if (folder.length == 0) continue;
        NSDictionary *subDic = [self _emoticonDicFromPath:[path stringByAppendingPathComponent:folder]];
        if (subDic) {
            [dic addEntriesFromDictionary:subDic];
        }
    }
    return dic;
}

+ (NSArray<WBEmoticonGroup *> *)emoticonGroups {
    static NSMutableArray *groups;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *emoticonBundlePath = [[NSBundle mainBundle] pathForResource:@"EmoticonWeibo" ofType:@"bundle"];
        NSString *emoticonPlistPath = [emoticonBundlePath stringByAppendingPathComponent:@"emoticons.plist"];
        NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:emoticonPlistPath];
        NSArray *packages = plist[@"packages"];
        groups = (NSMutableArray *)[NSArray modelArrayWithClass:[WBEmoticonGroup class] json:packages];
        
        NSMutableDictionary *groupDic = [NSMutableDictionary new];
        for (int i = 0, max = (int)groups.count; i < max; i++) {
            WBEmoticonGroup *group = groups[i];
            if (group.groupID.length == 0) {
                [groups removeObjectAtIndex:i];
                i--;
                max--;
                continue;
            }
            NSString *path = [emoticonBundlePath stringByAppendingPathComponent:group.groupID];
            NSString *infoPlistPath = [path stringByAppendingPathComponent:@"info.plist"];
            NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:infoPlistPath];
            [group modelSetWithDictionary:info];
            if (group.emoticons.count == 0) {
                i--;
                max--;
                continue;
            }
            groupDic[group.groupID] = group;
        }
        
        NSArray<NSString *> *additionals = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[emoticonBundlePath stringByAppendingPathComponent:@"additional"] error:nil];
        for (NSString *path in additionals) {
            WBEmoticonGroup *group = groupDic[path];
            if (!group) continue;
            NSString *infoJSONPath = [[[emoticonBundlePath stringByAppendingPathComponent:@"additional"] stringByAppendingPathComponent:path] stringByAppendingPathComponent:@"info.json"];
            NSData *infoJSON = [NSData dataWithContentsOfFile:infoJSONPath];
            WBEmoticonGroup *addGroup = [WBEmoticonGroup modelWithJSON:infoJSON];
            if (addGroup.emoticons.count) {
                for (EmotionModel *emoticon in addGroup.emoticons) {
                    emoticon.group = group;
                }
                [((NSMutableArray *)group.emoticons) insertObjects:addGroup.emoticons atIndex:0];
            }
        }
    });
    return groups;
}
@end

/*
 weibo.app 里面的正则，有兴趣的可以参考下：
 
 HTTP链接 (例如 http://www.weibo.com ):
 ([hH]ttp[s]{0,1})://[a-zA-Z0-9\.\-]+\.([a-zA-Z]{2,4})(:\d+)?(/[a-zA-Z0-9\-~!@#$%^&*+?:_/=<>.',;]*)?
 ([hH]ttp[s]{0,1})://[a-zA-Z0-9\.\-]+\.([a-zA-Z]{2,4})(:\d+)?(/[a-zA-Z0-9\-~!@#$%^&*+?:_/=<>]*)?
 (?i)https?://[a-zA-Z0-9]+(\.[a-zA-Z0-9]+)+([-A-Z0-9a-z_\$\.\+!\*\(\)/,:;@&=\?~#%]*)*
 ^http?://[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)+(\/[\w-. \/\?%@&+=\u4e00-\u9fa5]*)?$
 
 链接 (例如 www.baidu.com/s?wd=test ):
 ^[a-zA-Z0-9]+(\.[a-zA-Z0-9]+)+([-A-Z0-9a-z_\$\.\+!\*\(\)/,:;@&=\?~#%]*)*
 
 邮箱 (例如 sjobs@apple.com ):
 \b([a-zA-Z0-9%_.+\-]{1,32})@([a-zA-Z0-9.\-]+?\.[a-zA-Z]{2,6})\b
 \b([a-zA-Z0-9%_.+\-]+)@([a-zA-Z0-9.\-]+?\.[a-zA-Z]{2,6})\b
 ([a-zA-Z0-9%_.+\-]+)@([a-zA-Z0-9.\-]+?\.[a-zA-Z]{2,6})
 
 电话号码 (例如 18612345678):
 ^[1-9][0-9]{4,11}$
 
 At (例如 @王思聪 ):
 @([\x{4e00}-\x{9fa5}A-Za-z0-9_\-]+)
 
 话题 (例如 #奇葩说# ):
 #([^@]+?)#
 
 表情 (例如 [呵呵] ):
 \[([^ \[]*?)]
 
 匹配单个字符 (中英文数字下划线连字符)
 [\x{4e00}-\x{9fa5}A-Za-z0-9_\-]
 
 匹配回复 (例如 回复@王思聪: ):
 \x{56de}\x{590d}@([\x{4e00}-\x{9fa5}A-Za-z0-9_\-]+)(\x{0020}\x{7684}\x{8d5e})?:
 
 */
