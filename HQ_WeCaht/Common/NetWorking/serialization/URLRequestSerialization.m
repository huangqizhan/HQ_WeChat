//
//  URLRequestSerialization.m
//  AFDemo
//
//  Created by hqz on 2018/10/24.
//  Copyright © 2018年 8km. All rights reserved.
//

#import "URLRequestSerialization.h"
#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

///序列化错误
NSString * const URLRequestSerializationErrorDomain = @"error.serialization.request";
///响应错误
NSString * const NetworkingOperationFailingURLRequestErrorKey = @"serialization.request.error.response";
#pragma mark ------ coding url ------

///序列化回调
typedef NSString * (^QueryStringSerializationBlock)(NSURLRequest *request, id parameters, NSError *__autoreleasing *error);

///整理url
NSString * PercentEscapedStringFromString(NSString *string) {
    static NSString * const kAFCharactersGeneralDelimitersToEncode = @":#[]@"; // does not include "?" or "/" due to RFC 3986 - Section 3.4
    static NSString * const kAFCharactersSubDelimitersToEncode = @"!$&'()*+,;=";
    
    NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [allowedCharacterSet removeCharactersInString:[kAFCharactersGeneralDelimitersToEncode stringByAppendingString:kAFCharactersSubDelimitersToEncode]];
    
    // FIXME: https://github.com/AFNetworking/AFNetworking/pull/3028
    // return [string stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
    
    static NSUInteger const batchSize = 50;
    
    NSUInteger index = 0;
    NSMutableString *escaped = @"".mutableCopy;
    
    while (index < string.length) {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wgnu"
        NSUInteger length = MIN(string.length - index, batchSize);
#pragma GCC diagnostic pop
        NSRange range = NSMakeRange(index, length);
        
        // To avoid breaking up character sequences such as 👴🏻👮🏽
        range = [string rangeOfComposedCharacterSequencesForRange:range];
        
        NSString *substring = [string substringWithRange:range];
        NSString *encoded = [substring stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
        [escaped appendString:encoded];
        
        index += range.length;
    }
    
    return escaped;
}

#pragma mark  key --- value -----

///参数键值对
@interface QueryStringPair : NSObject

@property (readwrite,nonatomic,strong) id field;
@property (readwrite,nonatomic,strong) id value;

- (instancetype)initWithField:(id)field value:(id)value;

- (NSString *)URLEncodedStringValue;
@end

@implementation QueryStringPair
- (instancetype)initWithField:(id)field value:(id)value {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.field = field;
    self.value = value;
    
    return self;
}
- (NSString *)URLEncodedStringValue {
    if (!self.value || [self.value isEqual:[NSNull null]]) {
        return PercentEscapedStringFromString([self.field description]);
    } else {
        return [NSString stringWithFormat:@"%@=%@", PercentEscapedStringFromString([self.field description]), PercentEscapedStringFromString([self.value description])];
    }
}
@end


FOUNDATION_EXPORT NSArray * QueryStringPairsFromDictionary(NSDictionary *dictionary);
FOUNDATION_EXPORT NSArray * QueryStringPairsFromKeyAndValues(NSString *key, id value);

///分装参数
NSString * QueryStringFromParameters(NSDictionary *parameters) {
    NSMutableArray *mutablePairs = [NSMutableArray array];
    for (QueryStringPair *pair in QueryStringPairsFromDictionary(parameters)) {
        [mutablePairs addObject:[pair URLEncodedStringValue]];
    }
    
    return [mutablePairs componentsJoinedByString:@"&"];
}
/// 获取封装好的参数
NSArray * QueryStringPairsFromDictionary(NSDictionary *dictionary) {
    return QueryStringPairsFromKeyAndValues(nil, dictionary);
}
///创建参数对象
NSArray *QueryStringPairsFromKeyAndValues(NSString *key,id value){
    NSMutableArray *queryStringComments = [NSMutableArray new];
    NSSortDescriptor *sortDes = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES selector:@selector(compare:)];
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionValue = value;
        for (id nestKey in [dictionValue.allKeys sortedArrayUsingDescriptors:@[sortDes]]) {
            id nestValue = dictionValue[nestKey];
            [queryStringComments addObjectsFromArray:QueryStringPairsFromKeyAndValues(key?[NSString stringWithFormat:@"%@[%@]",key,nestKey]:nestKey,nestValue)];
        }
    }else if ([value isKindOfClass:[NSSet class]]){
        NSSet *set = value;
        for (id nestValue in [set sortedArrayUsingDescriptors:@[sortDes]]) {
            [queryStringComments addObjectsFromArray:QueryStringPairsFromKeyAndValues(key,nestValue)];
        }
    }else if ([value isKindOfClass:[NSArray class]]){
        NSArray *array = value;
        for (id nestValue in array) {
            [queryStringComments addObjectsFromArray:QueryStringPairsFromKeyAndValues([NSString stringWithFormat:@"%@[]", key],nestValue)];
        }
    }else{
        [queryStringComments addObject: [[QueryStringPair alloc] initWithField:key value:value]];
    }
    return queryStringComments;
}

#pragma mark ----- StreamingMultipart ----
////多部分参数
@interface StreamingMultipartFormData : NSObject<MultipartFormData>
- (instancetype)initWithURLRequest:(NSMutableURLRequest *)urlRequest
                    stringEncoding:(NSStringEncoding)encoding;
- (NSMutableURLRequest *)requestByFinalizingMultipartFormData;

@end
///需要添加的观察的
static NSArray * HTTPRequestSerializerObservedKeyPaths() {
    static NSArray *_HTTPRequestSerializerObservedKeyPaths = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _HTTPRequestSerializerObservedKeyPaths = @[NSStringFromSelector(@selector(allowsCellularAccess)), NSStringFromSelector(@selector(cachePolicy)), NSStringFromSelector(@selector(HTTPShouldHandleCookies)), NSStringFromSelector(@selector(HTTPShouldUsePipelining)), NSStringFromSelector(@selector(networkServiceType)), NSStringFromSelector(@selector(timeoutInterval))];
    });
    
    return _HTTPRequestSerializerObservedKeyPaths;
}

