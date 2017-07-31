//
//  HQNetWorkManager.m
//  QueueTest
//
//  Created by 黄麒展 on 17/3/11.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQNetWorkManager.h"
#import <objc/runtime.h>
#import "AFNetworkActivityIndicatorManager.h"
#import "AFNetworking.h"


#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetExportSession.h>
#import <AVFoundation/AVMediaFormat.h>


/*! 系统相册 */
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetsGroup.h>
#import <AssetsLibrary/ALAssetRepresentation.h>

#import "UIImage+CompressImage.h"




/*  请求tasks  */
static NSMutableArray *requestTasks;

@implementation HQNetWorkManager


+ (HQNetWorkManager *)shareQueueManagerInstance{
    static HQNetWorkManager  *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HQNetWorkManager alloc] init];
    });
    return manager;
}



+ (AFHTTPSessionManager *)shareAfHttpSessionManager{
    static AFHTTPSessionManager *sesstionManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sesstionManager = [AFHTTPSessionManager manager];
        ///设置超时时间
        sesstionManager.requestSerializer.timeoutInterval = 30;
        ///请求菊花状态
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        /*! 设置相应的缓存策略：此处选择不用加载也可以使用自动缓存【注：只有get方法才能用此缓存策略，NSURLRequestReturnCacheDataDontLoad】 */
        sesstionManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        /*! 设置返回数据类型为 json, 分别设置请求以及相应的序列化器 */
        /*!
         根据服务器的设定不同还可以设置：
         json：[AFJSONResponseSerializer serializer](常用)
         http：[AFHTTPResponseSerializer serializer]
         */
        AFJSONResponseSerializer *response = [AFJSONResponseSerializer serializer];
        /*! 这里是去掉了键值对里空对象的键值 */
        response.removesKeysWithNullValues = YES;
        sesstionManager.responseSerializer = response;
        /* 设置请求服务器数类型式为 json */
        /*!
         根据服务器的设定不同还可以设置：
         json：[AFJSONRequestSerializer serializer](常用)
         http：[AFHTTPRequestSerializer serializer]
         */
        AFJSONRequestSerializer *request = [AFJSONRequestSerializer serializer];
        sesstionManager.requestSerializer = request;
        
        /*! 设置apikey ------类似于自己应用中的tokken---此处仅仅作为测试使用*/
        //        [manager.requestSerializer setValue:apikey forHTTPHeaderField:@"apikey"];
        
        /*! 复杂的参数类型 需要使用json传值-设置请求内容的类型*/
        //        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        /*! 设置响应数据的基本类型 */
        sesstionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/css",@"text/xml",@"text/plain", @"application/javascript", @"image/*", nil];
        /*
         
        https 参数配置
         采用默认的defaultPolicy就可以了. AFN默认的securityPolicy就是它, 不必另写代码. AFSecurityPolicy类中会调用苹果security.framework的机制去自行验证本次请求服务端放回的证书是否是经过正规签名.
         
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
        securityPolicy.allowInvalidCertificates = YES;
        securityPolicy.validatesDomainName = NO;
        manager.securityPolicy = securityPolicy;
        
         自定义的CA证书配置如下：
         自定义security policy, 先前确保你的自定义CA证书已放入工程Bundle
        
         https://api.github.com网址的证书实际上是正规CADigiCert签发的, 这里把Charles的CA根证书导入系统并设为信任后, 把Charles设为该网址的SSL Proxy (相当于"中间人"), 这样通过代理访问服务器返回将是由Charles伪CA签发的证书.
         
        //        NSSet <NSData *> *cerSet = [AFSecurityPolicy certificatesInBundle:[NSBundle mainBundle]];
        //        AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:cerSet];
        //        policy.allowInvalidCertificates = YES;
        //        manager.securityPolicy = policy;
        
         如果服务端使用的是正规CA签发的证书, 那么以下几行就可去掉:
        //        NSSet <NSData *> *cerSet = [AFSecurityPolicy certificatesInBundle:[NSBundle mainBundle]];
        //        AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:cerSet];
        //        policy.allowInvalidCertificates = YES;
        //        manager.securityPolicy = policy;

         */
    });
    return sesstionManager;
}
+ (NSMutableArray *)requestTasks{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        requestTasks = [[NSMutableArray alloc] init];
    });
    return requestTasks;
}

