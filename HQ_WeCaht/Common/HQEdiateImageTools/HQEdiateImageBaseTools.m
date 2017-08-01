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
        [self setUpCurrentEdiateStatus];
    }
    return self;
}

- (void)setUpCurrentEdiateStatus{
    self.ediateMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, APP_Frame_Height, App_Frame_Width, 120)];
    self.ediateMenuView.backgroundColor = [UIColor redColor];
    [self.imageEdiateController.view addSubview:self.ediateMenuView];
    [UIView animateWithDuration:0.15 animations:^{
        self.ediateMenuView.top = APP_Frame_Height-120;
    }];
}

- (void)clearCurrentEdiateStatus{
    [self.ediateMenuView removeFromSuperview];
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