static void *HTTPRequestSerializerObserverContext = &HTTPRequestSerializerObserverContext;

@interface HttpRequestSerializer ()<URLRequestSerialization>
///观察的路径
@property (readwrite, nonatomic, strong) NSMutableSet *mutableObservedChangedKeyPaths;
///httpHeaders
@property (readwrite, nonatomic, strong) NSMutableDictionary *mutableHTTPRequestHeaders;
@property (readwrite, nonatomic, assign) HTTPRequestQueryStringSerializationStyle queryStringSerializationStyle;
///回调
@property (readwrite, nonatomic, copy) QueryStringSerializationBlock queryStringSerialization;

@end

@implementation HttpRequestSerializer

+ (instancetype)serializer{
    return [[self alloc] init];
}
- (instancetype)init{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.stringEncoding = NSUTF8StringEncoding;
    self.mutableHTTPRequestHeaders = [NSMutableDictionary new];
    
    ///http header  field  "Accept-Language"
    NSMutableArray *acceptLanguagesComponents = [NSMutableArray array];
    [[NSLocale preferredLanguages] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        float q = 1.0f - (idx * 0.1f);
        [acceptLanguagesComponents addObject:[NSString stringWithFormat:@"%@;q=%0.1g", obj, q]];
        *stop = q <= 0.5f;
    }];
    [self setValue:[acceptLanguagesComponents componentsJoinedByString:@", "] forHTTPHeaderField:@"Accept-Language"];
    
    ///http header field  "User-Agent"
    NSString *userAgent = nil;
    userAgent = [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)", [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleExecutableKey] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleIdentifierKey], [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleVersionKey], [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], [[UIScreen mainScreen] scale]];
    if (userAgent) {
        if (![userAgent canBeConvertedToEncoding:NSASCIIStringEncoding]) {
            NSMutableString *mutableUserAgent = [userAgent mutableCopy];
            if (CFStringTransform((__bridge CFMutableStringRef)(mutableUserAgent), NULL, (__bridge CFStringRef)@"Any-Latin; Latin-ASCII; [:^ASCII:] Remove", false)) {
                userAgent = mutableUserAgent;
            }
        }
        [self setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    }
    self.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET",@"HEAD",@"DELETE", nil];
    self.mutableObservedChangedKeyPaths = [NSMutableSet new];
    for (NSString *keyPath in HTTPRequestSerializerObservedKeyPaths()) {
        if ([self respondsToSelector:NSSelectorFromString(keyPath)]) {
            [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:HTTPRequestSerializerObserverContext];
        }
    }
    return self;
}
- (void)dealloc{
    for (NSString *keyPath in HTTPRequestSerializerObservedKeyPaths()) {
        if ([self respondsToSelector:NSSelectorFromString(keyPath)]) {
            [self removeObserver:self forKeyPath:keyPath context:HTTPRequestSerializerObserverContext];
        }
    }
}