+ (HQReqestSesstionTask *)requestWithType:(HQhTTPRequestType)type
              urlString:(NSString *)urlString
             parameters:(NSDictionary *)parameters
           successBlock:(HQRequestSuccessBlock)successBlock
           failureBlock:(HQRequestFaildBlock)failureBlock
               progress:(HQRequestProcessBlock)progress{
    if (urlString == nil){
        return  nil;
    }
    /*! 检查地址中是否有中文 */
    NSString *URLString = [NSURL URLWithString:urlString] ? urlString : [self strUTF8Encoding:urlString];
    NSString *requestType;
    HQReqestSesstionTask *task;
    switch (type) {
        case HQhTTPRequestTypeGET:
            requestType = @"Get";
            task = [self GetWithUrlString:urlString parmars:parameters progress:progress successBlock:successBlock failureBlock:failureBlock];
            break;
        case HQhTTPRequestTypePOST:
            requestType = @"Post";
            task = [self PostWithUrlString:urlString parmars:parameters progress:progress successBlock:successBlock failureBlock:failureBlock];
            break;
        case HQhTTPRequestTypePUT:
            requestType = @"Put";
            task = [self PutWirhUrlString:urlString parmars:parameters successBlock:successBlock failureBlock:failureBlock];
            break;
        case HQhTTPRequestTypeDELETE:
            requestType = @"Delete";
           task = [self DeleteWithUrlString:urlString parmars:parameters successBlock:successBlock failureBlock:failureBlock];
            break;
        default:
            break;
    }
    NSLog(@"******************** 请求参数 ***************************");
    NSLog(@"请求头: %@\n请求方式: %@\n请求URL: %@\n请求param: %@\n\n",[self shareAfHttpSessionManager].requestSerializer.HTTPRequestHeaders, requestType, URLString, parameters);
    NSLog(@"********************************************************");
    return task;
}


#pragma --------POST ------
+ (HQReqestSesstionTask *)PostWithUrlString:(NSString *)urlString
                  parmars:(NSDictionary *)parmars
                 progress:(HQRequestProcessBlock)progress
             successBlock:(HQRequestSuccessBlock)successBlock
             failureBlock:(HQRequestFaildBlock)failureBlock{
    HQWeak;
    HQReqestSesstionTask *task = (HQReqestSesstionTask *)[[self shareAfHttpSessionManager] POST:urlString parameters:parmars progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (task) {
            [[weakSelf requestTasks] removeObject:task];
        }
        successBlock(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (task) {
            [[weakSelf requestTasks] removeObject:task];
        }
        failureBlock(error);
    }];
    if (task) {
        [[weakSelf requestTasks] addObject:task];
    }
    return task;
}
#pragma --------GET ----------------
+ (HQReqestSesstionTask *)GetWithUrlString:(NSString *)urlString
                 parmars:(NSDictionary *)parmars
                progress:(HQRequestProcessBlock)progress
            successBlock:(HQRequestSuccessBlock)successBlock
            failureBlock:(HQRequestFaildBlock)failureBlock{
    HQWeak;
     HQReqestSesstionTask *task = (HQReqestSesstionTask *)[[self shareAfHttpSessionManager] GET:urlString parameters:parmars progress:^(NSProgress * _Nonnull downloadProgress) {
         progress(downloadProgress);
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         if (task) {
             [[weakSelf requestTasks] removeObject:task];
         }
         successBlock(responseObject);
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         if (task) {
             [[weakSelf requestTasks] removeObject:task];
         }
         failureBlock(error);
     }];
    if (task) {
        [[weakSelf requestTasks] addObject:task];
    }
    return task;
}
#pragma --------Delete----------------
+ (HQReqestSesstionTask *)DeleteWithUrlString:(NSString *)urlString
                    parmars:(NSDictionary *)parmars
               successBlock:(HQRequestSuccessBlock)successBlock
               failureBlock:(HQRequestFaildBlock)failureBlock{
    HQWeak;
   HQReqestSesstionTask *task = [[self shareAfHttpSessionManager] DELETE:urlString parameters:parmars success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (task) {
            [[self requestTasks] addObject:task];
        }
        successBlock(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (task) {
            [[weakSelf requestTasks] addObject:task];
        }
        failureBlock(error);
    }];
    if (task) {
        [[weakSelf requestTasks] addObject:task];
    }
    return task;
}
#pragma --------PUT -----------------

