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

- (instancetype)initWithEdiateController:(HQEdiateImageController *)ediateController andEdiateType:(HQEdiateImageType )type{
    self = [super init];
    if (self) {
        self.ediateType =  type;
        self.imageEdiateController = ediateController;
        [self setUpCurrentEdiateStatus];
    }
    return self;
}

- (void)setUpCurrentEdiateStatus{
    _ediateMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, APP_Frame_Height-80, App_Frame_Width, 80)];
    _ediateMenuView.backgroundColor = [UIColor redColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 100, 20)];
    label.text = [NSString stringWithFormat:@"%ld",self.ediateType];
    [_ediateMenuView addSubview:label];
    [self.imageEdiateController.view addSubview:_ediateMenuView];
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
