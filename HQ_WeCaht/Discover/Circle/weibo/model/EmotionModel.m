//
//  EmotionModel.m
//  YYStudyDemo
//
//  Created by hqz  QQ 757618403 on 2018/9/25.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//

#import "EmotionModel.h"

@implementation EmotionModel
+ (NSArray *)modelPropertyBlacklist {
    return @[@"group"];
}
@end


@implementation WBEmoticonGroup
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"groupID" : @"id",
             @"nameCN" : @"group_name_cn",
             @"nameEN" : @"group_name_en",
             @"nameTW" : @"group_name_tw",
             @"displayOnly" : @"display_only",
             @"groupType" : @"group_type"};
}
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"emoticons" : [EmotionModel class]};
}
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    [_emoticons enumerateObjectsUsingBlock:^(EmotionModel *emoticon, NSUInteger idx, BOOL *stop) {
        emoticon.group = self;
    }];
    return YES;
}
@end
