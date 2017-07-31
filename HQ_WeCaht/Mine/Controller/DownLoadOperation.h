//
//  DownLoadOperation.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/5/17.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownLoadTest.h"

extern NSString *_Nonnull const DownLoadStartNotification;
extern NSString *_Nonnull const DownLoadReceiveResponseDataNotification;
extern NSString *_Nonnull const DownLoadStopNotification;
extern NSString *_Nonnull const DownLoadFinisnNotification;


@protocol DownLoadOperationOperationInterface <NSObject>

- (nonnull instancetype)initWithRequest:(nullable NSURLRequest *)request
                              inSession:(nullable NSURLSession *)session
                                options:(DownLoadOptions)options;

- (nullable id)addHandlersForProgress:(nullable ProgressBlock)progressBlock
                            completed:(nullable CompletedBlock)completedBlock;

- (BOOL)shouldDecompressImages;
- (void)setShouldDecompressImages:(BOOL)value;

- (nullable NSURLCredential *)credential;
- (void)setCredential:(nullable NSURLCredential *)value;


@end


@interface DownLoadOperation : NSOperation<DownLoadOperationOperationInterface,NSURLSessionDataDelegate,NSURLSessionTaskDelegate>

@property (nonatomic,assign) DownLoadOptions options;

@property (strong, nonatomic, readonly, nullable) NSURLRequest *request;

@property (strong, nonatomic, readonly, nullable) NSURLSessionTask *dataTask;

@property (assign, nonatomic) BOOL shouldDecompressImages;

////总长度
@property (assign, nonatomic) NSInteger expectedSize;

@property (strong, nonatomic, nullable) NSURLResponse *response;


- (nonnull instancetype)initWithRequest:(nullable NSURLRequest *)request
                              inSession:(nullable NSURLSession *)session
                                options:(DownLoadOptions)options NS_DESIGNATED_INITIALIZER;

- (nullable id)addHandlersForProgress:(nullable ProgressBlock)progressBlock
                            completed:(nullable CompletedBlock)completedBlock;

////当前操作是否取消
- (BOOL)cancel:(nullable id)token;

@end
