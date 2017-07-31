//
//  HQRefershConst.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/25.
//  Copyright © 2017年 黄麒展. All rights reserved.
//
#import <UIKit/UIKit.h>


const CGFloat RefershHeight = 40;
const CGFloat RefreshFastAnimationDuration = 0.25;
const CGFloat RefreshSlowAnimationDuration = 0.4;


NSString *const RefreshKeyPathContentOffset = @"contentOffset";
NSString *const RefreshKeyPathContentInset = @"contentInset";
NSString *const RefreshKeyPathContentSize = @"contentSize";
NSString *const RefreshKeyPathPanState = @"state";


NSString *const RefreshHeaderLastUpdatedTimeKey = @"MJRefreshHeaderLastUpdatedTimeKey";

NSString *const RefreshHeaderIdleText = @"下拉可以刷新";
NSString *const RefreshHeaderPullingText = @"松开立即刷新";
NSString *const RefreshHeaderRefreshingText = @"正在刷新数据中...";

NSString *const RefreshAutoFooterIdleText = @"点击或上拉加载更多";
NSString *const RefreshAutoFooterRefreshingText = @"正在加载更多的数据...";
NSString *const RefreshAutoFooterNoMoreDataText = @"已经全部加载完毕";

NSString *const RefreshBackFooterIdleText = @"上拉可以加载更多";
NSString *const RefreshBackFooterPullingText = @"松开立即加载更多";
NSString *const RefreshBackFooterRefreshingText = @"正在加载更多的数据...";
NSString *const RefreshBackFooterNoMoreDataText = @"已经全部加载完毕";

