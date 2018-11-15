//
//  HQChatRefershControll.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/4/1.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface HQChatRefershControll : NSObject



- (void)beginRefreshing;

- (void)endRefreshing;

- (void)addToScrollView:(UIScrollView *)scrollView refreshBlock:(void (^)(void))refreshBlock;

@end
