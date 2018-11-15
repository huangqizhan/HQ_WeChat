//
//  URLResponseSerialization.m
//  AFDemo
//
//  Created by hqz on 2018/11/5.
//  Copyright © 2018年 8km. All rights reserved.
//

#import "URLResponseSerialization.h"

NSString * const URLResponseSerializationErrorDomain = @"com.alamofire.error.serialization.response";
NSString * const NetworkingOperationFailingURLResponseErrorKey = @"com.alamofire.serialization.response.error.response";
NSString * const NetworkingOperationFailingURLResponseDataErrorKey = @"com.alamofire.serialization.response.error.data";
///error
static NSError * ErrorWithUnderlyingError(NSError *error, NSError *underlyingError) {
    if (!error) {
        return underlyingError;
    }
    ///NSUnderlyingErrorKey 底层出现的错误
    if (!underlyingError || error.userInfo[NSUnderlyingErrorKey]) {
        return error;
    }
    
    NSMutableDictionary *mutableUserInfo = [error.userInfo mutableCopy];
    mutableUserInfo[NSUnderlyingErrorKey] = underlyingError;
    return [[NSError alloc] initWithDomain:error.domain code:error.code userInfo:mutableUserInfo];
}
///
static BOOL ErrorOrUnderlyingErrorHasCodeInDomain(NSError *error, NSInteger code, NSString *domain) {
    if ([error.domain isEqualToString:domain] && error.code == code) {
        return YES;
    } else if (error.userInfo[NSUnderlyingErrorKey]) {
        return ErrorOrUnderlyingErrorHasCodeInDomain(error.userInfo[NSUnderlyingErrorKey], code, domain);
    }
    
    return NO;
}
///json 序列化
static id JSONObjectByRemovingKeysWithNullValues(id JSONObject, NSJSONReadingOptions readingOptions) {
    if ([JSONObject isKindOfClass:[NSArray class]]) {
        NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:[(NSArray *)JSONObject count]];
        for (id value in (NSArray *)JSONObject) {
            [mutableArray addObject:JSONObjectByRemovingKeysWithNullValues(value, readingOptions)];
        }
        
        return (readingOptions & NSJSONReadingMutableContainers) ? mutableArray : [NSArray arrayWithArray:mutableArray];
    } else if ([JSONObject isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:JSONObject];
        for (id <NSCopying> key in [(NSDictionary *)JSONObject allKeys]) {
            id value = (NSDictionary *)JSONObject[key];
            if (!value || [value isEqual:[NSNull null]]) {
                [mutableDictionary removeObjectForKey:key];
            } else if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {
                mutableDictionary[key] = JSONObjectByRemovingKeysWithNullValues(value, readingOptions);
            }
        }
        
        return (readingOptions & NSJSONReadingMutableContainers) ? mutableDictionary : [NSDictionary dictionaryWithDictionary:mutableDictionary];
    }
    
    return JSONObject;
}

@implementation HTTPResponseSerializer

+ (instancetype)serializer {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.stringEncoding = NSUTF8StringEncoding;
    
    self.acceptableStatusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)];
    self.acceptableContentTypes = nil;
    
    return self;
}

- (BOOL)validateResponse:(NSHTTPURLResponse *)response
                    data:(NSData *)data
                   error:(NSError * __autoreleasing *)error{
    BOOL responseIsValid = YES;
    NSError *validationError = nil;
    if (response && [response isKindOfClass:[NSHTTPURLResponse class]]) {
        if (self.acceptableContentTypes && ![self.acceptableContentTypes containsObject:[response MIMEType]] && !([response MIMEType] == nil && data.length == 0)) {
            if (data.length > 0 && [response URL]) {
                ///数据类型不符合
                NSMutableDictionary *mutableUserInfo = [@{
                                                          NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedStringFromTable(@"Request failed: unacceptable content-type: %@", @"AFNetworking", nil), [response MIMEType]],
                                                          NSURLErrorFailingURLErrorKey:[response URL],
                                                          NetworkingOperationFailingURLResponseErrorKey: response,
                                                          } mutableCopy];
                if (data) {                    mutableUserInfo[NetworkingOperationFailingURLResponseDataErrorKey] = data;
                }
                validationError = ErrorWithUnderlyingError([NSError errorWithDomain:URLResponseSerializationErrorDomain code:NSURLErrorCannotDecodeContentData userInfo:mutableUserInfo], validationError);

            }
            responseIsValid = NO;
        }
        ///位置类型的状态码
        if(self.acceptableStatusCodes && ![self.acceptableStatusCodes containsIndex:(NSUInteger)response.statusCode] && [response URL]){
            NSMutableDictionary *mutableUserInfo = [@{
                                                      NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedStringFromTable(@"Request failed: %@ (%ld)", @"AFNetworking", nil), [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode], (long)response.statusCode],
                                                      NSURLErrorFailingURLErrorKey:[response URL],
                                                      NetworkingOperationFailingURLResponseErrorKey: response,
                                                      } mutableCopy];
            if (data) {
                mutableUserInfo[NetworkingOperationFailingURLResponseDataErrorKey] = data;
            }
            validationError = ErrorWithUnderlyingError([NSError errorWithDomain:URLResponseSerializationErrorDomain code:NSURLErrorBadServerResponse userInfo:mutableUserInfo], validationError);
            
            responseIsValid = NO;
        }
    }
    
    if (error && !responseIsValid) {
        *error = validationError;
    }

    return responseIsValid;
}

