//
//  HQRefershHeaderView.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/25.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQRefershBaseControll.h"

@interface HQRefershHeaderView : HQRefershBaseControll


+ (instancetype)headerWithRefreshingBlock:(RefreshControllRefreshingBlock)refreshingBlock;

///// 这个key用来存储上一次下拉刷新成功的时间
//@property (copy, nonatomic) NSString *lastUpdatedTimeKey;
///// 上一次下拉刷新成功的时间
//@property (strong, nonatomic, readonly) NSDate *lastUpdatedTime;

///忽略多少scrollView的contentInset的top
@property (assign, nonatomic) CGFloat ignoredScrollViewContentInsetTop;

////结束刷新回调
- (void)endRefreshingWithCallBack:(void (^)())callBack;


@end
