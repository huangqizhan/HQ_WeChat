//
//  WebImageManager.h
//  YYStudyDemo
//
//  Created by 黄麒展 on 2018/7/8.
//  Copyright © 2018年 hqz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebImageCache.h"


@class WebImageOperation;

/// The options to control image operation.
typedef NS_OPTIONS(NSUInteger, YYWebImageOptions) {
    
    /// Show network activity on status bar when download image.
    YYWebImageOptionShowNetworkActivity = 1 << 0,
    
    /// Display progressive/interlaced/baseline image during download (same as web browser).
    YYWebImageOptionProgressive = 1 << 1,
    
    /// Display blurred progressive JPEG or interlaced PNG image during download.
    /// This will ignore baseline image for better user experience.
    YYWebImageOptionProgressiveBlur = 1 << 2,
    
    /// Use NSURLCache instead of YYImageCache.
    YYWebImageOptionUseNSURLCache = 1 << 3,
    
    /// Allows untrusted SSL ceriticates.
    YYWebImageOptionAllowInvalidSSLCertificates = 1 << 4,
    
    /// Allows background task to download image when app is in background.
    YYWebImageOptionAllowBackgroundTask = 1 << 5,
    
    /// Handles cookies stored in NSHTTPCookieStore.
    YYWebImageOptionHandleCookies = 1 << 6,
    
    /// Load the image from remote and refresh the image cache.
    YYWebImageOptionRefreshImageCache = 1 << 7,
    
    /// Do not load image from/to disk cache.
    YYWebImageOptionIgnoreDiskCache = 1 << 8,
    
    /// Do not change the view's image before set a new URL to it.
    YYWebImageOptionIgnorePlaceHolder = 1 << 9,
    
    /// Ignore image decoding.
    /// This may used for image downloading without display.
    YYWebImageOptionIgnoreImageDecoding = 1 << 10,
    
    /// Ignore multi-frame image decoding.
    /// This will handle the GIF/APNG/WebP/ICO image as single frame image.
    YYWebImageOptionIgnoreAnimatedImage = 1 << 11,
    
    /// Set the image to view with a fade animation.
    /// This will add a "fade" animation on image view's layer for better user experience.
    YYWebImageOptionSetImageWithFadeAnimation = 1 << 12,
    
    /// Do not set the image to the view when image fetch complete.
    /// You may set the image manually.
    YYWebImageOptionAvoidSetImage = 1 << 13,
    
    /// This flag will add the URL to a blacklist (in memory) when the URL fail to be downloaded,
    /// so the library won't keep trying.
    YYWebImageOptionIgnoreFailedURL = 1 << 14,
};
/// Indicated where the image came from.
typedef NS_ENUM(NSUInteger, YYWebImageFromType) {
    
    /// No value.
    YYWebImageFromNone = 0,
    
    /// Fetched from memory cache immediately.
    /// If you called "setImageWithURL:..." and the image is already in memory,
    /// then you will get this value at the same call.
    YYWebImageFromMemoryCacheFast,
    
    /// Fetched from memory cache.
    YYWebImageFromMemoryCache,
    
    /// Fetched from disk cache.
    YYWebImageFromDiskCache,
    
    /// Fetched from remote (web or file path).
    YYWebImageFromRemote,
};

/// Indicated image fetch complete stage.
typedef NS_ENUM(NSInteger, YYWebImageStage) {
    
    /// Incomplete, progressive image.
    YYWebImageStageProgress  = -1,
    
    /// Cancelled.
    YYWebImageStageCancelled = 0,
    
    /// Finished (succeed or failed).
    YYWebImageStageFinished  = 1,
};

/**
 The block invoked in remote image fetch progress.
 
 @param receivedSize Current received size in bytes.
 @param expectedSize Expected total size in bytes (-1 means unknown).
 */
typedef void(^YYWebImageProgressBlock)(NSInteger receivedSize, NSInteger expectedSize);

/**
 The block invoked before remote image fetch finished to do additional image process.
 
 @discussion This block will be invoked before `YYWebImageCompletionBlock` to give
 you a chance to do additional image process (such as resize or crop). If there's
 no need to transform the image, just return the `image` parameter.
 
 @example You can clip the image, blur it and add rounded corners with these code:
 ^(UIImage *image, NSURL *url) {
 // Maybe you need to create an @autoreleasepool to limit memory cost.
 image = [image yy_imageByResizeToSize:CGSizeMake(100, 100) contentMode:UIViewContentModeScaleAspectFill];
 image = [image yy_imageByBlurRadius:20 tintColor:nil tintMode:kCGBlendModeNormal saturation:1.2 maskImage:nil];
 image = [image yy_imageByRoundCornerRadius:5];
 return image;
 }
 
 @param image The image fetched from url.
 @param url   The image url (remote or local file path).
 @return The transformed image.
 */
typedef UIImage * _Nullable (^YYWebImageTransformBlock)(UIImage * _Nullable image, NSURL *url);

