//
//  HQChatTableView.m
//  HQ_WeChat
//
//  Created by 黄麒展  QQ 757618403 on 2018/10/28.
//  Copyright © 2018年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HQChatTableView.h"
#import "HQLabel.h"

@implementation HQChatTableView{
    __weak HQLabel *_currentMsgLabel;
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self = [super initWithFrame:frame style:style];
//    self.delaysContentTouches = NO;
//    self.canCancelContentTouches = YES;
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(labelDidShowSelectionViewAction:) name:HQLabelDidShowSelectionViewNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(labelDidDismissSelectionViewAction:) name:HQLabelDidHiddenSelectionViewNotification object:nil];
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
    if (_currentMsgLabel != view) {
        CGPoint point = [[touches anyObject] locationInView:view];
        CGPoint newPoint = [view convertPoint:point toView:[UIApplication sharedApplication].keyWindow];
        CGRect rect = [_currentMsgLabel.superview convertRect:_currentMsgLabel.frame toView:[UIApplication sharedApplication].keyWindow];
        rect.origin.x -= 15;
        rect.size.width += 30;
        rect.origin.y -= 15;
        rect.size.height += 30;
        if (!CGRectContainsPoint(rect, newPoint)) {
            [_currentMsgLabel removeSelectionView];
        }
    }
    return [super touchesShouldBegin:touches withEvent:event inContentView:view];
}
- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    if ([view isKindOfClass:NSClassFromString(@"HQLabel")]){
        if (_currentMsgLabel == view) {
            return NO;
        }else{
            _currentMsgLabel = (HQLabel *)view;
        }
    }
    return [super touchesShouldCancelInContentView:view];
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    CGPoint newPoint = [self convertPoint:point toView:[UIApplication sharedApplication].keyWindow];
    CGRect rect = [_currentMsgLabel.superview convertRect:_currentMsgLabel.frame toView:[UIApplication sharedApplication].keyWindow];
    rect.origin.x -= 15;
    rect.size.width += 30;
    rect.origin.y -= 15;
    rect.size.height += 30;
    if (!CGRectContainsPoint(rect, newPoint)) {
        [_currentMsgLabel removeSelectionView];
    }
    return [super hitTest:point withEvent:event];
}
- (void)labelDidShowSelectionViewAction:(NSNotification *)notification{
    if ([notification.object isKindOfClass:NSClassFromString(@"HQLabel")]) {
        _currentMsgLabel = (HQLabel *)notification.object;
    }
}
- (void)labelDidDismissSelectionViewAction:(NSNotification *)notification{
    if ([notification.object isKindOfClass:NSClassFromString(@"HQLabel")]) {
        _currentMsgLabel = nil;
    }
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)chatTableViewDidEndScroll{
    if (_currentMsgLabel) {
        [_currentMsgLabel showMenuController];
    }
}
- (void)chatTableViewDidBeginScroll{
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
}
@end
