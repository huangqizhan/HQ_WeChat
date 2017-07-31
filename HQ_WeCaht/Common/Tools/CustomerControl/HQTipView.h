//
//  HQTipView.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/1.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol HQTipViewDelegate <NSObject>

@optional

@property (nonatomic) BOOL canCancelByTouch;

- (void)didMoveToTipLayer;

- (void)willRemoveFromTipLayer;
- (void)didRemoveFromTipLayer;

- (UIOffset)tipViewCenterPositionOffset;

@end


@interface HQTipView : UIView

+ (void)showTipView:(nonnull UIView<HQTipViewDelegate> *)view;

+ (void)hideTipView:(nonnull UIView<HQTipViewDelegate> *)tipView;

@end