+ (HQReqestSesstionTask *)PutWirhUrlString:(NSString *)urlString
                 parmars:(NSDictionary *)parmars
            successBlock:(HQRequestSuccessBlock)successBlock
            failureBlock:(HQRequestFaildBlock)failureBlock{
    HQWeak;
    HQReqestSesstionTask *task = [[self shareAfHttpSessionManager] PUT:urlString parameters:parmars success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (task) {
            [[weakSelf requestTasks] addObject:task];
        }
        successBlock(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (task) {
            [[weakSelf requestTasks] addObject:task];
        }
        failureBlock(error);
    }];
    if (task) {
        [[weakSelf requestTasks] addObject:task];
    }
    return task;
}

+ (HQReqestSesstionTask *)uploadImageWithUrlString:(NSString *)urlString
                                        parameters:(NSDictionary *)parameters
                                        imageArray:(NSArray *)imageArray
                                          fileName:(NSString *)fileName
                                      successBlock:(HQRequestSuccessBlock)successBlock
                                       failurBlock:(HQRequestFaildBlock)failureBlock
                                    upLoadProgress:(HQRequestProcessBlock)progress{
    if (urlString == nil){
        return nil;
    }
    HQWeak;
    /*! 检查地址中是否有中文 */
    NSString *URLString = [NSURL URLWithString:urlString] ? urlString : [self strUTF8Encoding:urlString];
    
    NSLog(@"******************** 请求参数 ***************************");
    NSLog(@"请求头: %@\n请求方式: %@\n请求URL: %@\n请求param: %@\n\n",[self shareAfHttpSessionManager].requestSerializer.HTTPRequestHeaders, @"POST",URLString, parameters);
    NSLog(@"******************************************************");
    
    HQReqestSesstionTask *task = [[self shareAfHttpSessionManager] POST:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        /*! 出于性能考虑,将上传图片进行压缩 */
        [imageArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            /*! image的压缩方法 */
            UIImage *resizedImage;
            /*! 此处是使用原生系统相册 */
            if([obj isKindOfClass:[ALAsset class]]){
                // 用ALAsset获取Asset URL  转化为image
                ALAssetRepresentation *assetRep = [obj defaultRepresentation];
                
                CGImageRef imgRef = [assetRep fullResolutionImage];
                resizedImage = [UIImage imageWithCGImage:imgRef
                                                   scale:1.0
                                             orientation:(UIImageOrientation)assetRep.orientation];
                resizedImage = [weakSelf imageWithImage:resizedImage scaledToSize:resizedImage.size];
            }
            else{
                /*! 此处是使用其他第三方相册，可以自由定制压缩方法 */
                resizedImage = obj;
            }
            /*! 此处压缩方法是jpeg格式是原图大小的0.8倍，要调整大小的话，就在这里调整就行了还是原图等比压缩 */
            NSData *imgData = UIImageJPEGRepresentation(resizedImage, 0.8);
            /*! 拼接data */
            if (imgData != nil){
                // 图片数据不为空才传递 fileName
                //                [formData appendPartWithFileData:imgData name:[NSString stringWithFormat:@"picflie%ld",(long)i] fileName:@"image.png" mimeType:@" image/jpeg"];
                [formData appendPartWithFileData:imgData
                                            name:[NSString stringWithFormat:@"picflie%ld",(long)idx]
                                        fileName:fileName
                                        mimeType:@"image/jpeg"];
                
            }
            
        }];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        progress(uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (task) {
            [[weakSelf requestTasks] removeObject:task];
        }
        successBlock(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (task) {
            [[weakSelf requestTasks] removeObject:task];
        }
        failureBlock(error);
    }];
    if (task) {
        [[self requestTasks] addObject:task];
    }
    return task;
}
+ (HQReqestSesstionTask *)uploadFileWithUrlString:(NSString *)urlString
                                       parameters:(NSDictionary *)parameters
                                         filePath:(NSString *)filePath
                                         fileName:(NSString *)fileName
                                     successBlock:(HQRequestSuccessBlock)successBlock
                                      failurBlock:(HQRequestFaildBlock)failureBlock
                                   upLoadProgress:(HQRequestProcessBlock)progress{
    if (urlString == nil){
        return nil;
    }
    HQWeak;
    /*! 检查地址中是否有中文 */
    NSString *URLString = [NSURL URLWithString:urlString] ? urlString : [self strUTF8Encoding:urlString];
    
    NSLog(@"******************** 请求参数 ***************************");
    NSLog(@"请求头: %@\n请求方式: %@\n请求URL: %@\n请求param: %@\n\n",[self shareAfHttpSessionManager].requestSerializer.HTTPRequestHeaders, @"POST",URLString, parameters);
    NSLog(@"******************************************************");
    
    HQReqestSesstionTask *task = [[self shareAfHttpSessionManager] POST:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        if (data) {
            [formData appendPartWithFileData:data
                                        name:filePath.lastPathComponent
                                    fileName:filePath.lastPathComponent
                                    mimeType:@"voice"];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        progress(uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (task) {
            [[weakSelf requestTasks] removeObject:task];
        }
        successBlock(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (task) {
            [[weakSelf requestTasks] removeObject:task];
        }
        failureBlock(error);
    }];
    if (task) {
        [[self requestTasks] addObject:task];
    }
    return task;
}
+ (HQReqestSesstionTask *)ba_uploadVideoWithUrlString:(NSString *)urlString
                         parameters:(NSDictionary *)parameters
                          videoPath:(NSString *)videoPath
                       successBlock:(HQRequestSuccessBlock)successBlock
                       failureBlock:(HQRequestFaildBlock)failureBlock
                     uploadProgress:(HQRequestProcessBlock)progress{
    /*! 获得视频资源 */
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:videoPath]  options:nil];
    
    /*! 压缩 */
    
    //    NSString *const AVAssetExportPreset640x480;
    //    NSString *const AVAssetExportPreset960x540;
    //    NSString *const AVAssetExportPreset1280x720;
    //    NSString *const AVAssetExportPreset1920x1080;
    //    NSString *const AVAssetExportPreset3840x2160;
    
    HQReqestSesstionTask *task;
   __block  typeof (task) weekTask = task;
    /*! 创建日期格式化器 */
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
    
    /*! 转化后直接写入Library---caches */
    NSString *videoWritePath = [NSString stringWithFormat:@"output-%@.mp4",[formatter stringFromDate:[NSDate date]]];
    NSString *outfilePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", videoWritePath];
    
    AVAssetExportSession *avAssetExport = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
    avAssetExport.outputURL = [NSURL fileURLWithPath:outfilePath];
    avAssetExport.outputFileType =  AVFileTypeMPEG4;
    [avAssetExport exportAsynchronouslyWithCompletionHandler:^{
        if (avAssetExport.status == AVAssetExportSessionStatusCompleted) {
           weekTask = [[self shareAfHttpSessionManager] POST:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                
                NSURL *filePathURL2 = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@", outfilePath]];
                // 获得沙盒中的视频内容
                [formData appendPartWithFileURL:filePathURL2 name:@"video" fileName:outfilePath mimeType:@"application/octet-stream" error:nil];
                
            } progress:^(NSProgress * _Nonnull uploadProgress) {
                if (progress){
                    progress(uploadProgress);
                }
            } success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable responseObject) {
                if (task) {
                    [[self requestTasks] removeObject:task];
                }
                if (successBlock){
                    successBlock(responseObject);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (task) {
                    [[self requestTasks] removeObject:task];
                }
                if (failureBlock){
                    failureBlock(error);
                }
            }];
            [[self requestTasks] addObject:task];
        }
    }];
    return weekTask;
}
+ (HQReqestSesstionTask *)ba_downLoadFileWithUrlString:(NSString *)urlString
                                            parameters:(NSDictionary *)parameters
                                              savaPath:(NSString *)savePath
                                          successBlock:(HQRequestSuccessBlock)successBlock
                                          failureBlock:(HQRequestFaildBlock)failureBlock
                                      downLoadProgress:(HQDownloadProcessBlock)progress{
    if (urlString == nil){
        return nil;
    }
    NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    NSLog(@"******************** 请求参数 ***************************");
    NSLog(@"请求头: %@\n请求方式: %@\n请求URL: %@\n请求param: %@\n\n",[self shareAfHttpSessionManager].requestSerializer.HTTPRequestHeaders, @"download",urlString, parameters);
    NSLog(@"******************************************************");
    
    
    HQReqestSesstionTask *sessionTask = nil;
    
    sessionTask = [[self shareAfHttpSessionManager] downloadTaskWithRequest:downloadRequest progress:^(NSProgress * _Nonnull downloadProgress) {
        
        NSLog(@"下载进度：%.2lld%%",100 * downloadProgress.completedUnitCount/downloadProgress.totalUnitCount);
        /*! 回到主线程刷新UI */
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progress){
                progress(downloadProgress);
            }
            
        });
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        if (!savePath){
            NSURL *downloadURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
            NSLog(@"默认路径--%@",downloadURL);
            return [downloadURL URLByAppendingPathComponent:[response suggestedFilename]];
        }else{
            return [NSURL fileURLWithPath:savePath];
        }
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        [[self requestTasks] removeObject:sessionTask];
        if (error == nil){
            if (successBlock){
                /*! 返回完整路径 */
                successBlock([filePath path]);
            }else{
                if (failureBlock){
                    failureBlock(error);
                }
            }
        }
    }];
    /*! 开始启动任务 */
    [sessionTask resume];
    if (sessionTask){
        [[self requestTasks] addObject:sessionTask];
    }
    return sessionTask;
}

