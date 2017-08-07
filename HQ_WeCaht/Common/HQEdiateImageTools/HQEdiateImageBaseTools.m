//
//  HQEdiateImageBaseTools.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/25.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQEdiateImageBaseTools.h"
#import "HQEdiateImageController.h"



@implementation HQEdiateImageBaseTools

- (instancetype)initWithEdiateController:(HQEdiateImageController *)ediateController andEdiateToolInfo:(HQEdiateToolInfo *)toolInfo{
    self = [super init];
    if (self) {
        self.toolInfo = toolInfo;
        self.imageEdiateController = ediateController;
    }
    return self;
}

- (void)setUpCurrentEdiateStatus{
    
}

- (void)clearCurrentEdiateStatus{

}

- (void)executeWithCompletionBlock:(void(^)(UIImage *image, NSError *error, NSDictionary *userInfo))completionBlock{
    
}

//图片
+ (UIImage*)defaultIconImage{
    return nil;
}

//工具名称
+ (NSString*)defaultTitle{
    return nil;
    
}

//包含的子工具
+ (NSArray*)subtools{
    return nil;
    
}

//显示顺序
+ (NSUInteger)orderNum{
    return 0;
}
@end
