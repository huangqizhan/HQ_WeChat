//
//  HQBaseOperation.h
//  LunchOPeration
//
//  Created by hjb_mac_mini on 2018/10/15.
//  Copyright © 2018年 8km. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSString * HQOperationQueueType;

///串行
extern HQOperationQueueType const HQOperationQueueSerialQueueType;
///并行
extern HQOperationQueueType const HQOperationQueueConcurrentType;

NS_ASSUME_NONNULL_BEGIN
 @interface HQBaseOperation : NSOperation 

@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;

///操作完成
- (void)done;


@end

NS_ASSUME_NONNULL_END