/**
 The block invoked when image fetch finished or cancelled.
 
 @param image       The image.
 @param url         The image url (remote or local file path).
 @param from        Where the image came from.
 @param stage       Current download stage.
 @param error       Error during image fetching.
 */
typedef void (^YYWebImageCompletionBlock)(UIImage * _Nullable image,
                                          NSURL * _Nullable url,
                                          YYWebImageFromType from,
                                          YYWebImageStage stage,
                                          NSError * _Nullable error);

NS_ASSUME_NONNULL_BEGIN
@interface WebImageManager : NSObject


- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

/**
 Returns global YYWebImageManager instance.
 
 @return YYWebImageManager shared instance.
 */
+ (instancetype _Nullable )sharedManager;
/**
 Creates a manager with an image cache and operation queue.
 
 @param cache  Image cache used by manager (pass nil to avoid image cache).
 @param queue  The operation queue on which image operations are scheduled and run
 (pass nil to make the new operation start immediately without queue).
 @return A new manager.
 */
- (instancetype)initWithCache:(nullable WebImageCache *)cache
                        queue:(nullable NSOperationQueue *)queue NS_DESIGNATED_INITIALIZER;



/**
 Creates and returns a new image operation, the operation will start immediately.
 
 @param url        The image url (remote or local file path).
 @param options    The options to control image operation.
 @param progress   Progress block which will be invoked on background thread (pass nil to avoid).
 @param transform  Transform block which will be invoked on background thread  (pass nil to avoid).
 @param completion Completion block which will be invoked on background thread  (pass nil to avoid).
 @return A new image operation.
 */
- (nullable WebImageOperation *)requestImageWithURL:(NSURL *)url
                                              options:(YYWebImageOptions)options
                                             progress:(nullable YYWebImageProgressBlock)progress
                                            transform:(nullable YYWebImageTransformBlock)transform
                                           completion:(nullable YYWebImageCompletionBlock)completion;



/**
 The image cache used by image operation.
 You can set it to nil to avoid image cache.
 */
@property (nullable, nonatomic, strong) WebImageCache *cache;

/**
 The operation queue on which image operations are scheduled and run.
 You can set it to nil to make the new operation start immediately without queue.
 
 You can use this queue to control maximum number of concurrent operations, to obtain
 the status of the current operations, or to cancel all operations in this manager.
 */
@property (nullable, nonatomic, strong) NSOperationQueue *queue;

/*
 下载下来之后 在存入缓存之前修改图片
 */
@property (nullable, nonatomic, copy) YYWebImageTransformBlock sharedTransformBlock;

/**
 The image request timeout interval in seconds. Default is 15.
 */
@property (nonatomic) NSTimeInterval timeout;

/**
 The username used by NSURLCredential, default is nil.
 */
@property (nullable, nonatomic, copy) NSString *username;

/**
 The password used by NSURLCredential, default is nil.
 */
@property (nullable, nonatomic, copy) NSString *password;

/**
 The image HTTP request header. Default is "Accept:image/webp,image/\*;q=0.8".
 */
@property (nullable, nonatomic, copy) NSDictionary<NSString *, NSString *> *headers;

/**
 A block which will be invoked for each image HTTP request to do additional
 HTTP header process. Default is nil.
 
 Use this block to add or remove HTTP header field for a specified URL.
 */
@property (nullable, nonatomic, copy) NSDictionary<NSString *, NSString *> *(^headersFilter)(NSURL *url, NSDictionary<NSString *, NSString *> * _Nullable header);

/**
 A block which will be invoked for each image operation. Default is nil.
 
 Use this block to provide a custom image cache key for a specified URL.
 */
@property (nullable, nonatomic, copy) NSString *(^cacheKeyFilter)(NSURL *url);

/**
 Returns the HTTP headers for a specified URL.
 
 @param url A specified URL.
 @return HTTP headers.
 */
- (nullable NSDictionary<NSString *, NSString *> *)headersForURL:(NSURL *)url;

/**
 Returns the cache key for a specified URL.
 
 @param url A specified URL
 @return Cache key used in YYImageCache.
 */
- (NSString *)cacheKeyForURL:(NSURL *)url;


/**
 Increments the number of active network requests.
 If this number was zero before incrementing, this will start animating the
 status bar network activity indicator.
 
 This method is thread safe.
 
 This method has no effect in App Extension.
 */
+ (void)incrementNetworkActivityCount;

/**
 Decrements the number of active network requests.
 If this number becomes zero after decrementing, this will stop animating the
 status bar network activity indicator.
 
 This method is thread safe.
 
 This method has no effect in App Extension.
 */
+ (void)decrementNetworkActivityCount;

/**
 Get current number of active network requests.
 
 This method is thread safe.
 
 This method has no effect in App Extension.
 */
+ (NSInteger)currentNetworkActivityCount;



@end


NS_ASSUME_NONNULL_END