#pragma mark ---- AFURLResponseSerialization

- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing  _Nullable *)error{
    [self validateResponse:(NSHTTPURLResponse *)response data:data error:error];
    return data;
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
    
    self.acceptableStatusCodes = [decoder decodeObjectOfClass:[NSIndexSet class] forKey:NSStringFromSelector(@selector(acceptableStatusCodes))];
    self.acceptableContentTypes = [decoder decodeObjectOfClass:[NSIndexSet class] forKey:NSStringFromSelector(@selector(acceptableContentTypes))];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.acceptableStatusCodes forKey:NSStringFromSelector(@selector(acceptableStatusCodes))];
    [coder encodeObject:self.acceptableContentTypes forKey:NSStringFromSelector(@selector(acceptableContentTypes))];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    HTTPResponseSerializer *serializer = [[[self class] allocWithZone:zone] init];
    serializer.acceptableStatusCodes = [self.acceptableStatusCodes copyWithZone:zone];
    serializer.acceptableContentTypes = [self.acceptableContentTypes copyWithZone:zone];
    
    return serializer;
}

@end

@implementation JSONResponseSerializer

+ (instancetype)serializer {
    return [self serializerWithReadingOptions:(NSJSONReadingOptions)0];
}

+ (instancetype)serializerWithReadingOptions:(NSJSONReadingOptions)readingOptions {
    JSONResponseSerializer *serializer = [[self alloc] init];
    serializer.readingOptions = readingOptions;
    
    return serializer;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",nil];
    return self;
}

#pragma mark ---- AFURLResponseSerialization
- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing  _Nullable *)error{
    
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error]) {
        if (!error || ErrorOrUnderlyingErrorHasCodeInDomain(*error, NSURLErrorCannotDecodeContentData,URLResponseSerializationErrorDomain)) {
            
        }
        return nil;
    }
    id responseObject = nil;
    NSError *serializationError = nil;
    BOOL isSpace = [data isEqualToData:[NSData dataWithBytes:" " length:1]];
    if (data.length > 0 && !isSpace) {
        responseObject = [NSJSONSerialization JSONObjectWithData:data options:self.readingOptions error:&serializationError];
    } else {
        return nil;
    }

    if (self.removesKeysWithNullValues && responseObject) {
        responseObject = JSONObjectByRemovingKeysWithNullValues(responseObject, self.readingOptions);
    }
    if (error) {
        *error = ErrorWithUnderlyingError(serializationError, *error);
    }
    return responseObject;
}
#pragma mark - NSSecureCoding

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (!self) {
        return nil;
    }
    
    self.readingOptions = [[decoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(readingOptions))] unsignedIntegerValue];
    self.removesKeysWithNullValues = [[decoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(removesKeysWithNullValues))] boolValue];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
    [coder encodeObject:@(self.readingOptions) forKey:NSStringFromSelector(@selector(readingOptions))];
    [coder encodeObject:@(self.removesKeysWithNullValues) forKey:NSStringFromSelector(@selector(removesKeysWithNullValues))];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    JSONResponseSerializer *serializer = [[[self class] allocWithZone:zone] init];
    serializer.readingOptions = self.readingOptions;
    serializer.removesKeysWithNullValues = self.removesKeysWithNullValues;
    
    return serializer;
}

@end


@implementation XMLResponseSerializer

+ (instancetype)serializer {
    XMLResponseSerializer *serializer = [[self alloc] init];
    
    return serializer;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.acceptableContentTypes = [[NSSet alloc] initWithObjects:@"application/xml", @"text/xml",@"text/html", nil];
    
    return self;
}

#pragma mark - AFURLResponseSerialization

- (id)responseObjectForResponse:(NSHTTPURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error]) {
        if (!error || ErrorOrUnderlyingErrorHasCodeInDomain(*error, NSURLErrorCannotDecodeContentData, URLResponseSerializationErrorDomain)) {
            return nil;
        }
    }
    
    return [[NSXMLParser alloc] initWithData:data];
}


