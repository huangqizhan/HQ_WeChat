//
//  DownLoadTest.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/5/17.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 1.NSURLRequestUseProtocolCachePolicy NSURLRequest                  默认的cache policy，使用Protocol协议定义。
 2.NSURLRequestReloadIgnoringCacheData                                        忽略缓存直接从原始地址下载。
 3.NSURLRequestReturnCacheDataDontLoad                                     只使用cache数据，如果不存在cache，请求失败；用于没有建立网络连接离线模式
 4.NSURLRequestReturnCacheDataElseLoad                                     只有在cache中不存在data时才从原始地址下载。
 5.NSURLRequestReloadIgnoringLocalAndRemoteCacheData           忽略本地和远程的缓存数据，直接从原始地址下载，与NSURLRequestReloadIgnoringCacheData类似。
 6.NSURLRequestReloadRevalidatingCacheData                              :验证本地数据与远程数据是否相同，如果不同则下载远程数据，否则使用本地数据
 */
@interface DownloadToken : NSObject

@property (nonatomic, strong, nullable) NSURL *url;
@property (nonatomic, strong, nullable) id downloadOperationCancelToken;

@end



typedef NS_ENUM(NSInteger,DownLoadOptions) {
    
    DownLoadOptionsNone,
    
    DownLoadOptionsTemp
};
typedef NS_ENUM(NSInteger,DownLoadExcuteOrder) {
    ////先进先出
    DownLoadOrderFIFOExecutionOrder,
    ////先进后出
    downloadOrderIFOExecutionOrder,
};

typedef void(^ProgressBlock)(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL);


typedef void(^CompletedBlock)(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished);

typedef NSDictionary<NSString *, NSString *> HTTPHeadersDictionary;

typedef NSMutableDictionary<NSString *, NSString *> HTTPHeadersMutableDictionary;


typedef HTTPHeadersMutableDictionary * _Nullable (^WebImageDownloaderHeadersFilterBlock)(NSURL * _Nullable url, HTTPHeadersDictionary * _Nullable headers);

@interface DownLoadTest : NSObject


@property (nonatomic,copy,nullable) NSString *passWord;

@property (nonatomic,copy,nullable) NSString *userName;

//// 网络请求的凭证
@property (strong, nonatomic, nullable) NSURLCredential *urlCredential;


@property (nonatomic,assign) DownLoadOptions options;

////下载顺序
@property (nonatomic,assign) DownLoadExcuteOrder loadOrder;


@property (readonly, nonatomic) NSUInteger currentDownloadCount;


///请求头block
@property (nonatomic,copy,nullable) WebImageDownloaderHeadersFilterBlock httpFilterBlock;

+ (nullable instancetype)shareDownLoadManager;

- (nonnull instancetype)initWithSessionConfiguration:(nullable NSURLSessionConfiguration *)sessionConfiguration NS_DESIGNATED_INITIALIZER;

- (nullable DownloadToken *)downloadWithUrl:(nullable NSURL *)url andOptions:(DownLoadOptions)options andProcess:(nullable ProgressBlock) process andComplite:(nullable CompletedBlock)complite;

////设置请求头
- (void)setValue:(nullable NSString *)value forHTTPHeaderField:(nullable NSString *)field;
///获取请求头信息
- (nullable NSString *)valueForHTTPHeaderField:(nullable NSString *)field;

////扩展使用
- (void)setOperationClass:(nullable Class)operationClass;

////取消其中一个下载
- (void)cancel:(nullable DownloadToken *)token;

/////停止下载队列
- (void)setSuspended:(BOOL)suspended;

/////取消所有下载

- (void)cancelAllDownloads;

@end



