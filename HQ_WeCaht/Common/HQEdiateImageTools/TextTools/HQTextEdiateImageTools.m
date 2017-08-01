//
//  HQTextEdiateImageTools.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/25.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQTextEdiateImageTools.h"

@implementation HQTextEdiateImageTools

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
    return [UIImage imageNamed:@"ToolText"];
}

//工具名称
+ (NSString*)defaultTitle{
    return nil;
    
}
//显示顺序
+ (NSUInteger)orderNum{
    return 5;
}

@end
