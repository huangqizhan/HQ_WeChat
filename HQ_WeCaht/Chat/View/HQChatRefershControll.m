//
//  HQChatRefershControll.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/4/1.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQChatRefershControll.h"


@interface HQChatRefershControll ()<UIScrollViewDelegate>

@property (strong) UIRefreshControl *refreshControl;
///加载视图
@property (nonatomic,strong) UIActivityIndicatorView *activityView;
///所在控制器
@property (nonatomic,weak) UIViewController *viewController;
////要添加到的scrollView
@property (nonatomic,weak) UIScrollView *scrollView;

@property (weak) id originalDelegate;

@property (weak) id refreshTarget;

@property (assign) SEL refreshSelector;



@end


@implementation HQChatRefershControll

- (instancetype)init{
    self = [super init];
    if (self) {
        self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self action:@selector(refreshControlTriggered:) forControlEvents:UIControlEventValueChanged];
        [self.refreshControl addSubview:self.activityView];
    }
    return self;
}

- (void)refreshControlTriggered:(UIRefreshControl *)refersh{
    [self.activityView startAnimating];
    
}
- (void)addToScrollView:(UIScrollView *)scrollView refreshBlock:(void (^)(void))refreshBlock{
    NSAssert([scrollView respondsToSelector:@selector(refreshControl)], @"refreshControl is only available on UIScrollView on iOS 10 and up.");
    [self removeFromPartnerObject];
    self.scrollView = scrollView;
    self.scrollView.refreshControl = self.refreshControl;
    [self.refreshControl.subviews.firstObject removeFromSuperview];
    
    self.originalDelegate = self.scrollView.delegate;
    self.scrollView.delegate = self;
}

- (void)beginRefreshing {
    BOOL adjustScrollOffset = (self.scrollView.contentInset.top == -self.scrollView.contentOffset.y);
    
    self.activityView.hidden = NO;
    [self.activityView stopAnimating];
    [self.refreshControl beginRefreshing];
    [self refreshControlTriggered:self.refreshControl];
    
    if (adjustScrollOffset) {
        [self.scrollView setContentOffset:CGPointMake(0, -self.scrollView.contentInset.top) animated:YES];
    }
}
- (void)endRefreshing {
//    __weak HQChatRefershControll *weakSelf = self;
    
    if (self.scrollView.isDragging) {
        [self.refreshControl endRefreshing];
        return;
    }
    [self.activityView stopAnimating];
    /*
     self.awaitingRefreshEnd = YES;
     NSString * const animationGroupKey = @"animationGroupKey";
     
     [CATransaction begin];
     [CATransaction setCompletionBlock:^{
     [weakSelf.loadingSpinner stopAnimating];
     [weakSelf.loadingSpinner.layer removeAnimationForKey:animationGroupKey];
     
     
     if (!weakSelf.scrollView.isDecelerating) {
     weakSelf.awaitingRefreshEnd = NO;
     }
     }];
     
     CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform"];
     CATransform3D scaleTransform = CATransform3DScale(CATransform3DIdentity, 0.25, 0.25, 1);
     scale.toValue = [NSValue valueWithCATransform3D:scaleTransform];
     
     CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
     opacity.toValue = @(0);
     
     CAAnimationGroup *group = [CAAnimationGroup animation];
     group.animations = @[ scale, opacity ];
     group.removedOnCompletion = NO;
     group.fillMode = kCAFillModeForwards;
     
     [self.loadingSpinner.layer addAnimation:group forKey:animationGroupKey];
     [CATransaction commit];

     */
    [self.refreshControl endRefreshing];
}


- (void)removeFromPartnerObject {
//    if (self.tableViewController) {
//        self.tableViewController.refreshControl = nil;
//        self.tableViewController = nil;
//    }
    
    self.refreshTarget = nil;
    self.refreshSelector = NULL;
    
    self.scrollView.delegate = self.originalDelegate;
    self.scrollView = nil;
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([self.originalDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.originalDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
    
    if (self.activityView.isAnimating && !self.refreshControl.isRefreshing) {
        [self endRefreshing];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self.originalDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.originalDelegate scrollViewDidEndDecelerating:scrollView];
    }
    
    if (!self.refreshControl.isRefreshing) {
//        self.awaitingRefreshEnd = NO;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.originalDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.originalDelegate scrollViewDidScroll:scrollView];
    }
    
    if (!self.refreshControl.hidden) {
//        self.loadingSpinner.frame = CGRectMake(
//                                               (self.refreshControl.frame.size.width - self.loadingSpinner.frame.size.width) / 2,
//                                               (self.refreshControl.frame.size.height - self.loadingSpinner.frame.size.height) / 2,
//                                               self.loadingSpinner.frame.size.width,
//                                               self.loadingSpinner.frame.size.height
//                                               );
        [self.activityView startAnimating];
    }
    
//    if (!self.awaitingRefreshEnd) {
//        self.loadingSpinner.hidden = NO;
//        
//        const CGFloat stretchLength = M_PI_2 + M_PI_4;
//        CGFloat draggedOffset = scrollView.contentInset.top + scrollView.contentOffset.y;
//        CGFloat percentToThreshold = draggedOffset / [self appleMagicOffset];
//        
//        self.loadingSpinner.staticArcLength = MIN(percentToThreshold * stretchLength, stretchLength);
//    }
}

/**
 *  @brief After testing, this is what Apple believes is the perfect offset
 *         at which refreshing should commence.
 */
- (CGFloat)appleMagicOffset {
    __block NSInteger majorOSVersion;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        majorOSVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] firstObject] integerValue];
    });
    
    if (majorOSVersion <= 9) {
        return -109.0;
    } else {
        return -129.0;
    }
}

#pragma mark - UIScrollViewDelegate method forwarding
- (BOOL)respondsToSelector:(SEL)aSelector {
    return [super respondsToSelector:aSelector] || [self.originalDelegate respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return self.originalDelegate;
}


@end
