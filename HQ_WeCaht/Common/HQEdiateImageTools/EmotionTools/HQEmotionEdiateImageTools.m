//
//  HQEmotionEdiateImageTools.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/25.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQEmotionEdiateImageTools.h"
#import "HQEdiateImageController.h"

@interface HQEmotionEdiateImageTools ()



@end


@implementation HQEmotionEdiateImageTools
- (instancetype)initWithEdiateController:(HQEdiateImageController *)ediateController andEdiateToolInfo:(HQEdiateToolInfo *)toolInfo{
    return [super initWithEdiateController:ediateController andEdiateToolInfo:toolInfo];
}


- (void)setUpCurrentEdiateStatus{
    [super setUpCurrentEdiateStatus];
    
    
    
}

- (void)clearCurrentEdiateStatus{
    [super clearCurrentEdiateStatus];
}
- (void)executeWithCompletionBlock:(void (^)(UIImage *, NSError *, NSDictionary *))completionBlock{
    
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