#pragma mark ----- setter  getter ------
- (void)setAllowCellularAccess:(BOOL)allowCellularAccess{
    [self willChangeValueForKey:NSStringFromSelector(@selector(allowCellularAccess))];
    _allowCellularAccess = allowCellularAccess;
    [self didChangeValueForKey:NSStringFromSelector(@selector(allowCellularAccess))];
}
- (void)setCachePolicy:(NSURLRequestCachePolicy)cachePolicy{
    [self willChangeValueForKey:NSStringFromSelector(@selector(cachePolicy))];
    _cachePolicy = cachePolicy;
    [self didChangeValueForKey:NSStringFromSelector(@selector(cachePolicy))];
}
- (void)setHTTPShouldHandleCookies:(BOOL)HTTPShouldHandleCookies{
    [self willChangeValueForKey:NSStringFromSelector(@selector(HTTPShouldHandleCookies))];
    _HTTPShouldHandleCookies = HTTPShouldHandleCookies;
    [self didChangeValueForKey:NSStringFromSelector(@selector(HTTPShouldHandleCookies))];
}
- (void)setHTTPShouldUsePipelining:(BOOL)HTTPShouldUsePipelining{
    [self willChangeValueForKey:NSStringFromSelector(@selector(HTTPShouldUsePipelining))];
    _HTTPShouldUsePipelining = HTTPShouldUsePipelining;
    [self didChangeValueForKey:NSStringFromSelector(@selector(HTTPShouldUsePipelining))];
}
- (void)setNetworkServiceType:(NSURLRequestNetworkServiceType)networkServiceType{
    [self willChangeValueForKey:NSStringFromSelector(@selector(networkServiceType))];
    _networkServiceType = networkServiceType;
    [self didChangeValueForKey:NSStringFromSelector(@selector(networkServiceType))];
}
- (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval{
    [self willChangeValueForKey:NSStringFromSelector(@selector(timeoutInterval))];
    _timeoutInterval = timeoutInterval;
    [self didChangeValueForKey:NSStringFromSelector(@selector(timeoutInterval))];
}
- (NSDictionary *)HTTPRequestHeaders {
    return [NSDictionary dictionaryWithDictionary:self.mutableHTTPRequestHeaders];
}

- (void)setValue:(NSString *)value
forHTTPHeaderField:(NSString *)field{
    if (!value || !field ) return;
    [self.mutableHTTPRequestHeaders setObject:value forKey:field];
}
- (NSString *)valueForHTTPHeaderField:(NSString *)field {
    return [self.mutableHTTPRequestHeaders valueForKey:field];
}
- (void)setAuthorizationHeaderFieldWithUsername:(NSString *)username password:(NSString *)password{
    NSData *basicAuthCredentials = [[NSString stringWithFormat:@"%@:%@", username, password] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64AuthCredentials = [basicAuthCredentials base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0];
    [self setValue:[NSString stringWithFormat:@"Basic %@", base64AuthCredentials] forHTTPHeaderField:@"Authorization"];
}
- (void)clearAuthorizationHeader {
    [self.mutableHTTPRequestHeaders removeObjectForKey:@"Authorization"];
}
- (void)setQueryStringSerializationWithStyle:(HTTPRequestQueryStringSerializationStyle)style {
    self.queryStringSerializationStyle = style;
    self.queryStringSerialization = nil;
}
- (void)setQueryStringSerializationWithBlock:(nullable NSString * (^)(NSURLRequest *request, id parameters, NSError * __autoreleasing *error))block{
    self.queryStringSerialization = block;
}

#pragma mark ------ request  ------
///单个部分
- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                 URLString:(NSString *)URLString
                                parameters:(nullable id)parameters
                                     error:(NSError * _Nullable __autoreleasing *)error{
    NSParameterAssert(method);
    NSParameterAssert(URLString);
    NSURL *url = [NSURL URLWithString:URLString];
    NSParameterAssert(url);
    NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    mutableRequest.HTTPMethod = method;
    for (NSString *keyPath in HTTPRequestSerializerObservedKeyPaths()) {
        if ([self.mutableObservedChangedKeyPaths containsObject:keyPath]) {
            [mutableRequest setValue:[self valueForKey:keyPath] forKey:keyPath];
        }
    }
    mutableRequest = [[self requestBySerializingRequest:mutableRequest withParameters:parameters error:error] mutableCopy];
    return mutableRequest;
}
///多个部分
- (NSMutableURLRequest *)multipartFormRequestWithMethod:(NSString *)method
                                              URLString:(NSString *)URLString
                                             parameters:(NSDictionary *)parameters
                              constructingBodyWithBlock:(void (^)(id <MultipartFormData> formData))block
                                                  error:(NSError *__autoreleasing *)error{
    NSParameterAssert(method);
    NSParameterAssert(![method isEqualToString:@"GET"] && ![method isEqualToString:@"HEAD"]);
    
    NSMutableURLRequest *mutableRequest = [self requestWithMethod:method URLString:URLString parameters:nil error:error];
    __block StreamingMultipartFormData *formData = [[StreamingMultipartFormData alloc] initWithURLRequest:mutableRequest stringEncoding:NSUTF8StringEncoding];
    if (parameters) {
        for (QueryStringPair *pair in QueryStringPairsFromDictionary(parameters)) {
            NSData *data = nil;
            if ([pair.value isKindOfClass:[NSData class]]) {
                data = pair.value;
            } else if ([pair.value isEqual:[NSNull null]]) {
                data = [NSData data];
            } else {
                data = [[pair.value description] dataUsingEncoding:self.stringEncoding];
            }
            if (data) {
                [formData appendPartWithFormData:data name:[pair.field description]];
            }
        }
    }
    if (block) {
        block(formData);
    }
    return [formData requestByFinalizingMultipartFormData];
}
- (NSMutableURLRequest *)requestWithMultipartFormRequest:(NSURLRequest *)request writingStreamContentsToFile:(NSURL *)fileURL
                                       completionHandler:(void (^)(NSError *error))handler{
    NSParameterAssert(request.HTTPBodyStream);
    NSParameterAssert([fileURL isFileURL]);
    
    NSInputStream *inputStream = request.HTTPBodyStream;
    NSOutputStream *outputStream = [[NSOutputStream alloc] initWithURL:fileURL append:NO];
    __block NSError *error = nil;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        [inputStream open];
        [outputStream open];
        
    while ([inputStream hasBytesAvailable] && [outputStream hasSpaceAvailable]) {
        uint8_t buffer [1024];
        NSInteger bytesRead = [inputStream read:buffer maxLength:1024];
        if (inputStream.streamError || bytesRead < 0) {
            error = inputStream.streamError;
            break;
        }
        NSInteger bytesWritten = [outputStream write:buffer maxLength:(NSUInteger)bytesRead];
        if (outputStream.streamError || bytesWritten < 0) {
            error = outputStream.streamError;
            break;
        }
        if (bytesRead == 0 && bytesWritten == 0) {
            break;
        }
    }
        [outputStream close];
        [inputStream close];
        if (handler) {
        dispatch_async(dispatch_get_main_queue(), ^{
                handler(error);
            });
        }
    });
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    mutableRequest.HTTPBodyStream = nil;
    return mutableRequest;
}