/*
 //通过类方法创建默认的请求对象
 

 
 通过这种方式创建的请求对象 默认使用NSURLRequestUseProtocolCachePolicy缓存逻辑 默认请求超时时限为60s
 


+ (instancetype)requestWithURL:(NSURL *)URL;

//返回一个BOOL值 用于判断是否支持安全编码

+ (BOOL )supportsSecureCoding;

//请求对象的初始化方法 创建时设置缓存逻辑和超时时限

+ (instancetype)requestWithURL:(NSURL *)URL cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval;

//init方法进行对象的创建 默认使用NSURLRequestUseProtocolCachePolicy缓存逻辑 默认请求超时时限为60s

- (instancetype)initWithURL:(NSURL *)URL;

//init方法进行对象的创建

- (instancetype)initWithURL:(NSURL *)URL cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval;

//只读属性 获取请求对象的URL

@property (nullable, readonly, copy) NSURL *URL;

//只读属性 缓存策略枚举

 
 NSURLRequestCachePolicy枚举如下：
 
 typedef NS_ENUM(NSUInteger, NSURLRequestCachePolicy)
 
 {
 
 //默认的缓存协议
 
 NSURLRequestUseProtocolCachePolicy = 0,
 
 //无论有无本地缓存数据 都进行从新请求
 
 NSURLRequestReloadIgnoringLocalCacheData = 1,
 
 //忽略本地和远程的缓存数据 未实现的策略
 
 NSURLRequestReloadIgnoringLocalAndRemoteCacheData = 4,
 
 //无论有无缓存数据 都进行从新请求
 
 NSURLRequestReloadIgnoringCacheData = NSURLRequestReloadIgnoringLocalCacheData,
 
 //先检查缓存 如果没有缓存再进行请求
 
 NSURLRequestReturnCacheDataElseLoad = 2,
 
 //类似离线模式，只读缓存 无论有无缓存都不进行请求
 
 NSURLRequestReturnCacheDataDontLoad = 3,
 
 //未实现的策略
 
 NSURLRequestReloadRevalidatingCacheData = 5, // Unimplemented
 
 };
 


@property (readonly) NSURLRequestCachePolicy cachePolicy;

//只读属性 获取请求的超时时限

@property (readonly) NSTimeInterval timeoutInterval;

//主文档地址 这个地址用来存放缓存

@property (nullable, readonly, copy) NSURL *mainDocumentURL;

//获取网络请求的服务类型 枚举如下


 
 typedef NS_ENUM(NSUInteger, NSURLRequestNetworkServiceType)
 
 {
 
 NSURLNetworkServiceTypeDefault = 0,   // Standard internet traffic
 
 NSURLNetworkServiceTypeVoIP = 1,  // Voice over IP control traffic
 
 NSURLNetworkServiceTypeVideo = 2, // Video traffic
 
 NSURLNetworkServiceTypeBackground = 3, // Background traffic
 
 NSURLNetworkServiceTypeVoice = 4     // Voice data
 
 };
 


@property (readonly) NSURLRequestNetworkServiceType networkServiceType;

//获取是否允许使用服务商蜂窝网络

@property (readonly)  BOOL allowsCellularAccess;
NSURLRequest请求类除了在初始化时可以设定一些属性，创建出来后则大部分属性都为只读的，无法设置与修改。 另一个类NSMutableURLRequest可以更加灵活的设置请求的相关属性。
三、NSMutableURLRequest类中常用方法与属性总结

//设置请求的URL

@property (nullable, copy) NSURL *URL;

//设置请求的缓存策略

@property NSURLRequestCachePolicy cachePolicy;

//设置超时时间

@property NSTimeInterval timeoutInterval;

//设置缓存目录

@property (nullable, copy) NSURL *mainDocumentURL;

//设置网络服务类型

@property NSURLRequestNetworkServiceType networkServiceType NS_AVAILABLE(10_7, 4_0);

//设置是否允许使用服务商蜂窝网

@property  BOOL allowsCellularAccess NS_AVAILABLE(10_8, 6_0);
四、NSURLRequest请求对象与HTTP/HTTPS协议相关请求的属性设置
一下属性的设置必须使用NSMutableURLRequest类，如果是NSURLRequest，则只可以读，不可以修改。
?
//设置HPPT请求方式 默认为“GET”

@property (copy) NSString *HTTPMethod;

//通过字典设置HTTP请求头的键值数据

@property (nullable, copy) NSDictionary<NSString *, NSString *> *allHTTPHeaderFields;

//设置http请求头中的字段值

- (void )setValue:(nullable NSString *)value forHTTPHeaderField:(NSString *)field;

//向http请求头中添加一个字段

- (void )addValue:(NSString *)value forHTTPHeaderField:(NSString *)field;

//设置http请求体 用于POST请求

@property (nullable, copy) NSData *HTTPBody;

//设置http请求体的输入流

@property (nullable, retain) NSInputStream *HTTPBodyStream;

//设置发送请求时是否发送cookie数据

@property  BOOL HTTPShouldHandleCookies;

//设置请求时是否按顺序收发 默认禁用 在某些服务器中设为YES可以提高网络性能

@property  BOOL HTTPShouldUsePipelining;

 
 */
