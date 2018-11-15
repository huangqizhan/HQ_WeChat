//
//  HQPopoverView.h
//  HQ_WeChat
//
//  Created by 黄麒展  QQ 757618403 on 2017/8/27.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HQPopoverAction.h"


@interface HQPopoverView : UIView


+ (instancetype)popoverView;

@property (nonatomic, assign) BOOL hideAfterTouchOutside; ///< 是否开启点击外部隐藏弹窗, 默认为YES.
@property (nonatomic, assign) BOOL showShade; ///< 是否显示阴影, 如果为YES则弹窗背景为半透明的阴影层, 否则为透明, 默认为NO.

@property (nonatomic,assign) HQPopoverActionStyle style;



/*! @brief 指向指定的View来显示弹窗
 *  @param pointView 箭头指向的View
 *  @param actions   动作对象集合<PopoverAction>
 */
- (void)showToView:(UIView *)pointView withActions:(NSArray<HQPopoverAction *> *)actions;

/*! @brief 指向指定的点来显示弹窗
 *  @param toPoint 箭头指向的点(这个点的坐标需按照keyWindow的坐标为参照)
 *  @param actions 动作对象集合<PopoverAction>
 */
- (void)showToPoint:(CGPoint)toPoint withActions:(NSArray<HQPopoverAction *> *)actions;

@end