///序列化请求
- (NSURLRequest *)requestBySerializingRequest:(NSURLRequest *)request withParameters:(id)parameters error:(NSError *__autoreleasing *)error{
    NSParameterAssert(request);
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    ///设置请求header
    [self.HTTPRequestHeaders enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        if (![mutableRequest valueForHTTPHeaderField:key]) {
            [mutableRequest setValue:obj forHTTPHeaderField:key];
        }
    }];
    
    //设置body 或者url 参数
    NSString *queryString = nil;
    if (parameters) {
        if (self.queryStringSerialization) {
            NSError *searialError;
            queryString = self.queryStringSerialization(mutableRequest,parameters,&searialError);
            if (searialError) {
                if (error) {
                    *error = searialError;
                }
                return nil;
            }
        }else{
            switch (self.queryStringSerializationStyle){
                case HTTPRequestQueryStringDefaultStyle:
                    queryString = QueryStringFromParameters(parameters);
                    break;
            }
        }
    }
    ///HEAD GET DELETE
    if ([self.HTTPMethodsEncodingParametersInURI  containsObject:[[mutableRequest HTTPMethod] uppercaseString]]) {
        if (queryString && queryString.length > 0) {
            mutableRequest.URL = [NSURL URLWithString:[[mutableRequest.URL absoluteString] stringByAppendingFormat:mutableRequest.URL.query?@"&%@":@"?%@",queryString]];
        }
    }else{
        if (!queryString) {
            queryString = @"";
        }
        if (![mutableRequest valueForHTTPHeaderField:@"Content-Type"]) {
            [mutableRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        }
        [mutableRequest setHTTPBody:[queryString dataUsingEncoding:self.stringEncoding]];
    }
    return mutableRequest;
}
#pragma mark ------ observe

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    if ([HTTPRequestSerializerObservedKeyPaths() containsObject:key]) {
        return NO;
    }
    return [super automaticallyNotifiesObserversForKey:key];
}
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(__unused id)object
                        change:(NSDictionary *)change
                       context:(void *)context{
    if (context ==HTTPRequestSerializerObserverContext) {
        if ([change[NSKeyValueChangeNewKey] isEqual:[NSNull null]]) {
            [self.mutableObservedChangedKeyPaths removeObject:keyPath];
        } else {
            [self.mutableObservedChangedKeyPaths addObject:keyPath];
        }
    }
}
#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}
- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    if (!self) {
        return nil;
    }
    
    self.mutableHTTPRequestHeaders = [[decoder decodeObjectOfClass:[NSDictionary class] forKey:NSStringFromSelector(@selector(mutableHTTPRequestHeaders))] mutableCopy];
    self.queryStringSerializationStyle = (HTTPRequestQueryStringSerializationStyle)[[decoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(queryStringSerializationStyle))] unsignedIntegerValue];
    
    return self;
}
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.mutableHTTPRequestHeaders forKey:NSStringFromSelector(@selector(mutableHTTPRequestHeaders))];
    [coder encodeInteger:self.queryStringSerializationStyle forKey:NSStringFromSelector(@selector(queryStringSerializationStyle))];
}
#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    HttpRequestSerializer *serializer = [[[self class] allocWithZone:zone] init];
    serializer.mutableHTTPRequestHeaders = [self.mutableHTTPRequestHeaders mutableCopyWithZone:zone];
    serializer.queryStringSerializationStyle = self.queryStringSerializationStyle;
    serializer.queryStringSerialization = self.queryStringSerialization;
    
    return serializer;
}

@end
///创建 header body 的边界
static NSString * CreateMultipartFormBoundary() {
    return [NSString stringWithFormat:@"Boundary+%08X%08X", arc4random(), arc4random()];
}
///header 每个key value 之间 两个换行
static NSString * const kMultipartFormCRLF = @"\r\n";
/// 创建header开始的边界
static inline NSString * MultipartFormInitialBoundary(NSString *boundary) {
    return [NSString stringWithFormat:@"--%@%@", boundary, kMultipartFormCRLF];
}
/// 封装边界
static inline NSString * MultipartFormEncapsulationBoundary(NSString *boundary) {
    return [NSString stringWithFormat:@"%@--%@%@", kMultipartFormCRLF, boundary, kMultipartFormCRLF];
}
/// 结束时的边界
static inline NSString * MultipartFormFinalBoundary(NSString *boundary) {
    return [NSString stringWithFormat:@"%@--%@--%@", kMultipartFormCRLF, boundary, kMultipartFormCRLF];
}
static inline NSString * ContentTypeForPathExtension(NSString *extension) {
    NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)extension, NULL);
    NSString *contentType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
    if (!contentType) {
        return @"application/octet-stream";
    } else {
        return contentType;
    }
}
///3G网络下  传输量  16KB
NSUInteger const kUploadStream3GSuggestedPacketSize = 1024 * 16;
///网络不好的环境下节流   隔0.2 发送一次
NSTimeInterval const kUploadStream3GSuggestedDelay = 0.2;
#pragma mark ----HTTP body 的组成部分
@interface HTTPBodyPart : NSObject

@property (nonatomic, assign) NSStringEncoding stringEncoding;
@property (nonatomic, strong) NSDictionary *headers;
@property (nonatomic, copy) NSString *boundary;
@property (nonatomic, strong) id body;
@property (nonatomic, assign) unsigned long long bodyContentLength;
@property (nonatomic, strong) NSInputStream *inputStream;

@property (nonatomic, assign) BOOL hasInitialBoundary;
@property (nonatomic, assign) BOOL hasFinalBoundary;

@property (readonly, nonatomic, assign, getter = hasBytesAvailable) BOOL bytesAvailable;
@property (readonly, nonatomic, assign) unsigned long long contentLength;

- (NSInteger)read:(uint8_t *)buffer
        maxLength:(NSUInteger)length;

@end

#pragma mark ----- HTTP body 的 stream 数据流 包含多个（HTTPBodyPart）
@interface MultipartBodyStream : NSInputStream<NSStreamDelegate>
@property (nonatomic, assign) NSUInteger numberOfBytesInPacket;
@property (nonatomic, assign) NSTimeInterval delay;
@property (nonatomic, strong) NSInputStream *inputStream;
@property (readonly, nonatomic, assign) unsigned long long contentLength;
@property (readonly, nonatomic, assign, getter = isEmpty) BOOL empty;

- (instancetype)initWithStringEncoding:(NSStringEncoding)encoding;
- (void)setInitialAndFinalBoundaries;
- (void)appendHTTPBodyPart:(HTTPBodyPart *)bodyPart;
@end


#pragma mark ------ 整个v表单数据 ---
@interface StreamingMultipartFormData ()
@property (readwrite, nonatomic, copy) NSMutableURLRequest *request;
@property (readwrite, nonatomic, assign) NSStringEncoding stringEncoding;
@property (readwrite, nonatomic, copy) NSString *boundary;
///http body 数据
@property (readwrite, nonatomic, strong) MultipartBodyStream *bodyStream;

@end

