//
//  NetworkingOperation.h
//  HQ_WeChat
//
//  Created by 黄麒展  QQ 757618403 on 2018/11/14.
//  Copyright © 2018年 8km. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "URLRequestSerialization.h"
#import "URLResponseSerialization.h"

typedef NS_ENUM(NSUInteger , NetworkingOperationStatus) {
    ///空状态
    NetworkingOperationNoneStatus = 0,
    ///加载状态
    NetworkingOperationLoadingStatus = 1,
    ///加载成功状态
    NetworkingOperationSuccessStatus = 2,
    ///失败状态
    NetworkingOperationFaildStatus = 3,
};

typedef void (^NetworkingOperationTextBlock)(NetworkingOperationStatus status,NSURLSessionTask *task,id result); 


NS_ASSUME_NONNULL_BEGIN


@interface NetworkingBaseOperation : NSObject

/**
 sesstionTask
 */
@property (nullable,nonatomic,strong) NSURLSessionTask *task;

/**
 responseResult
 */
@property (nullable,nonatomic,strong) id responseObject;
/**
 uploadProgress
 */
@property (nonatomic,strong) NSProgress *uploadProgress;

/**
 downloadProgress
 */
@property (nonatomic,strong) NSProgress *downLoadProgress;
/**
 请求状态
 */
@property (nonatomic,assign) NetworkingOperationStatus status;

- (NSUInteger )startChatTextRequestWith:(NetworkingOperationTextBlock)block;

@end




@interface NetworkingCahtTextOperation : NetworkingBaseOperation


@end

NS_ASSUME_NONNULL_END
