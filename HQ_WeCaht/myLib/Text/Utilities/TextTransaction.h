//
//  TextTransaction.h
//  YYStudyDemo
//
//  Created by hqz  QQ 757618403 on 2018/9/4.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//

#import <Foundation/Foundation.h>


/// 主线程添加的观察事务
@interface TextTransaction : NSObject

+ (TextTransaction *)transactionWithTarget:(id)target selector:(SEL)selector;

- (void)commit;

@end
