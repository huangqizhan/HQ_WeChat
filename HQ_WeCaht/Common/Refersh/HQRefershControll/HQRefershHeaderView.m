//
//  HQRefershHeaderView.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/25.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HQRefershHeaderView.h"
#import "HQRefershConst.h"

@interface HQRefershHeaderView ()

@property (nonatomic,strong) UIActivityIndicatorView *indicatorView;

@end

@implementation HQRefershHeaderView

+ (instancetype)headerWithRefreshingBlock:(RefreshControllRefreshingBlock)refreshingBlock{
    HQRefershHeaderView  *header = [[self alloc] init];
    header.backgroundColor = [UIColor clearColor];
    header.refreshingBlock = refreshingBlock;
    return header;
}
- (void)prepare{
    [super prepare];
//    self.lastUpdatedTimeKey = RefreshHeaderLastUpdatedTimeKey;
    // 设置高度
    self.height = RefershHeight;
    self.automaticallyChangeAlpha = YES;
    _indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((App_Frame_Width-40)/2.0, (self.height-40)/2.0, 40, 40)];
    _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [_indicatorView startAnimating];
    [self addSubview:_indicatorView];
}

- (void)placeSubviews{
    [super placeSubviews];
    
    self.top = -self.height - self.ignoredScrollViewContentInsetTop;
    
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change{
    [super scrollViewContentOffsetDidChange:change];
    
    if (self.state == HQRefreshControllStatRefreshing) {
        return;
    }
    // 跳转到下一个控制器时，contentInset可能会变
    _scrollViewOriginalInset = self.scrollView.contentInset;
    
    CGFloat offsetY = self.scrollView.contentOffset.y;
    
    CGFloat happenOffsetY = - self.scrollViewOriginalInset.top;
    
    if (offsetY > happenOffsetY) {
        return;
    }
    if (self.state !=  HQRefreshControllStatRefreshing && offsetY < -2 ){
        [self beginRefreshing];
    }
}
- (void)setState:(HQRefreshControllState)state{
    HQRefreshControllCheckState
    // 根据状态做事情
    if (state == HQRefreshControllStateNormal) {
        if (oldState != HQRefreshControllStatRefreshing) return;    
        // 恢复inset和offset
        [UIView animateWithDuration:0.25 animations:^{
            self.scrollView.insetT -= self.height;
            // 自动调整透明度
            if (self.isAutomaticallyChangeAlpha) self.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.pullingPercent = 0.0;
        }];
    } else if (state == HQRefreshControllStatRefreshing) {
        [UIView animateWithDuration:RefreshFastAnimationDuration animations:^{
            // 增加滚动区域
            self.scrollView.insetT = self.height;
            // 设置滚动位置
            self.scrollView.offsetY = - self.height;
            
            self.indicatorView.alpha = 1.0;
        } completion:^(BOOL finished) {
            [self executeRefreshingCallback];
        }];
    }
}
- (void)beginRefreshing{
    [super beginRefreshing];
}
#pragma mark - 公共方法
- (void)endRefreshing{
    if ([self.scrollView isKindOfClass:[UICollectionView class]]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [super endRefreshing];
        });
    } else {
        [super endRefreshing];
    }
}
- (void)endFershingWhenNoMoreData{
    WEAKSELF;
    [self endRefreshingWithCallBack:^{
        [weakSelf removeFromSuperview];
    }];
}

- (void)endRefreshingWithCallBack:(void (^)())callBack{
    [UIView animateWithDuration:.35 animations:^{
        self.indicatorView.alpha = 0.0;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [super endRefreshing];
        });
        if (callBack)callBack();
    }];
}



@end