@end



@implementation PropertityListResponseSerocalzer

+ (instancetype)serializer {
    return [self serializerWithFormat:NSPropertyListXMLFormat_v1_0 readOptions:0];
}

+ (instancetype)serializerWithFormat:(NSPropertyListFormat)format
                         readOptions:(NSPropertyListReadOptions)readOptions
{
    PropertityListResponseSerocalzer *serializer = [[self alloc] init];
    serializer.format = format;
    serializer.readOptions = readOptions;
    
    return serializer;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.acceptableContentTypes = [[NSSet alloc] initWithObjects:@"application/x-plist", nil];
    
    return self;
}

#pragma mark - AFURLResponseSerialization

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error{
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error]) {
        if (!error || ErrorOrUnderlyingErrorHasCodeInDomain(*error, NSURLErrorCannotDecodeContentData, URLResponseSerializationErrorDomain)) {
            return nil;
        }
    }
    
    id responseObject;
    NSError *serializationError = nil;
    
    if (data) {
        responseObject = [NSPropertyListSerialization propertyListWithData:data options:self.readOptions format:NULL error:&serializationError];
    }
    
    if (error) {
        *error = ErrorWithUnderlyingError(serializationError, *error);
    }
    return responseObject;
}

#pragma mark - NSSecureCoding

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (!self) {
        return nil;
    }
    
    self.format = (NSPropertyListFormat)[[decoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(format))] unsignedIntegerValue];
    self.readOptions = [[decoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(readOptions))] unsignedIntegerValue];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
    [coder encodeObject:@(self.format) forKey:NSStringFromSelector(@selector(format))];
    [coder encodeObject:@(self.readOptions) forKey:NSStringFromSelector(@selector(readOptions))];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    PropertityListResponseSerocalzer *serializer = [[[self class] allocWithZone:zone] init];
    serializer.format = self.format;
    serializer.readOptions = self.readOptions;
    
    return serializer;
}
@end


#import <UIKit/UIKit.h>

@interface UIImage (NetworkingSafeImageLoading)
+ (UIImage *)af_safeImageWithData:(NSData *)data;
@end

static NSLock* imageLock = nil;

@implementation UIImage (NetworkingSafeImageLoading)

+ (UIImage *)af_safeImageWithData:(NSData *)data {
    UIImage* image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imageLock = [[NSLock alloc] init];
    });
    
    [imageLock lock];
    image = [UIImage imageWithData:data];
    [imageLock unlock];
    return image;
}
@end
static UIImage * ImageWithDataAtScale(NSData *data, CGFloat scale) {
    UIImage *image = [UIImage af_safeImageWithData:data];
    if (image.images) {
        return image;
    }
    
    return [[UIImage alloc] initWithCGImage:[image CGImage] scale:scale orientation:image.imageOrientation];
}
///位图处理
static UIImage *InflatedImageFromResponseWithDataAtScale(NSHTTPURLResponse *response,NSData *data,CGFloat scale){
    if (!data || [data length] == 0) {
        return nil;
    }
    CGImageRef imageRef = NULL;
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    if ([response.MIMEType isEqualToString:@"image/png"]) {
        imageRef = CGImageCreateWithPNGDataProvider(dataProvider, NULL, true, kCGRenderingIntentDefault);
    }else if ([response.MIMEType isEqualToString:@"image/jpeg"]){
        imageRef = CGImageCreateWithJPEGDataProvider(dataProvider, NULL, true, kCGRenderingIntentDefault);
        if (imageRef) {
            CGColorSpaceRef imageColorSpace = CGImageGetColorSpace(imageRef);
            CGColorSpaceModel imageColorSpaceModel = CGColorSpaceGetModel(imageColorSpace);
            
            // CGImageCreateWithJPEGDataProvider does not properly handle CMKY, so fall back to AFImageWithDataAtScale
            if (imageColorSpaceModel == kCGColorSpaceModelCMYK) {
                CGImageRelease(imageRef);
                imageRef = NULL;
            }
        }
    }
    
    
    CGDataProviderRelease(dataProvider);
    
    UIImage *image = ImageWithDataAtScale(data, scale);
    if (!imageRef) {
        if (image.images || !image) {
            return image;
        }
        
        imageRef = CGImageCreateCopy([image CGImage]);
        if (!imageRef) {
            return nil;
        }
    }
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    size_t bitsPerComment = CGImageGetBitsPerComponent(imageRef);
    ///图片的最大显示
    if (width * height > 1024 * 1024 || bitsPerComment > 8) {
        CGImageRelease(imageRef);
        return image;
    }
    size_t bytesPerRow = 0;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(colorSpace);
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    if (colorSpaceModel == kCGColorSpaceModelRGB) {
        uint32_t alpha = (bitmapInfo & kCGBitmapAlphaInfoMask);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wassign-enum"
        if (alpha == kCGImageAlphaNone) {
            bitmapInfo &= ~kCGBitmapAlphaInfoMask;
            bitmapInfo |= kCGImageAlphaNoneSkipFirst;
        } else if (!(alpha == kCGImageAlphaNoneSkipFirst || alpha == kCGImageAlphaNoneSkipLast)) {
            bitmapInfo &= ~kCGBitmapAlphaInfoMask;
            bitmapInfo |= kCGImageAlphaPremultipliedFirst;
        }
#pragma clang diagnostic pop
    }
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, bitsPerComment, bytesPerRow, colorSpace, bitmapInfo);
    
    CGColorSpaceRelease(colorSpace);
    
    if (!context) {
        CGImageRelease(imageRef);
        
        return image;
    }
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, width, height), imageRef);
    CGImageRef inflatedImageRef = CGBitmapContextCreateImage(context);
    
    CGContextRelease(context);
    
    UIImage *inflatedImage = [[UIImage alloc] initWithCGImage:inflatedImageRef scale:scale orientation:image.imageOrientation];
    
    CGImageRelease(inflatedImageRef);
    CGImageRelease(imageRef);
    
    return inflatedImage;
}