/*!
 *  开启网络监测
 */
+ (void)startNetWorkMonitoringWithBlock:(HQNetWorkingStatusBlock)networkStatus{
    /*! 1.获得网络监控的管理者 */
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    /*! 当使用AF发送网络请求时,只要有网络操作,那么在状态栏(电池条)wifi符号旁边显示  菊花提示 */
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    /*! 2.设置网络状态改变后的处理 */
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        /*! 当网络状态改变了, 就会调用这个block */
        switch (status){
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未知网络");
                networkStatus ? networkStatus(HQNetWorkingStatusUnKnow) : nil;
                [HQNetWorkManager shareQueueManagerInstance].netWorkStatus = HQNetWorkingStatusUnKnow;
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"没有网络");
                networkStatus ? networkStatus(HQNetWorkingStatusNotReachable) : nil;
                [HQNetWorkManager shareQueueManagerInstance].netWorkStatus = HQNetWorkingStatusNotReachable;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"手机自带网络");
                networkStatus ? networkStatus(HQNetWorkingStatusReachableViaWWAN) : nil;
                [HQNetWorkManager shareQueueManagerInstance].netWorkStatus = HQNetWorkingStatusReachableViaWWAN;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"wifi 网络");
                networkStatus ? networkStatus(HQNetWorkingStatusReachableViaWifi) : nil;
                [HQNetWorkManager shareQueueManagerInstance].netWorkStatus = HQNetWorkingStatusReachableViaWifi;
                break;
        }
    }];
    [manager startMonitoring];
}
+ (BOOL)isHaveNetwork{
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

/*!
 *  是否是手机网络
 *
 *  @return YES, 反之:NO
 */
+ (BOOL)is3GOr4GNetwork{
    return [AFNetworkReachabilityManager sharedManager].reachableViaWWAN;
}

/*!
 *  是否是 WiFi 网络
 *
 *  @return YES, 反之:NO
 */
+ (BOOL)isWiFiNetwork{
    return [AFNetworkReachabilityManager sharedManager].reachableViaWiFi;
}

#pragma mark - 取消 Http 请求
/*!
 *  取消所有 Http 请求
 */
+ (void)cancelAllRequest{
    // 锁操作
    @synchronized(self){
        [[self requestTasks] enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            [task cancel];
        }];
        [[self requestTasks] removeAllObjects];
    }
}
/*!
 *  取消指定的 Http 请求
 */
