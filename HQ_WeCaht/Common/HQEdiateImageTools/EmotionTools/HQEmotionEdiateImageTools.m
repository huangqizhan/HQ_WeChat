//
//  HQEmotionEdiateImageTools.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/25.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQEmotionEdiateImageTools.h"

@implementation HQEmotionEdiateImageTools
- (instancetype)initWithEdiateController:(HQEdiateImageController *)ediateController andEdiateType:(HQEdiateImageType)type{
    return [super initWithEdiateController:ediateController andEdiateType:type];
}


- (void)setUpCurrentEdiateStatus{
    NSLog(@"setUpCurrentEdiateStatus");
}

- (void)clearCurrentEdiateStatus{
    
}
//图片
+ (UIImage*)defaultIconImage{
    return [UIImage imageNamed:@"ToolViewEmotion"];
}

//工具名称
+ (NSString*)defaultTitle{
    return nil;
    
}

//显示顺序
+ (NSUInteger)orderNum{
    return 3;
}


@end
