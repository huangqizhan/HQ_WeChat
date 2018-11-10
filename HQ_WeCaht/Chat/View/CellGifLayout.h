//
//  CellGifLayout.h
//  HQ_WeChat
//
//  Created by 黄麒展 on 2018/10/26.
//  Copyright © 2018年 黄麒展. All rights reserved.
//

#import "HQBaseCellLayout.h"
#import "ImageCore.h"

NS_ASSUME_NONNULL_BEGIN

@interface CellGifLayout : HQBaseCellLayout

///gif data
@property (nonatomic,strong) MyImage *image;
///frame
@property (nonatomic,assign) CGRect imageFrame;

@end

NS_ASSUME_NONNULL_END
