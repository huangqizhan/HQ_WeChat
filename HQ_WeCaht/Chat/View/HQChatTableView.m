//
//  HQChatTableView.m
//  HQ_WeChat
//
//  Created by 黄麒展 on 2018/10/28.
//  Copyright © 2018年 黄麒展. All rights reserved.
//

#import "HQChatTableView.h"

@implementation HQChatTableView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.delaysContentTouches = NO;
    self.canCancelContentTouches = YES;
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // Remove touch delay (since iOS 8)
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
    
    return self;
}

- (BOOL)touchesShouldBegin:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view{
    return [super touchesShouldBegin:touches withEvent:event inContentView:view];
}
- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    if ( [view isKindOfClass:[UIControl class]]) {
        return YES;
    }else if ([view isKindOfClass:NSClassFromString(@"HQLabel")]){
        return NO;
    }
    return [super touchesShouldCancelInContentView:view];
}
//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
//    return self;
//}
@end