@implementation StreamingMultipartFormData
- (instancetype)initWithURLRequest:(NSMutableURLRequest *)urlRequest
                    stringEncoding:(NSStringEncoding)encoding
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.request = urlRequest;
    self.stringEncoding = encoding;
    self.boundary = CreateMultipartFormBoundary();
    self.bodyStream = [[MultipartBodyStream alloc] initWithStringEncoding:encoding];
    return self;
}
- (BOOL)appendPartWithFileURL:(NSURL *)fileURL
                         name:(NSString *)name
                        error:(NSError * __autoreleasing *)error
{
    NSParameterAssert(fileURL);
    NSParameterAssert(name);
    
    NSString *fileName = [fileURL lastPathComponent];
    NSString *mimeType = ContentTypeForPathExtension([fileURL pathExtension]);
    
    return [self appendPartWithFileURL:fileURL name:name fileName:fileName mimeType:mimeType error:error];
}
- (BOOL)appendPartWithFileURL:(NSURL *)fileURL
                         name:(NSString *)name
                     fileName:(NSString *)fileName
                     mimeType:(NSString *)mimeType
                        error:(NSError * __autoreleasing *)error{
    NSParameterAssert(fileURL);
    NSParameterAssert(name);
    NSParameterAssert(fileName);
    NSParameterAssert(mimeType);
    
    if (![fileURL isFileURL]) {
        NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: NSLocalizedStringFromTable(@"Expected URL to be a file URL", @"AFNetworking", nil)};
        if (error) {
            *error = [[NSError alloc] initWithDomain:URLRequestSerializationErrorDomain code:NSURLErrorBadURL userInfo:userInfo];
        }
        
        return NO;
    } else if ([fileURL checkResourceIsReachableAndReturnError:error] == NO) {
        NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: NSLocalizedStringFromTable(@"File URL not reachable.", @"AFNetworking", nil)};
        if (error) {
            *error = [[NSError alloc] initWithDomain:URLRequestSerializationErrorDomain code:NSURLErrorBadURL userInfo:userInfo];
        }
        
        return NO;
    }
    
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[fileURL path] error:error];
    if (!fileAttributes) {
        return NO;
    }
    
    NSMutableDictionary *mutableHeaders = [NSMutableDictionary dictionary];
    [mutableHeaders setValue:[NSString stringWithFormat:@"form-data; name=\"%@\"; filename=\"%@\"", name, fileName] forKey:@"Content-Disposition"];
    [mutableHeaders setValue:mimeType forKey:@"Content-Type"];
    
    HTTPBodyPart *bodyPart = [[HTTPBodyPart alloc] init];
    bodyPart.stringEncoding = self.stringEncoding;
    bodyPart.headers = mutableHeaders;
    bodyPart.boundary = self.boundary;
    bodyPart.body = fileURL;
    bodyPart.bodyContentLength = [fileAttributes[NSFileSize] unsignedLongLongValue];
    [self.bodyStream appendHTTPBodyPart:bodyPart];
    
    return YES;
}
- (void)appendPartWithInputStream:(NSInputStream *)inputStream
                             name:(NSString *)name
                         fileName:(NSString *)fileName
                           length:(int64_t)length
                         mimeType:(NSString *)mimeType{
    NSParameterAssert(name);
    NSParameterAssert(fileName);
    NSParameterAssert(mimeType);
    
    NSMutableDictionary *mutableHeaders = [NSMutableDictionary dictionary];
    [mutableHeaders setValue:[NSString stringWithFormat:@"form-data; name=\"%@\"; filename=\"%@\"", name, fileName] forKey:@"Content-Disposition"];
    [mutableHeaders setValue:mimeType forKey:@"Content-Type"];
    
    HTTPBodyPart *bodyPart = [[HTTPBodyPart alloc] init];
    bodyPart.stringEncoding = self.stringEncoding;
    bodyPart.headers = mutableHeaders;
    bodyPart.boundary = self.boundary;
    bodyPart.body = inputStream;
    
    bodyPart.bodyContentLength = (unsigned long long)length;
    
    [self.bodyStream appendHTTPBodyPart:bodyPart];
}
- (void)appendPartWithFileData:(NSData *)data
                          name:(NSString *)name
                      fileName:(NSString *)fileName
                      mimeType:(NSString *)mimeType{
    NSParameterAssert(name);
    NSParameterAssert(fileName);
    NSParameterAssert(mimeType);
    
    NSMutableDictionary *mutableHeaders = [NSMutableDictionary dictionary];
    [mutableHeaders setValue:[NSString stringWithFormat:@"form-data; name=\"%@\"; filename=\"%@\"", name, fileName] forKey:@"Content-Disposition"];
    [mutableHeaders setValue:mimeType forKey:@"Content-Type"];
    
    [self appendPartWithHeaders:mutableHeaders body:data];
}
- (void)appendPartWithFormData:(NSData *)data
                          name:(NSString *)name{
    NSParameterAssert(name);
    
    NSMutableDictionary *mutableHeaders = [NSMutableDictionary dictionary];
    [mutableHeaders setValue:[NSString stringWithFormat:@"form-data; name=\"%@\"", name] forKey:@"Content-Disposition"];
    
    [self appendPartWithHeaders:mutableHeaders body:data];
}
- (void)appendPartWithHeaders:(NSDictionary *)headers
                         body:(NSData *)body{
    NSParameterAssert(body);
    
    HTTPBodyPart *bodyPart = [[HTTPBodyPart alloc] init];
    bodyPart.stringEncoding = self.stringEncoding;
    bodyPart.headers = headers;
    bodyPart.boundary = self.boundary;
    bodyPart.bodyContentLength = [body length];
    bodyPart.body = body;
    
    [self.bodyStream appendHTTPBodyPart:bodyPart];
}
///节流
- (void)throttleBandwidthWithPacketSize:(NSUInteger)numberOfBytes
                                  delay:(NSTimeInterval)delay{
    self.bodyStream.numberOfBytesInPacket = numberOfBytes;
    self.bodyStream.delay = delay;
}

