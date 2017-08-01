//
//  HQEdiateBottomView.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/31.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HQEdiateImageProtocal.h"


@class HQEdiateImageToolInfo;

@interface HQEdiateBottomView : UIView

- (instancetype)initWithFrame:(CGRect)frame andClickButtonIndex:(void(^)(HQEdiateImageToolInfo *toolInfo))callClickButtonIndex;

@property (nonatomic,copy)  void (^bottomEdiateViewClick)(HQEdiateImageToolInfo *toolInfo);

@end








#pragma mark -------- 底部视图的item ------ 


@interface HQEdiateItem :   UIControl


@property (nonatomic,copy)  void (^clickBackAction)(HQEdiateImageToolInfo *info);

- (instancetype)initWithFram:(CGRect)frame andToolInfo:(HQEdiateImageToolInfo *)toolInfo   andClickCallBackAction:(void (^)(HQEdiateImageToolInfo *info))clickCallBackAction;




@end











#pragma mark -------- 底部编辑视图的封装模型 --------

@interface HQEdiateImageToolInfo : NSObject

@property (nonatomic, readonly) NSString *toolName; //类名
@property (nonatomic, strong)   NSString *title;    //工具显示的名称
@property (nonatomic, strong) UIImage  *iconImage;  //图片
@property (nonatomic, readonly) NSArray  *subtools; //包含的子工具信息 KKImageToolInfo数组
@property (nonatomic, assign) NSUInteger orderNum;  //显示的顺序


+ (HQEdiateImageToolInfo *)toolInfoForToolClass:(Class<HQEdiateImageProtocal>)toolClass;

+ (NSArray *)toolsWithToolClass:(Class<HQEdiateImageProtocal>)toolClass;

@end
