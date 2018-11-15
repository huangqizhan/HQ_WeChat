//
//  HQRefershBaseControll.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/25.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>


/** 刷新控件的状态 */
typedef enum {
    HQRefreshControllStateNormal = 1,  // 普通闲置状态
    HQRefreshControllStatPulling,      /// 松开就可以进行刷新的状态
    HQRefreshControllStatRefreshing,   // 正在刷新中的状态
    HQRefreshControllStatWillRefresh,  // 即将刷新的状态
} HQRefreshControllState;





typedef void (^RefreshControllRefreshingBlock)();



@interface HQRefershBaseControll : UIView{
    /** 记录scrollView刚开始的inset */
    UIEdgeInsets _scrollViewOriginalInset;
    
    __weak UIScrollView *_scrollView;
}

@property (assign, nonatomic, readonly) UIEdgeInsets scrollViewOriginalInset;
@property (weak ,nonatomic,readonly)UIScrollView *scrollView;
@property (nonatomic,assign) HQRefreshControllState state;


@property (nonatomic,copy) RefreshControllRefreshingBlock refreshingBlock;


//// 回调对象
@property (weak, nonatomic) id refreshingTarget;
//// 回调方法 
@property (assign, nonatomic) SEL refreshingAction;


// 设置回调对象和回调方法
- (void)setRefreshingTarget:(id)target refreshingAction:(SEL)action;
//// 触发回调（交给子类去调用）
- (void)executeRefreshingCallback;
/// 进入刷新状态
- (void)beginRefreshing;
/// 结束刷新状态
- (void)endRefreshing;

///下拉加载更多没有数据时结束刷新
- (void)endFershingWhenNoMoreData;




#pragma mark - 交给子类们去实现
/// 初始化
- (void)prepare NS_REQUIRES_SUPER;
//// 摆放子控件frame
- (void)placeSubviews NS_REQUIRES_SUPER;
/// 当scrollView的contentOffset发生改变的时候调用
- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change NS_REQUIRES_SUPER;
/// 当scrollView的contentSize发生改变的时候调用
- (void)scrollViewContentSizeDidChange:(NSDictionary *)change NS_REQUIRES_SUPER;
/// 当scrollView的拖拽状态发生改变的时候调用
- (void)scrollViewPanStateDidChange:(NSDictionary *)change NS_REQUIRES_SUPER;

/// 拉拽的百分比(交给子类重写)
@property (assign, nonatomic) CGFloat pullingPercent;

/** 根据拖拽比例自动切换透明度 */
@property (assign, nonatomic, getter=isAutomaticallyChangeAlpha) BOOL automaticallyChangeAlpha;

- (void)endRefreshingWithCallBack:(void (^)())callBack;








@end