///数据整理后获取request
- (NSMutableURLRequest *)requestByFinalizingMultipartFormData{
    if ([self.bodyStream isEmpty]) {
        return self.request;
    }
    ///重新设置边界
    [self.bodyStream setInitialAndFinalBoundaries];
    [self.request setHTTPBodyStream:self.bodyStream];
    [self.request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", self.boundary] forHTTPHeaderField:@"Content-Type"];
    [self.request setValue:[NSString stringWithFormat:@"%llu", [self.bodyStream contentLength]] forHTTPHeaderField:@"Content-Length"];
    return self.request;
}
@end


@interface NSStream ()
@property (readwrite) NSStreamStatus streamStatus;
@property (readwrite, copy) NSError *streamError;
@end


@interface MultipartBodyStream ()
/// 编码类型
@property (readwrite, nonatomic, assign) NSStringEncoding stringEncoding;
///多个 httpPart
@property (readwrite, nonatomic, strong) NSMutableArray *HTTPBodyParts;
///遍历 httpPart
@property (readwrite, nonatomic, strong) NSEnumerator *HTTPBodyPartEnumerator;
///当前的httpPart
@property (readwrite, nonatomic, strong) HTTPBodyPart *currentHTTPBodyPart;
@property (readwrite, nonatomic, strong) NSOutputStream *outputStream;
@property (readwrite, nonatomic, strong) NSMutableData *buffer;


@end

@implementation MultipartBodyStream

@synthesize delegate = _delegate;
@synthesize streamStatus = _streamStatus;
@synthesize streamError = _streamError;

- (instancetype)initWithStringEncoding:(NSStringEncoding)encoding {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.stringEncoding = encoding;
    self.HTTPBodyParts = [NSMutableArray array];
    self.numberOfBytesInPacket = NSIntegerMax;
    
    return self;
}
///给开始和结束part 添加 标记
- (void)setInitialAndFinalBoundaries {
    if ([self.HTTPBodyParts count] > 0) {
        for (HTTPBodyPart *bodyPart in self.HTTPBodyParts) {
            bodyPart.hasInitialBoundary = NO;
            bodyPart.hasFinalBoundary = NO;
        }
        
        [[self.HTTPBodyParts firstObject] setHasInitialBoundary:YES];
        [[self.HTTPBodyParts lastObject] setHasFinalBoundary:YES];
    }
}
- (void)appendHTTPBodyPart:(HTTPBodyPart *)bodyPart {
    [self.HTTPBodyParts addObject:bodyPart];
}
- (BOOL)isEmpty {
    return [self.HTTPBodyParts count] == 0;
}
- (NSInteger)read:(uint8_t *)buffer
        maxLength:(NSUInteger)length{
    if ([self streamStatus] == NSStreamStatusClosed) {
        return 0;
    }
    NSInteger totalNumberOfBytesRead = 0;
    while (totalNumberOfBytesRead> MIN(length, self.numberOfBytesInPacket)) {
        if (!self.currentHTTPBodyPart || !self.currentHTTPBodyPart.bytesAvailable) {
            if (!(self.currentHTTPBodyPart = [self.HTTPBodyPartEnumerator nextObject])) {
                break;
            }
        }else{
            NSUInteger maxLength = MIN(length, self.numberOfBytesInPacket) - (NSUInteger)totalNumberOfBytesRead;
            NSInteger numberOfBytesRead = [self.currentHTTPBodyPart read:&buffer[totalNumberOfBytesRead] maxLength:maxLength];
            if (numberOfBytesRead == -1) {
                self.streamError = self.currentHTTPBodyPart.inputStream.streamError;
                break;
            } else {
                totalNumberOfBytesRead += numberOfBytesRead;
                
                if (self.delay > 0.0f) {
                    [NSThread sleepForTimeInterval:self.delay];
                }
            }
        }
    }
    return totalNumberOfBytesRead;
}

#pragma mark ----- over ride NSInputStream
- (BOOL)getBuffer:(__unused uint8_t **)buffer
           length:(__unused NSUInteger *)len{
    return NO;
}
- (BOOL)hasBytesAvailable {
    return [self streamStatus] == NSStreamStatusOpen;
}
#pragma mark ----- over ride NSStream

- (void)open {
    if (self.streamStatus == NSStreamStatusOpen) {
        return;
    }
    
    self.streamStatus = NSStreamStatusOpen;
    
    [self setInitialAndFinalBoundaries];
    self.HTTPBodyPartEnumerator = [self.HTTPBodyParts objectEnumerator];
}
- (void)close {
    self.streamStatus = NSStreamStatusClosed;
}
- (id)propertyForKey:(__unused NSString *)key {
    return nil;
}
- (BOOL)setProperty:(__unused id)property
             forKey:(__unused NSString *)key{
    return NO;
}
- (void)scheduleInRunLoop:(__unused NSRunLoop *)aRunLoop
                  forMode:(__unused NSString *)mode{
}
- (void)removeFromRunLoop:(__unused NSRunLoop *)aRunLoop
                  forMode:(__unused NSString *)mode{
}
- (unsigned long long)contentLength {
    unsigned long long length = 0;
    for (HTTPBodyPart *bodyPart in self.HTTPBodyParts) {
        length += [bodyPart contentLength];
    }
    return length;
}

- (void)_scheduleInCFRunLoop:(__unused CFRunLoopRef)aRunLoop
                     forMode:(__unused CFStringRef)aMode{
}
- (void)_unscheduleFromCFRunLoop:(__unused CFRunLoopRef)aRunLoop
                         forMode:(__unused CFStringRef)aMode{
}
- (BOOL)_setCFClientFlags:(__unused CFOptionFlags)inFlags
                 callback:(__unused CFReadStreamClientCallBack)inCallback
                  context:(__unused CFStreamClientContext *)inContext {
    return NO;
}
- (instancetype)copyWithZone:(NSZone *)zone {
    MultipartBodyStream *bodyStreamCopy = [[[self class] allocWithZone:zone] initWithStringEncoding:self.stringEncoding];
    
    for (HTTPBodyPart *bodyPart in self.HTTPBodyParts) {
        [bodyStreamCopy appendHTTPBodyPart:[bodyPart copy]];
    }
    [bodyStreamCopy setInitialAndFinalBoundaries];
    return bodyStreamCopy;
}


@end
///请求数据读入阶段
typedef enum {
    ///包装开始边界阶段
    EncapsulationBoundaryPhase = 1,
    ///header 阶段
    HeaderPhase                = 2,
    ///body 阶段
    BodyPhase                  = 3,
    ///最后边界阶段
    FinalBoundaryPhase         = 4,
} HTTPBodyPartReadPhase;

@interface HTTPBodyPart ()<NSCopying>{
    NSInputStream *_inputStream;
    HTTPBodyPartReadPhase _phase;
    unsigned long long _phaseReadOffset;
}
- (BOOL)transitionToNextPhase;
- (NSInteger)readData:(NSData *)data
           intoBuffer:(uint8_t *)buffer
            maxLength:(NSUInteger)length;
@end

@implementation HTTPBodyPart

- (instancetype)init{
    self = [super init];
    if (!self) {
        return nil;
    }
    [self transitionToNextPhase];
    return self;
}
- (void)dealloc{
    if (_inputStream) {
        [_inputStream close];
        _inputStream = nil;
    }
}
- (NSInputStream *)inputStream{
    if (!_inputStream) {
        if ([self.body isKindOfClass:[NSData class]]) {
            _inputStream = [NSInputStream inputStreamWithData:self.body];
        }else if ([self.body isKindOfClass:[NSURL class]]){
            _inputStream = [NSInputStream inputStreamWithURL:self.body];
        }else if ([self.body isKindOfClass:[NSInputStream class]]){
            _inputStream = self.body;
        }else{
            _inputStream = [NSInputStream inputStreamWithData:[NSData data]];
        }
    }
    return _inputStream;
}
- (NSString *)stringForHeaders{
    NSMutableString *headerString = [NSMutableString string];
    for (NSString *field in [self.headers allKeys]) {
        [headerString appendString:[NSString stringWithFormat:@"%@: %@%@", field, [self.headers valueForKey:field], kMultipartFormCRLF]];
    }
    [headerString appendString:kMultipartFormCRLF];
    
    return [NSString stringWithString:headerString];
}
- (unsigned long long)contentLength {
    unsigned long long length = 0;
    
    NSData *encapsulationBoundaryData = [([self hasInitialBoundary] ? MultipartFormInitialBoundary(self.boundary) : MultipartFormEncapsulationBoundary(self.boundary)) dataUsingEncoding:self.stringEncoding];
    length += [encapsulationBoundaryData length];
    
    NSData *headersData = [[self stringForHeaders] dataUsingEncoding:self.stringEncoding];
    length += [headersData length];
    
    length += _bodyContentLength;
    
    NSData *closingBoundaryData = ([self hasFinalBoundary] ? [MultipartFormFinalBoundary(self.boundary) dataUsingEncoding:self.stringEncoding] : [NSData data]);
    length += [closingBoundaryData length];
    
    return length;
}
- (BOOL)hasBytesAvailable {
    // Allows `read:maxLength:` to be called again if `AFMultipartFormFinalBoundary` doesn't fit into the available buffer
    if (_phase == FinalBoundaryPhase) {
        return YES;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wcovered-switch-default"
    switch (self.inputStream.streamStatus) {
        case NSStreamStatusNotOpen:
        case NSStreamStatusOpening:
        case NSStreamStatusOpen:
        case NSStreamStatusReading:
        case NSStreamStatusWriting:
            return YES;
        case NSStreamStatusAtEnd:
        case NSStreamStatusClosed:
        case NSStreamStatusError:
        default:
            return NO;
    }
#pragma clang diagnostic pop
}
- (NSInteger)read:(uint8_t *)buffer
        maxLength:(NSUInteger)length{
    NSInteger totalNumberOfReadBytes = 0;
    if (_phase == EncapsulationBoundaryPhase) {
        NSData *encapsulationBoundaryData = [self.hasInitialBoundary? MultipartFormInitialBoundary(self.boundary): MultipartFormEncapsulationBoundary(self.boundary) dataUsingEncoding:self.stringEncoding];
        totalNumberOfReadBytes += [self readData:encapsulationBoundaryData intoBuffer:&buffer[totalNumberOfReadBytes] maxLength:length - totalNumberOfReadBytes];
    }
    
    if (_phase == HeaderPhase) {
        NSData *headerData = [[self stringForHeaders] dataUsingEncoding:self.stringEncoding];
        totalNumberOfReadBytes += [self readData:headerData intoBuffer:&buffer[totalNumberOfReadBytes] maxLength:length - totalNumberOfReadBytes];
    }
    
    if (_phase == BodyPhase) {
        NSInteger numberOfBytesRead = 0;
        
        numberOfBytesRead = [self.inputStream read:&buffer[totalNumberOfReadBytes] maxLength:(length - (NSUInteger)totalNumberOfReadBytes)];
        if (numberOfBytesRead == -1) {
            return -1;
        } else {
            totalNumberOfReadBytes += numberOfBytesRead;
            if ([self.inputStream streamStatus] >= NSStreamStatusAtEnd) {
                [self transitionToNextPhase];
            }
        }
    }
    if (_phase == FinalBoundaryPhase) {
        NSData *closingBoundaryData = ([self hasFinalBoundary] ? [MultipartFormFinalBoundary(self.boundary) dataUsingEncoding:self.stringEncoding] : [NSData data]);
        totalNumberOfReadBytes += [self readData:closingBoundaryData intoBuffer:&buffer[totalNumberOfReadBytes] maxLength:(length - (NSUInteger)totalNumberOfReadBytes)];
    }
    
    return totalNumberOfReadBytes;
}
///切换到下一个阶段
- (BOOL)transitionToNextPhase{
    if (![[NSThread currentThread] isMainThread]) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self transitionToNextPhase];
        });
        return YES;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wcovered-switch-default"
    switch (_phase) {
        case EncapsulationBoundaryPhase:
            _phase = HeaderPhase;
            break;
        case HeaderPhase:
            [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
            [self.inputStream open];
            _phase = BodyPhase;
            break;
        case BodyPhase:
            [self.inputStream close];
            _phase = FinalBoundaryPhase;
            break;
        case FinalBoundaryPhase:
        default:
            _phase = EncapsulationBoundaryPhase;
            break;
    }
    _phaseReadOffset = 0;
#pragma clang diagnostic pop
    return YES;
}
///读数据
- (NSInteger)readData:(NSData *)data
           intoBuffer:(uint8_t *)buffer
            maxLength:(NSUInteger)length{
    NSRange range = NSMakeRange((NSUInteger)_phaseReadOffset, MIN(data.length-_phaseReadOffset, length));
    [data getBytes:buffer range:range];
    _phaseReadOffset += range.length;
    if ((NSInteger)_phaseReadOffset >= data.length) {
        [self transitionToNextPhase];
    }
    
    return range.length;
}
- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    HTTPBodyPart *bodyPart = [[[self class] allocWithZone:zone] init];
    bodyPart.stringEncoding = self.stringEncoding;
    bodyPart.headers = self.headers;
    bodyPart.bodyContentLength = self.bodyContentLength;
    bodyPart.body = self.body;
    bodyPart.boundary = self.boundary;
    
    return bodyPart;
}

