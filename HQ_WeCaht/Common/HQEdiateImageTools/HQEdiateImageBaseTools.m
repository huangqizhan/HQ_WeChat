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
//    self.ediateMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, APP_Frame_Height, App_Frame_Width, 120)];
//    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10, 5, 40, 40)];
//    [button setImage:[UIImage imageNamed:@"EmoticonCloseButton_16x16_"] forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
////    [self.ediateMenuView addSubview:button];
//    self.ediateMenuView.backgroundColor = [UIColor redColor];
//    [self.imageEdiateController.view addSubview:self.ediateMenuView];
//    [UIView animateWithDuration:0.15 animations:^{
//        self.ediateMenuView.top = APP_Frame_Height-120;
//    }];
}
//- (void)cancelButtonAction:(UIButton *)sender{
////    [self clearCurrentEdiateStatus];
////    [self.ediateMenuView removeFromSuperview];
//}
- (void)clearCurrentEdiateStatus{
//    [UIView animateWithDuration:0.15 animations:^{
//        self.ediateMenuView.top = APP_Frame_Height;
//    } completion:^(BOOL finished) {
//        [self.ediateMenuView removeFromSuperview];
//    }];
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
