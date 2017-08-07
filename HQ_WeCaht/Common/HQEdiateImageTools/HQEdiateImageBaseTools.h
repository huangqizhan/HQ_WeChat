//
//  HQEdiateImageBaseTools.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/25.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HQEdiateImageProtocal.h"
#import "HQEdiateToolInfo.h"


@class  HQEdiateImageController;



typedef NS_ENUM(NSInteger,HQEdiateImageType) {
    HQEdiateImageDrawType = 1,            ///画笔编辑
    HQEdiateImageMosaicType,              ///马赛克编辑
    HQEdiateImageEmtionType,              ////表情
    HQEdiateImageCutType,                     ///裁剪
    HQEdiateImageTextType                    ///文本编辑
};


@interface HQEdiateImageBaseTools : NSObject <HQEdiateImageProtocal>{
    
    __weak  HQEdiateImageController * _imageEdiateController;
    
}


- (instancetype)initWithEdiateController:(HQEdiateImageController *)ediateController andEdiateToolInfo:(HQEdiateToolInfo *)toolInfo;



@property (nonatomic,weak) HQEdiateImageController *imageEdiateController;
@property (nonatomic,strong) HQEdiateToolInfo *toolInfo;
@property (nonatomic,strong) UIView *ediateMenuView;



- (void)setUpCurrentEdiateStatus;

- (void)clearCurrentEdiateStatus;


- (void)executeWithCompletionBlock:(void(^)(UIImage *image, NSError *error, NSDictionary *userInfo))completionBlock;

@end
