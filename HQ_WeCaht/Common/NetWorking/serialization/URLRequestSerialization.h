//
//  URLRequestSerialization.h
//  AFDemo
//
//  Created by hqz on 2018/10/24.
//  Copyright © 2018年 8km. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 StreamingMultipartFormData 签订<MultipartFormData>协议
 属性 bodyStream（MultipartBodyStream ）负责添加数据    （包括表单字段数据，文件，stream）封装在HTTPBodyPart中

 ///封装数据
 StreamingMultipartFormData {
     MultipartBodyStream{
      HTTPBodyPart
      HTTPBodyPart
      ...
    }
 }
 
 
 请求参数的封装 QueryStringPair --> (key value)

 */



NS_ASSUME_NONNULL_BEGIN

///参数序列化类型
typedef NS_ENUM(NSUInteger, HTTPRequestQueryStringSerializationStyle) {
    HTTPRequestQueryStringDefaultStyle = 0,
};

/**
 重新编码URL
 */
FOUNDATION_EXPORT NSString * PercentEscapedStringFromString(NSString *string);

///序列化请求数据
@protocol URLRequestSerialization <NSObject,NSSecureCoding,NSCopying>

- (nullable NSURLRequest *)requestBySerializingRequest:(NSURLRequest *)request
                                withParameters:(nullable id)parameters
                                                 error:(NSError * _Nullable __autoreleasing *)error NS_SWIFT_NOTHROW;

@end

@protocol MultipartFormData ;

///求情序列化
@interface HttpRequestSerializer : NSObject<URLRequestSerialization>

///编码类型
@property (nonatomic,assign) NSStringEncoding stringEncoding;

///是否允许蜂窝网
@property (nonatomic,assign) BOOL allowCellularAccess;

///求情缓存策略
@property (nonatomic,assign) NSURLRequestCachePolicy cachePolicy;

///是否使用cookie
@property (nonatomic, assign) BOOL HTTPShouldHandleCookies;

///是否并行请求
@property (nonatomic, assign) BOOL HTTPShouldUsePipelining;

///服务类型
@property (nonatomic, assign) NSURLRequestNetworkServiceType networkServiceType;

///超时时间
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

///请求头
@property (readonly, nonatomic, strong) NSDictionary <NSString *, NSString *> *HTTPRequestHeaders;


+ (instancetype)serializer;



/// 需要序列化参数的 http method 
@property (nonatomic, strong) NSSet <NSString *> *HTTPMethodsEncodingParametersInURI;

///设置请求头
- (void)setValue:(nullable NSString *)value
forHTTPHeaderField:(NSString *)field;
///请求头的value
- (nullable NSString *)valueForHTTPHeaderField:(NSString *)field;
///设置证书的用户名 密码 
- (void)setAuthorizationHeaderFieldWithUsername:(NSString *)username password:(NSString *)password;
///清空证书
- (void)clearAuthorizationHeader;
///设置序列化类型
- (void)setQueryStringSerializationWithStyle:(HTTPRequestQueryStringSerializationStyle)style;
///设置 可自定义序列化  的回调
- (void)setQueryStringSerializationWithBlock:(nullable NSString * (^)(NSURLRequest *request, id parameters, NSError * __autoreleasing *error))block;

///创建 request   如果 http method 是 HEAD DELETE GET 参数就会拼接到Url的后面 否则就会添加到http body 中
- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                 URLString:(NSString *)URLString
                                parameters:(nullable id)parameters
                                     error:(NSError * _Nullable __autoreleasing *)error;

///创建request  多个参数  添加到body中
- (NSMutableURLRequest *)multipartFormRequestWithMethod:(NSString *)method
                                              URLString:(NSString *)URLString
                                             parameters:(NSDictionary *)parameters
                              constructingBodyWithBlock:(void (^)(id <MultipartFormData> formData))block
                                                  error:(NSError *__autoreleasing *)error;
///创建 request  读取文件数据流
- (NSMutableURLRequest *)requestWithMultipartFormRequest:(NSURLRequest *)request writingStreamContentsToFile:(NSURL *)fileURL
                                       completionHandler:(void (^)(NSError *error))handler;

@end


#pragma 添加body数据协议

@protocol MultipartFormData
///文件数据
- (BOOL)appendPartWithFileURL:(NSURL *)fileURL
                         name:(NSString *)name
                        error:(NSError * _Nullable __autoreleasing *)error;

///添加文件数据
- (BOOL)appendPartWithFileURL:(NSURL *)fileURL
                         name:(NSString *)name
                     fileName:(NSString *)fileName
                     mimeType:(NSString *)mimeType
                        error:(NSError * _Nullable __autoreleasing *)error;
///添加数据流
- (void)appendPartWithInputStream:(nullable NSInputStream *)inputStream
                             name:(NSString *)name
                         fileName:(NSString *)fileName
                           length:(int64_t)length
                         mimeType:(NSString *)mimeType;
///添加数据流
- (void)appendPartWithFileData:(NSData *)data
                          name:(NSString *)name
                      fileName:(NSString *)fileName
                      mimeType:(NSString *)mimeType;
///部分表单数据
- (void)appendPartWithFormData:(NSData *)data
                          name:(NSString *)name;

///添加header
- (void)appendPartWithHeaders:(nullable NSDictionary <NSString *, NSString *> *)headers
                         body:(NSData *)body;

///节流
- (void)throttleBandwidthWithPacketSize:(NSUInteger)numberOfBytes
                                  delay:(NSTimeInterval)delay;

@end


///json序列化
@interface JSONHttpRequestSerializer : HttpRequestSerializer

@property (nonatomic, assign) NSJSONWritingOptions writingOptions;

+ (instancetype)serializerWithWritingOptions:(NSJSONWritingOptions)writingOptions;
@end

///属性列表 序列化
@interface PropertyListHttpRequestSerializer : HttpRequestSerializer

///属性系列化格式
@property (nonatomic, assign) NSPropertyListFormat format;

@property (nonatomic, assign) NSPropertyListWriteOptions writeOptions;

+ (instancetype)serializerWithFormat:(NSPropertyListFormat)format
                        writeOptions:(NSPropertyListWriteOptions)writeOptions;

@end



///序列化错误
FOUNDATION_EXPORT NSString * const URLRequestSerializationErrorDomain;
///operation 错误
FOUNDATION_EXPORT NSString * const NetworkingOperationFailingURLRequestErrorKey;
///3G网络下  传输量  16KB
FOUNDATION_EXPORT NSUInteger const kUploadStream3GSuggestedPacketSize;

///网络不好的环境下节流   隔0.2 发送一次
FOUNDATION_EXPORT NSTimeInterval  const kUploadStream3GSuggestedDelay;




NS_ASSUME_NONNULL_END
