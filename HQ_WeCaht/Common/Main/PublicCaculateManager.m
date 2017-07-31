//
//  PublicCaculateManager.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/4/17.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "PublicCaculateManager.h"
#import "ContractModel+Action.h"
#import "HQGifPlayManager.h"
#import "HQDeviceVoiceManager.h"
#import "HQRecordManager.h"
#import "HQAudioPlayerManager.h"

@implementation PublicCaculateManager


+ (void)clearChatViewControllerManagers{
    [[HQGifPlayManager shareInstance] stopAllGIFAnimationView];
    [[HQDeviceVoiceManager sharedManager] disableProximitySensor];
    [[HQRecordManager sharedManager] stopRecording];
    [[HQAudioPlayerManager sharedManager] stopPlaying];
}
+ (NSDictionary *)groupContractWith:(NSArray *)dataSourse{
    NSMutableArray *nameArray = [NSMutableArray new];
    for (ContractModel *model in dataSourse) {
        [nameArray addObject:model.userName];
    }
    NSDictionary *dic = [self dictionaryOrderByCharacterWithOriginalArray:nameArray];
    NSArray *names = [dic objectForKey:[dic.allKeys firstObject]];
    NSMutableArray *totalArr = [NSMutableArray new];
    for (NSArray *ns in names) {
        NSMutableArray *groupArr = [NSMutableArray new];
        for (NSString *name in ns) {
            NSString *filter = [NSString stringWithFormat:@"userName = '%@'",name];
            NSPredicate *pre = [NSPredicate predicateWithFormat:filter];
            [groupArr addObjectsFromArray:[dataSourse filteredArrayUsingPredicate:pre]];
        }
        [totalArr addObject:groupArr];
    }
    return [NSDictionary dictionaryWithObjectsAndKeys:totalArr,dic.allKeys.count?[dic.allKeys firstObject]:[NSArray array], nil];
}

+ (NSDictionary *)dictionaryOrderByCharacterWithOriginalArray:(NSArray *)array{
    if (array.count == 0) {
        return [NSDictionary dictionary];
    }
    for (id obj in array) {
        if (![obj isKindOfClass:[NSString class]]) {
            return [NSDictionary dictionary];
        }
    }
    UILocalizedIndexedCollation *indexedCollation = [UILocalizedIndexedCollation currentCollation];
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:indexedCollation.sectionTitles.count];
    //创建27个分组数组
    for (int i = 0; i < indexedCollation.sectionTitles.count; i++) {
        NSMutableArray *obj = [NSMutableArray array];
        [objects addObject:obj];
    }
    NSMutableArray *keys = [NSMutableArray arrayWithCapacity:objects.count];
    //按字母顺序进行分组
    NSInteger lastIndex = -1;
    for (int i = 0; i < array.count; i++) {
        NSInteger index = [indexedCollation sectionForObject:array[i] collationStringSelector:@selector(uppercaseString)];
        [[objects objectAtIndex:index] addObject:array[i]];
        lastIndex = index;
    }
    //去掉空数组
    for (int i = 0; i < objects.count; i++) {
        NSMutableArray *obj = objects[i];
        if (obj.count == 0) {
            [objects removeObject:obj];
        }
    }
    //获取索引字母
    for (NSMutableArray *obj in objects) {
        NSString *str = obj[0];
        NSString *key = [self firstCharacterWithString:str];
        [keys addObject:key];
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:objects forKey:keys];
    return dic;
}
//获取字符串(或汉字)首字母
+(NSString *)firstCharacterWithString:(NSString *)string{
    NSMutableString *str = [NSMutableString stringWithString:string];
    CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformStripDiacritics, NO);
    NSString *pingyin = [str capitalizedString];
    return [pingyin substringToIndex:1];
}

@end
