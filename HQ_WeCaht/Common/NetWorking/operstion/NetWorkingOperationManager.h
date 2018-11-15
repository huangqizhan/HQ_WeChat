//
//  NetWorkingOperationManager.h
//  HQ_WeChat
//
//  Created by 黄麒展  QQ 757618403 on 2018/11/14.
//  Copyright © 2018年 8km. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkingOperation.h"


typedef void (^ChatTetxOpeationComplitionBlock) (NetworkingOperationStatus status,id responseObject);

NS_ASSUME_NONNULL_BEGIN

@interface NetWorkingOperationManager : NSObject

/**
 operations
 */
@property (readonly,nonatomic,strong) NSMutableDictionary *operationsDictionary;

+ (instancetype)shareManager;


+ (void)addChatTextOperation:(NetworkingBaseOperation *)operation complition:(ChatTetxOpeationComplitionBlock)complition;

@end

NS_ASSUME_NONNULL_END