@end


@implementation JSONHttpRequestSerializer

+ (instancetype)serializer{
  return [self serializerWithWritingOptions:(NSJSONWritingOptions)0];
}

+ (instancetype)serializerWithWritingOptions:(NSJSONWritingOptions)writingOptions{
    JSONHttpRequestSerializer *serializer = [[self alloc] init];
    serializer.writingOptions = writingOptions;
    return serializer;
}

#pragma URLRequestSerialization
- (NSURLRequest *)requestBySerializingRequest:(NSURLRequest *)request withParameters:(id)parameters error:(NSError *__autoreleasing  _Nullable *)error{
    NSParameterAssert(request);
    ///HEAD  GET DELETE
    if ([self.HTTPMethodsEncodingParametersInURI containsObject:[[request HTTPMethod] uppercaseString]]) {
        return [super requestBySerializingRequest:request withParameters:parameters error:error];
    }
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    
    [self.HTTPRequestHeaders enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
        if (![request valueForHTTPHeaderField:field]) {
            [mutableRequest setValue:value forHTTPHeaderField:field];
        }
    }];
    
    if (parameters) {
        if (![mutableRequest valueForHTTPHeaderField:@"Content-Type"]) {
            [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        }
        
        [mutableRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:parameters options:self.writingOptions error:error]];
    }
    
    return mutableRequest;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
    [coder encodeInteger:self.writingOptions forKey:NSStringFromSelector(@selector(writingOptions))];
}
#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    JSONHttpRequestSerializer *serializer = [super copyWithZone:zone];
    serializer.writingOptions = self.writingOptions;
    
    return serializer;
}

