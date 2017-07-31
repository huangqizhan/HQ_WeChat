//
//  HQDownLoadFile.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/5/19.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * _Nonnull const HQDownLoadFileCache;

@class HQDownLoadTempModel;

typedef NS_ENUM(NSInteger,HQDownLoadFileStatus) {
    HQDownLoadFileStatusNone = 0,                /** default */
    HQDownLoadFileStatusWaiting = 1,             /** 等待 */
    HQDownLoadFileStatusLoading = 2,             /** 正在下载 */
    HQDownLoadFileStatusSuspend = 3,             /** 暂停 */
    HQDownLoadFileStatusComplite = 4,            /** 完成 */
    HQDownLoadFileStatusFaild = 5                /** 失败 */
};

typedef NS_ENUM(NSInteger,HQDownLoadPriorization) {
    HQDownLoadPriorizationFIFO,               /** 先进先出 */
    HQDownLoadPriorizationLIFO                /** 后进先出 */
};

////下载完成回调
typedef void (^HQDownLoadSuccessBlock)(NSURLRequest * _Nullable request,NSHTTPURLResponse * _Nullable response,NSURL * _Nullable url);

////下载失败回调
typedef void (^HQDownLoadFaildBlock)(NSURLRequest * _Nullable request,NSHTTPURLResponse * _Nullable response,NSError * _Nullable error);

/////下载进度回调
typedef void (^HQDownLoadProcessBlok)(NSProgress *_Nullable process,HQDownLoadTempModel *_Nullable receipt);

/////描述回调
//typedef  NSURL *_Nullable (^DestinationBlcok)(NSURL * _Nullable url , NSURLResponse * _Nullable *response);



//@interface HQDownLoadReceipt : NSObject <NSCoding>
//
//@property (nonatomic,copy,nullable) HQDownLoadSuccessBlock successBlock;
//@property (nonatomic,copy,nullable) HQDownLoadFaildBlock faildBlock;
//@property (nonatomic,copy,nullable) HQDownLoadProcessBlok processBlok;
//
//@end

typedef NSMutableDictionary<NSString *,NSURLSessionDataTask  *> HQDownLoadDictionary;

typedef NSMutableArray<NSURLSessionDataTask *> HQDownLoadTaskArray;

typedef NSMutableDictionary<NSString *,HQDownLoadTempModel *> HQDownLoadReceiptDictionary;


@protocol HQDownloadControlDelegate <NSObject>

////暂停某个下载任务
- (void)suspendWithURL:(NSString * _Nonnull)url;
- (void)suspendWithDownloadReceipt:(HQDownLoadTempModel * _Nonnull)receipt;


////删除某个下载任务
- (void)removeWithURL:(NSString * _Nonnull)url;
- (void)removeWithDownloadReceipt:(HQDownLoadTempModel * _Nonnull)receipt;

@end


@interface HQDownLoadFile : NSObject <HQDownloadControlDelegate>

////下载顺序
@property (nonatomic,assign) HQDownLoadPriorization priorization;

+ (nonnull instancetype)DefaultManager;


- (void)downLoadWithUrl:(nullable HQDownLoadTempModel *)model
                                       process:(_Nullable HQDownLoadProcessBlok)processBlock
                                       success:(_Nullable HQDownLoadSuccessBlock)successBlock
                                       failure:(_Nullable HQDownLoadFaildBlock)failureBlock;


////暂停某个下载任务
- (void)suspendWithURL:(NSString * _Nonnull)url;
- (void)suspendWithDownloadReceipt:(HQDownLoadTempModel * _Nonnull)receipt;


////删除某个下载任务
- (void)removeWithURL:(NSString * _Nonnull)url;
- (void)removeWithDownloadReceipt:(HQDownLoadTempModel * _Nonnull)receipt;


@end






