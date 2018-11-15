//
//  ImageControll.h
//  YYStudyDemo
//
//  Created by hqz  QQ 757618403 on 2018/9/28.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageControll : UIView
/// 数据
@property (nonatomic, strong) UIImage *image;
#pragma mark ----- 事件 ---
/// 点击
@property (nonatomic, copy) void (^touchBlock)(ImageControll *view, UIGestureRecognizerState state, NSSet *touches, UIEvent *event);
///长按
@property (nonatomic, copy) void (^longPressBlock)(ImageControll *view, CGPoint point);

@end

NS_ASSUME_NONNULL_END
