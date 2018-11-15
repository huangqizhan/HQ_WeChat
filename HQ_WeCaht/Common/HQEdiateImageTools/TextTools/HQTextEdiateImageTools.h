//
//  HQTextEdiateImageTools.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/25.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HQEdiateImageBaseTools.h"

@interface HQTextEdiateImageTools : HQEdiateImageBaseTools



/**
 底部栏删除时删除框的状态

 @param active bool
 */
- (void)setMenuViewDeleteStatusIsActive:(BOOL)active;


/**
 重置底部栏状态
 */
- (void)setMenuViewDefaultStatus;


@end
