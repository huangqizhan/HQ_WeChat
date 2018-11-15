//
//  HQPopoverViewCell.h
//  HQ_WeChat
//
//  Created by 黄麒展  QQ 757618403 on 2017/8/27.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HQPopoverAction.h"

UIKIT_EXTERN float const PopoverViewCellHorizontalMargin; ///< 水平间距边距
UIKIT_EXTERN float const PopoverViewCellVerticalMargin; ///< 垂直边距
UIKIT_EXTERN float const PopoverViewCellTitleLeftEdge; ///< 标题左边边距


@interface HQPopoverViewCell : UITableViewCell

@property (nonatomic, assign) HQPopoverActionStyle style;

+ (UIColor *)bottomLineColorForStyle:(HQPopoverActionStyle )style;

+ (UIFont *)titleFont;

- (void)setAction:(HQPopoverAction *)action;

- (void)showBottomLine:(BOOL)show;

@end