+ (void)cancelRequestWithURL:(NSString *)currentTimeral{
    if (!currentTimeral){
        return;
    }
    @synchronized (self){
        [[self requestTasks] enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([task.requestTimeal isEqualToString:currentTimeral]){
                [task cancel];
                [[self requestTasks] removeObject:task];
                *stop = YES;
            }
        }];
    }
}


#pragma mark - 压缩图片尺寸
/*! 对图片尺寸进行压缩 */
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize{
    if (newSize.height > 375/newSize.width*newSize.height){
        newSize.height = 375/newSize.width*newSize.height;
    }
    if (newSize.width > 375){
        newSize.width = 375;
    }
    UIImage *newImage = [UIImage needCenterImage:image size:newSize scale:1.0];
    
    return newImage;
}


#pragma mark - url 中文格式化
+ (NSString *)strUTF8Encoding:(NSString *)str{
    /*! ios9适配的话 打开第一个 */
    if ([[UIDevice currentDevice] systemVersion].floatValue >= 9.0){
        return [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
    }
    else{
        return [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet  URLQueryAllowedCharacterSet]];
    }
}

/*
 ////写本地文件  
 NSString *path = [NSString stringWithFormat:@"%ld.plist", [URLString hash]];
 // 存储的沙盒路径
 NSString *path_doc = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
 // 归档
 [NSKeyedArchiver archiveRootObject:responseObject toFile:[path_doc stringByAppendingPathComponent:path]];
 */
@end




@implementation  NSURLSessionTask (AddProperty)

- (void)setRequestTimeal:(NSString *)requestTimeal{
    objc_setAssociatedObject(self, @selector(requestTimeal), requestTimeal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)requestTimeal{
    return objc_getAssociatedObject(self, _cmd);
}
@end






