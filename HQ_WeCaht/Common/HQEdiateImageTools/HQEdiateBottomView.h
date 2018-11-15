//
//  HQEdiateBottomView.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/31.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HQEdiateImageProtocal.h"
#import "HQEdiateToolInfo.h"


@class HQEdiateImageToolInfo;

@interface HQEdiateBottomView : UIView

- (instancetype)initWithFrame:(CGRect)frame andClickButtonIndex:(void(^)(HQEdiateToolInfo *toolInfo))callClickButtonIndex;

@property (nonatomic,copy)  void (^bottomEdiateViewClick)(HQEdiateToolInfo *toolInfo);

@end








#pragma mark -------- 底部视图的item ------ 


@interface HQEdiateItem :   UIControl


@property (nonatomic,copy)  void (^clickBackAction)(HQEdiateToolInfo *info);

- (instancetype)initWithFram:(CGRect)frame andToolInfo:(HQEdiateToolInfo *)toolInfo   andClickCallBackAction:(void (^)(HQEdiateToolInfo *info))clickCallBackAction;




@end






