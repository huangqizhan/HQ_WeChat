//
//  HQCircleTableView.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/11/17.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQCircleTableView.h"

@implementation HQCircleTableView

- (instancetype)initWithFrame:(CGRect)frame{
    self  = [super initWithFrame:frame];
    if (self) {
        self.delaysContentTouches = NO;
        self.canCancelContentTouches = YES;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        // 移除触摸延迟
        UIView *wrapView = self.subviews.firstObject;
        // UITableViewWrapperView
        if (wrapView && [NSStringFromClass(wrapView.class) hasSuffix:@"WrapperView"]) {
            for (UIGestureRecognizer *gesture in wrapView.gestureRecognizers) {
                // UIScrollViewDelayedTouchesBeganGestureRecognizer
                if ([NSStringFromClass(gesture.class) containsString:@"DelayedTouchesBegan"] ) {
                    gesture.enabled = NO;
                    break;
                }
            }
        }
    }
    return self;
}


- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    if ( [view isKindOfClass:[UIControl class]]) {
        return YES;
    }
    return [super touchesShouldCancelInContentView:view];
}
@end
