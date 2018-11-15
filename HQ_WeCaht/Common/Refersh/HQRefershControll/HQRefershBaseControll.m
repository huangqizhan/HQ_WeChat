//
//  HQRefershBaseControll.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/25.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HQRefershBaseControll.h"
#import "HQRefershConst.h"


@interface HQRefershBaseControll ()

@property (strong, nonatomic) UIPanGestureRecognizer *pan;

@end


@implementation HQRefershBaseControll
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self prepare];
        _state = HQRefreshControllStateNormal;
    }
    return self;
}
- (void)prepare{
    // 基本属性
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.backgroundColor = [UIColor clearColor];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self placeSubviews];
}
- (void)placeSubviews{
}
- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    if (newSuperview && ![newSuperview isKindOfClass:[UIScrollView class]]) return;
    [self removeObservers];
    if (newSuperview) {
        self.x = 0;
        self.width = newSuperview.width;
        _scrollView = (UIScrollView *)newSuperview;
        _scrollView.alwaysBounceVertical = YES;
        _scrollViewOriginalInset = _scrollView.contentInset;
        [self addObservers];
    }
}
- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    if (self.state == HQRefreshControllStatWillRefresh) {
        self.state = HQRefreshControllStatRefreshing;
    }
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (!self.userInteractionEnabled) {
        return;
    }
    if ([keyPath isEqualToString:RefreshKeyPathContentSize]) {
        [self scrollViewContentSizeDidChange:change];
    }
    if (self.hidden) {
        return;
    }
    if ([keyPath isEqualToString:RefreshKeyPathContentOffset]) {
        [self scrollViewContentOffsetDidChange:change];
    }else if ([keyPath isEqualToString:RefreshKeyPathPanState]){
        [self scrollViewPanStateDidChange:change];
    }
}
- (void)setRefreshingTarget:(id)target refreshingAction:(SEL)action{
    self.refreshingTarget = target;
    self.refreshingAction = action;
}
- (void)executeRefreshingCallback{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.refreshingBlock) {
            self.refreshingBlock();
        }
        if ([self.refreshingTarget respondsToSelector:self.refreshingAction]) {
            ((void(*)(void *,SEL,UIView *))objc_msgSend)((__bridge void *)(self.refreshingTarget), self.refreshingAction,self);
        }
    });
}
- (void)endRefreshingWithCallBack:(void (^)())callBack{
    
}
- (void)endFershingWhenNoMoreData{
    
}
- (void)beginRefreshing{
    [UIView animateWithDuration:RefreshFastAnimationDuration animations:^{
        self.alpha = 1.0;
    }];
    self.pullingPercent = 1.0;
    if (self.window) {
        self.state = HQRefreshControllStatRefreshing;
    }else{
        self.state = HQRefreshControllStatWillRefresh;
        [self setNeedsDisplay];
    }
}
- (void)endRefreshing{
    self.state = HQRefreshControllStateNormal;
}
- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change{}
- (void)scrollViewContentSizeDidChange:(NSDictionary *)change{}
- (void)scrollViewPanStateDidChange:(NSDictionary *)change{}



- (void)removeObservers{
    [self.superview removeObserver:self forKeyPath:RefreshKeyPathContentOffset];
    [self.superview removeObserver:self forKeyPath:RefreshKeyPathContentSize];;
    [self.pan removeObserver:self forKeyPath:RefreshKeyPathPanState];
    self.pan = nil;
}

- (void)addObservers{
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [self.scrollView addObserver:self forKeyPath:RefreshKeyPathContentOffset options:options context:nil];
    [self.scrollView addObserver:self forKeyPath:RefreshKeyPathContentSize options:options context:nil];
    self.pan = self.scrollView.panGestureRecognizer;
    [self.pan addObserver:self forKeyPath:RefreshKeyPathPanState options:options context:nil];
    
}


@end