@implementation ImageResponseSerializer

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.acceptableContentTypes = [[NSSet alloc] initWithObjects:@"image/tiff", @"image/jpeg", @"image/gif", @"image/png", @"image/ico", @"image/x-icon", @"image/bmp", @"image/x-bmp", @"image/x-xbitmap", @"image/x-win-bitmap", nil];

    self.imageScale = [[UIScreen mainScreen] scale];
    self.automaticallyInflatesResponseImage = YES;
    return self;
}

#pragma mark ---- URLResponseSerializer

- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing  _Nullable *)error{
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error]) {
        if (!error || ErrorOrUnderlyingErrorHasCodeInDomain(*error, NSURLErrorCannotDecodeContentData, URLResponseSerializationErrorDomain)) {
            return nil;
        }
    }
    if (self.automaticallyInflatesResponseImage) {
        return InflatedImageFromResponseWithDataAtScale((NSHTTPURLResponse *)response, data, self.imageScale);
    } else {
        return ImageWithDataAtScale(data, self.imageScale);
    }
}
#pragma mark - NSSecureCoding

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (!self) {
        return nil;
    }
    
#if TARGET_OS_IOS  || TARGET_OS_TV || TARGET_OS_WATCH
    NSNumber *imageScale = [decoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(imageScale))];
#if CGFLOAT_IS_DOUBLE
    self.imageScale = [imageScale doubleValue];
#else
    self.imageScale = [imageScale floatValue];
#endif
    
    self.automaticallyInflatesResponseImage = [decoder decodeBoolForKey:NSStringFromSelector(@selector(automaticallyInflatesResponseImage))];
#endif
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
    [coder encodeObject:@(self.imageScale) forKey:NSStringFromSelector(@selector(imageScale))];
    [coder encodeBool:self.automaticallyInflatesResponseImage forKey:NSStringFromSelector(@selector(automaticallyInflatesResponseImage))];
#endif
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    ImageResponseSerializer *serializer = [[[self class] allocWithZone:zone] init];
    
#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
    serializer.imageScale = self.imageScale;
    serializer.automaticallyInflatesResponseImage = self.automaticallyInflatesResponseImage;
#endif
    
    return serializer;
}

@end


@interface CompoundResponseSerializer ()

@property (readwrite, nonatomic, copy) NSArray *responseSerializers;

@end

@implementation CompoundResponseSerializer

+ (instancetype)compoundSerializerWithResponseSerializers:(NSArray *)responseSerializers {
    CompoundResponseSerializer *serializer = [[self alloc] init];
    serializer.responseSerializers = responseSerializers;
    return serializer;
}
#pragma mark ----- URLResponseSerialization
- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing  _Nullable *)error{
    for (id <URLResponseSerialization> serializer in self.responseSerializers) {
        if (![serializer isKindOfClass:[HTTPResponseSerializer class]]) {
            continue;
        }
        NSError *serializerError = nil;
        id responseObject = [serializer responseObjectForResponse:response data:data error:&serializerError];
        if (responseObject) {
            if (error) {
                *error = ErrorWithUnderlyingError(serializerError, *error);
            }
            return responseObject;
        }
    }
    return [super responseObjectForResponse:response data:data error:error];
}

@end