#pragma mark - NSSecureCoding

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (!self) {
        return nil;
    }
    
    self.writingOptions = [[decoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(writingOptions))] unsignedIntegerValue];
    
    return self;
}
@end




@implementation PropertyListHttpRequestSerializer
+ (instancetype)serializer {
    return [self serializerWithFormat:NSPropertyListXMLFormat_v1_0 writeOptions:0];
}

+ (instancetype)serializerWithFormat:(NSPropertyListFormat)format
                        writeOptions:(NSPropertyListWriteOptions)writeOptions{
    PropertyListHttpRequestSerializer *serializer = [[self alloc] init];
    serializer.format = format;
    serializer.writeOptions = writeOptions;
    
    return serializer;
}

- (NSURLRequest *)requestBySerializingRequest:(NSURLRequest *)request withParameters:(id)parameters error:(NSError *__autoreleasing  _Nullable *)error{
    NSParameterAssert(request);
    
    if ([self.HTTPMethodsEncodingParametersInURI containsObject:[[request HTTPMethod] uppercaseString]]) {
        return [super requestBySerializingRequest:request withParameters:parameters error:error];
    }
    
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    
    [self.HTTPRequestHeaders enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
        if (![request valueForHTTPHeaderField:field]) {
            [mutableRequest setValue:value forHTTPHeaderField:field];
        }
    }];
    
    if (parameters) {
        if (![mutableRequest valueForHTTPHeaderField:@"Content-Type"]) {
            [mutableRequest setValue:@"application/x-plist" forHTTPHeaderField:@"Content-Type"];
        }
        
        [mutableRequest setHTTPBody:[NSPropertyListSerialization dataWithPropertyList:parameters format:self.format options:self.writeOptions error:error]];
    }
    return mutableRequest;
}
#pragma mark - NSSecureCoding

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (!self) {
        return nil;
    }
    
    self.format = (NSPropertyListFormat)[[decoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(format))] unsignedIntegerValue];
    self.writeOptions = [[decoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(writeOptions))] unsignedIntegerValue];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
    [coder encodeInteger:self.format forKey:NSStringFromSelector(@selector(format))];
    [coder encodeObject:@(self.writeOptions) forKey:NSStringFromSelector(@selector(writeOptions))];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    PropertyListHttpRequestSerializer *serializer = [super copyWithZone:zone];
    serializer.format = self.format;
    serializer.writeOptions = self.writeOptions;
    
    return serializer;
}

@end
