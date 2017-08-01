//
//  HQMosaicEdiateImage.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/25.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQMosaicEdiateImage.h"
#import "HQEdiateImageController.h"



@implementation HQMosaicEdiateImage
- (instancetype)initWithEdiateController:(HQEdiateImageController *)ediateController andEdiateToolInfo:(HQEdiateToolInfo *)toolInfo{
    return [super initWithEdiateController:ediateController andEdiateToolInfo:toolInfo];
}


- (void)setUpCurrentEdiateStatus{
    [super setUpCurrentEdiateStatus];
}

- (void)clearCurrentEdiateStatus{
    [super clearCurrentEdiateStatus];
    
}
//图片
+ (UIImage*)defaultIconImage{
    return [UIImage imageNamed:@"ToolMasaic"];
}

//工具名称
+ (NSString*)defaultTitle{
    return nil;
    
}
//显示顺序
+ (NSUInteger)orderNum{
    return 2;
}

@end
