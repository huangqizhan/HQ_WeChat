//
//  HQNetWorkManager.h
//  QueueTest
//
//  Created by 黄麒展 on 17/3/11.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <Foundation/Foundation.h>


#define HQWeak  __weak __typeof(self) weakSelf = self



/** 网络状态  枚举  */
typedef NS_ENUM(NSUInteger,HQNetWorkingStatus) {
    
    ///未知
    HQNetWorkingStatusUnKnow = 0,
    ///没有网络
    HQNetWorkingStatusNotReachable,
    ///手机网络
    HQNetWorkingStatusReachableViaWWAN,
    ///wifi
    HQNetWorkingStatusReachableViaWifi
};

/** 请求的类型   GET POST PUT DELETE  */
typedef NS_ENUM(NSUInteger,HQhTTPRequestType) {
    
    ///GET
    HQhTTPRequestTypeGET = 0,
    ///POST
    HQhTTPRequestTypePOST,
    ////PUT
    HQhTTPRequestTypePUT,
    ///DELETE
    HQhTTPRequestTypeDELETE
    
};
/*  检测网络状态的  Block  */
typedef void (^HQNetWorkingStatusBlock) (HQNetWorkingStatus status);

/*  请求成功回调  Block    */
typedef void (^HQRequestSuccessBlock) (id responseData);

/*  请求网络失败回调 Block  */
typedef void (^HQRequestFaildBlock) (NSError *error);
/*  上传进度回调 Block */
typedef void (^HQRequestProcessBlock) (NSProgress *process);
/*  下载进度回调 Block     */
typedef void (^HQDownloadProcessBlock) (NSProgress *process);


typedef NSURLSessionTask HQReqestSesstionTask;

@interface HQNetWorkManager : NSObject


/**
 networking 单例
 
 @return QueueManager
 */
+ (HQNetWorkManager *)shareQueueManagerInstance;

///请求状态
@property (nonatomic,assign)HQNetWorkingStatus netWorkStatus;


/*!
 *  网络请求方法,block回调
 *
 *  @param type         get / post
 *  @param urlString    请求的地址
 *  @param parameters    请求的参数
 *  @param successBlock 请求成功的回调
 *  @param failureBlock 请求失败的回调
 *  @param progress 进度
 */
+ (HQReqestSesstionTask *)requestWithType:(HQhTTPRequestType)type
              urlString:(NSString *)urlString
             parameters:(NSDictionary *)parameters
           successBlock:(HQRequestSuccessBlock)successBlock
           failureBlock:(HQRequestFaildBlock)failureBlock
               progress:(HQRequestProcessBlock)progress;
/*!
 *  上传图片(多图)
 *
 *  @param parameters   上传图片预留参数---视具体情况而定 可移除
 *  @param imageArray   上传的图片数组
 *  @param fileName     上传的图片数组fileName
 *  @param urlString    上传的url
 *  @param successBlock 上传成功的回调
 *  @param failureBlock 上传失败的回调
 *  @param progress     上传进度
 */
+ (HQReqestSesstionTask *)uploadImageWithUrlString:(NSString *)urlString
                                       parameters:(NSDictionary *)parameters
                                       imageArray:(NSArray *)imageArray
                                         fileName:(NSString *)fileName
                                     successBlock:(HQRequestSuccessBlock)successBlock
                                      failurBlock:(HQRequestFaildBlock)failureBlock
                                   upLoadProgress:(HQRequestProcessBlock)progress;


/**
 上传文件

 @param urlString URL
 @param parameters 参数
 @param filePath 文件路径
 @param fileName fileName
 @param successBlock 成功回调
 @param failureBlock 失败回调
 @param progress 进度
 @return 任务
 */
+ (HQReqestSesstionTask *)uploadFileWithUrlString:(NSString *)urlString
                                        parameters:(NSDictionary *)parameters
                                        filePath:(NSString *)filePath
                                          fileName:(NSString *)fileName
                                      successBlock:(HQRequestSuccessBlock)successBlock
                                       failurBlock:(HQRequestFaildBlock)failureBlock
                                    upLoadProgress:(HQRequestProcessBlock)progress;

/*!
 *  视频上传
 *
 *  @param parameters   上传视频预留参数---视具体情况而定 可移除
 *  @param videoPath    上传视频的本地沙河路径
 *  @param urlString     上传的url
 *  @param successBlock 成功的回调
 *  @param failureBlock 失败的回调
 *  @param progress     上传的进度
 */
+ (HQReqestSesstionTask *)ba_uploadVideoWithUrlString:(NSString *)urlString
                         parameters:(NSDictionary *)parameters
                          videoPath:(NSString *)videoPath
                       successBlock:(HQRequestSuccessBlock)successBlock
                       failureBlock:(HQRequestFaildBlock)failureBlock
                     uploadProgress:(HQRequestProcessBlock)progress;

/*!
 *  文件下载
 *
 *  @param parameters   文件下载预留参数---视具体情况而定 可移除
 *  @param savePath     下载文件保存路径
 *  @param urlString        请求的url
 *  @param successBlock 下载文件成功的回调
 *  @param failureBlock 下载文件失败的回调
 *  @param progress     下载文件的进度显示
 */
+ (HQReqestSesstionTask *)ba_downLoadFileWithUrlString:(NSString *)urlString
                                        parameters:(NSDictionary *)parameters
                                          savaPath:(NSString *)savePath
                                      successBlock:(HQRequestSuccessBlock)successBlock
                                      failureBlock:(HQRequestFaildBlock)failureBlock
                                  downLoadProgress:(HQDownloadProcessBlock)progress;


/*!
 *  开启网络监测
 */
+ (void)startNetWorkMonitoringWithBlock:(HQNetWorkingStatusBlock)networkStatus;


/**
 检测是否有望

 @return bool
 */
+ (BOOL)isHaveNetwork;

/*!
 *  是否是手机网络
 *
 *  @return YES, 反之:NO
 */
+ (BOOL)is3GOr4GNetwork;


/*!
 *  是否是 WiFi 网络
 *
 *  @return YES, 反之:NO
 */
+ (BOOL)isWiFiNetwork;

/*!
 *  取消所有 Http 请求
 */
+ (void)cancelAllRequest;

/*!
 *  取消指定的 Http 请求
 */
+ (void)cancelRequestWithURL:(NSString *)currentTimeral;
@end









@interface NSURLSessionTask (AddProperty)

@property (nonatomic,copy) NSString *requestTimeal;

@end



