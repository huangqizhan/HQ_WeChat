//
//  HQEdiateToolInfo.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/8/1.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HQEdiateImageProtocal.h"

@interface HQEdiateToolInfo : NSObject


@property (nonatomic, readonly) NSString *toolName; //类名
@property (nonatomic, strong)   NSString *title;    //工具显示的名称
@property (nonatomic, strong) UIImage  *iconImage;  //图片
@property (nonatomic, readonly) NSArray  *subtools; //包含的子工具信息 KKImageToolInfo数组
@property (nonatomic, assign) NSUInteger orderNum;  //显示的顺序


+ (HQEdiateToolInfo *)toolInfoForToolClass:(Class<HQEdiateImageProtocal>)toolClass;

+ (NSArray *)toolsWithToolClass:(Class<HQEdiateImageProtocal>)toolClass;

@end
