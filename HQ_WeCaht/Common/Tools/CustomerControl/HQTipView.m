//
//  HQTipView.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/1.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HQTipView.h"
#import "UIApplication+HQExtern.h"

#define SAFE_SEND_MESSAGE(obj, msg) if ((obj) && [(obj) respondsToSelector:@selector(msg)])


@interface HQTipView ()

@property (nonatomic) NSMutableSet<UIView<HQTipViewDelegate> *> *allTipViews;


@end

@implementation HQTipView


+ (instancetype)sharedInstance {
    static HQTipView *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HQTipView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    });
    return instance;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _allTipViews = [NSMutableSet set];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tap];
    }
    
    return self;
}
- (void)tapHandler:(UITapGestureRecognizer *)tap {
    NSSet<UIView<HQTipViewDelegate> *> *tipViews = [self.allTipViews copy];
    for (UIView<HQTipViewDelegate> *tipView in tipViews) {
        SAFE_SEND_MESSAGE(tipView, canCancelByTouch) {
            BOOL canCancel = [tipView canCancelByTouch];
            
            if (canCancel) {
                [self removeTipView:tipView];
            }
        }
    }
    
}
- (void)removeTipView:(UIView<HQTipViewDelegate> *)tipView {
    [_allTipViews removeObject:tipView];
    
    SAFE_SEND_MESSAGE(tipView, willRemoveFromTipLayer) {
        [tipView willRemoveFromTipLayer];
    }
    
    [tipView removeFromSuperview];
    
    SAFE_SEND_MESSAGE(tipView, didRemoveFromTipLayer) {
        [tipView didRemoveFromTipLayer];
    }
    
    if (_allTipViews.count == 0)
        [self removeFromSuperview];
    
}
+ (void)showTipView:(nonnull UIView<HQTipViewDelegate> *)view {
    HQTipView *containerView = [HQTipView sharedInstance];
    if (!containerView.superview) {
        [[UIApplication currentWindow] addSubview:containerView];
    }
    [containerView.superview bringSubviewToFront:containerView];
    
    [containerView.allTipViews addObject:view];
    
    [containerView addSubview:view];
    SAFE_SEND_MESSAGE(view, didMoveToTipLayer) {
        [view didMoveToTipLayer];
    }
    
    view.center = containerView.center;
    SAFE_SEND_MESSAGE(view, tipViewCenterPositionOffset) {
        UIOffset offset = [view tipViewCenterPositionOffset];
        view.center = CGPointMake(view.center.x + offset.horizontal, view.center.y + offset.vertical);
    }
    
}

+ (void)hideTipView:(nonnull UIView<HQTipViewDelegate> *)tipView {
    HQTipView *containerView = [HQTipView sharedInstance];
    [containerView removeTipView:tipView];
}


@end
