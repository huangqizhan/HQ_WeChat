//
//  URLResponseSerialization.h
//  AFDemo
//
//  Created by hqz on 2018/11/5.
//  Copyright © 2018年 8km. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

///序列化 错误
FOUNDATION_EXPORT NSString * const URLResponseSerializationErrorDomain;
///operation  错误
FOUNDATION_EXPORT NSString * const NetworkingOperationFailingURLResponseErrorKey;
///response data 错误
FOUNDATION_EXPORT NSString * const NetworkingOperationFailingURLResponseDataErrorKey;

///序列化 response
@protocol URLResponseSerialization <NSObject,NSSecureCoding, NSCopying>

- (nullable id)responseObjectForResponse:(nullable NSURLResponse *)response
                                    data:(nullable NSData *)data
                                   error:(NSError * _Nullable __autoreleasing *)error NS_SWIFT_NOTHROW;
@end


@interface HTTPResponseSerializer : NSObject<URLResponseSerialization>


- (instancetype)init;

@property (nonatomic, assign) NSStringEncoding stringEncoding;

+ (instancetype)serializer;

///错误码
@property (nonatomic, copy, nullable) NSIndexSet *acceptableStatusCodes;
///接收到的内容类型
@property (nonatomic, copy, nullable) NSSet <NSString *> *acceptableContentTypes;

///
- (BOOL)validateResponse:(nullable NSHTTPURLResponse *)response
                    data:(nullable NSData *)data
                   error:(NSError * _Nullable __autoreleasing *)error;

@end

/// response  json
@interface JSONResponseSerializer : HTTPResponseSerializer

@property (nonatomic, assign) NSJSONReadingOptions readingOptions;

@property (nonatomic, assign) BOOL removesKeysWithNullValues;

+ (instancetype)serializerWithReadingOptions:(NSJSONReadingOptions)readingOptions;

@end

/*
 `text/xml`
 `application/xml`
 */
@interface XMLResponseSerializer : HTTPResponseSerializer

@end


@interface PropertityListResponseSerocalzer : HTTPResponseSerializer

@property (nonatomic, assign) NSPropertyListFormat format;

@property (nonatomic, assign) NSPropertyListReadOptions readOptions;

+ (instancetype)serializerWithFormat:(NSPropertyListFormat)format
                         readOptions:(NSPropertyListReadOptions)readOptions;


@end

/*
 `image/tiff`
 `image/jpeg`
`image/gif`
`image/png`
`image/ico`
`image/x-icon`
`image/bmp`
`image/x-bmp`
`image/x-xbitmap`
`image/x-win-bitmap`
*/
@interface ImageResponseSerializer : HTTPResponseSerializer

///scale
@property (nonatomic, assign) CGFloat imageScale;

///是否自动转成位图 
@property (nonatomic, assign) BOOL automaticallyInflatesResponseImage;

@end

///混合序列化
@interface CompoundResponseSerializer : HTTPResponseSerializer

@property (readonly, nonatomic, copy) NSArray <id<URLResponseSerialization>> *responseSerializers;
+ (instancetype)compoundSerializerWithResponseSerializers:(NSArray <id<URLResponseSerialization>> *)responseSerializers;
@end
