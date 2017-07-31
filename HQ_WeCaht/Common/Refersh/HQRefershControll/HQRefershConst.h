//
//  HQRefershConst.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/25.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/message.h>



UIKIT_EXTERN const CGFloat RefershHeight;
UIKIT_EXTERN const CGFloat RefreshFastAnimationDuration;
UIKIT_EXTERN const CGFloat RefreshSlowAnimationDuration;

UIKIT_EXTERN NSString *const RefreshKeyPathContentOffset;
UIKIT_EXTERN NSString *const RefreshKeyPathContentInset;
UIKIT_EXTERN NSString *const RefreshKeyPathContentSize;
UIKIT_EXTERN NSString *const RefreshKeyPathPanState;



UIKIT_EXTERN NSString *const RefreshHeaderLastUpdatedTimeKey;

UIKIT_EXTERN NSString *const RefreshHeaderIdleText;
UIKIT_EXTERN NSString *const RefreshHeaderPullingText;
UIKIT_EXTERN NSString *const RefreshHeaderRefreshingText;

UIKIT_EXTERN NSString *const RefreshAutoFooterIdleText;
UIKIT_EXTERN NSString *const RefreshAutoFooterRefreshingText;
UIKIT_EXTERN NSString *const RefreshAutoFooterNoMoreDataText;

UIKIT_EXTERN NSString *const RefreshBackFooterIdleText;
UIKIT_EXTERN NSString *const RefreshBackFooterPullingText;
UIKIT_EXTERN NSString *const RefreshBackFooterRefreshingText;
UIKIT_EXTERN NSString *const RefreshBackFooterNoMoreDataText;





#define HQRefreshControllCheckState \
HQRefreshControllState oldState = self.state; \
if (state == oldState) return; \
[super setState:state];


