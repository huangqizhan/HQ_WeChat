//
//  CellImageLayout.h
//  HQ_WeChat
//
//  Created by 黄麒展 on 2018/10/26.
//  Copyright © 2018年 黄麒展. All rights reserved.
//

#import "HQBaseCellLayout.h"
#import "HQImageIOHelper.h" 
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface CellImageLayout : HQBaseCellLayout

@property (nonatomic,strong) UIImage *image;

@property (nonatomic,assign) CGRect imageFrame;

@end

NS_ASSUME_NONNULL_END
