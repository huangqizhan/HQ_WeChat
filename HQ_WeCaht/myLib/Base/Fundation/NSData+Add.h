//
//  NSData+Add.h
//  YYKitStudy
//
//  Created by GoodSrc on 2017/11/27.
//  Copyright © 2017年 GoodSrc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (Add)

/**
 Returns a lowercase NSString for md2 hash.
 */
- (nullable NSString *)md2String;

/**
 Returns a lowercase NSString for md4 hash.
 */
- (nullable NSString *)md4String;

/**
 Returns a lowercase NSString for md5 hash.
 */
- (nullable NSString *)md5String;

/**
 Returns a lowercase NSString for sha1 hash.
 */
- (nullable NSString *)sha1String;

/**
 Returns a lowercase NSString for sha224 hash.
 */
- (nullable NSString *)sha224String;

/**
 Returns a lowercase NSString for sha256 hash.
 */
- (nullable NSString *)sha256String;

/**
 Returns a lowercase NSString for sha384 hash.
 */
- (nullable NSString *)sha384String;

/**
 Returns a lowercase NSString for sha512 hash.
 */
- (nullable NSString *)sha512String;


/**
 Returns a lowercase NSString for hmac using algorithm md5 with key.
 @param key  The hmac key.
 */
- (NSString *)hmacMD5StringWithKey:(NSString *)key;

/**
 Returns an NSData for hmac using algorithm md5 with key.
 @param key  The hmac key.
 */
- (NSData *)hmacMD5DataWithKey:(NSData *)key;

/**
 Returns a lowercase NSString for hmac using algorithm sha1 with key.
 @param key  The hmac key.
 */
- (NSString *)hmacSHA1StringWithKey:(NSString *)key;

/**
 Returns an NSData for hmac using algorithm sha1 with key.
 @param key  The hmac key.
 */
- (NSData *)hmacSHA1DataWithKey:(NSData *)key;

/**
 Returns a lowercase NSString for hmac using algorithm sha224 with key.
 @param key  The hmac key.
 */
- (NSString *)hmacSHA224StringWithKey:(NSString *)key;

/**
 Returns an NSData for hmac using algorithm sha224 with key.
 @param key  The hmac key.
 */
- (NSData *)hmacSHA224DataWithKey:(NSData *)key;

/**
 Returns a lowercase NSString for hmac using algorithm sha256 with key.
 @param key  The hmac key.
 */
- (NSString *)hmacSHA256StringWithKey:(NSString *)key;

/**
 Returns an NSData for hmac using algorithm sha256 with key.
 @param key  The hmac key.
 */
- (NSData *)hmacSHA256DataWithKey:(NSData *)key;

/**
 Returns a lowercase NSString for hmac using algorithm sha384 with key.
 @param key  The hmac key.
 */
- (NSString *)hmacSHA384StringWithKey:(NSString *)key;

/**
 Returns an NSData for hmac using algorithm sha384 with key.
 @param key  The hmac key.
 */
- (NSData *)hmacSHA384DataWithKey:(NSData *)key;

/**
 Returns a lowercase NSString for hmac using algorithm sha512 with key.
 @param key  The hmac key.
 */
- (NSString *)hmacSHA512StringWithKey:(NSString *)key;

/**
 Returns an NSData for hmac using algorithm sha512 with key.
 @param key  The hmac key.
 */
- (NSData *)hmacSHA512DataWithKey:(NSData *)key;

/**
 Returns a lowercase NSString for crc32 hash.     数据校验   每次校验后返回一个结果
 */
- (NSString *)crc32String;

/**
 Returns crc32 hash.   数据校验   每次校验后返回一个结果  
 */
- (uint32_t)crc32;


/**
 aes 加密

 @param key 用于加密的key
 @param iv 用于初始化的向量   可不传
 @return 加密后的data
 */
- (nullable NSData *)aes256EncryptWithKey:(NSData *)key iv:(nullable NSData *)iv;

/**
ase 解密
 
 @param key   A key length of 16, 24 or 32 (128, 192 or 256bits).
 
 @param iv    An initialization vector length of 16(128bits).
 Pass nil when you don't want to use iv.
 
 @return      An NSData decrypted, or nil if an error occurs.
 */
- (nullable NSData *)aes256DecryptWithkey:(NSData *)key iv:(nullable NSData *)iv;


/**
 UTF8编码

 @return UTF8编码
 */
- (NSString *)utf8String;


/**
 十六进制 data 转字符串

 @return 十六进制 编码
 */
- (NSString *)hexString;


/**
 十六进制字符串  转十六进制 data

 @param hexString 十六进制字符串
 @return 十六进制 data
 */
+ (nullable NSData *)dataWithHexString:(NSString *)hexString;


/**
  返回一个用base64编码的string
 */
- (nullable NSString *)base64EncodedString;



/**
 返回一个用base64编码data

 @param base64EncodedString 用于编码的字符串
 @return 用base64编码data
 */
+ (nullable NSData *)dataWithBase64EncodedString:(NSString *)base64EncodedString;


/**
 obj json化

 @return json
 */
- (id)jsonValueDecoded;

///zip解压缩
- (NSData *)gzipInflate;

////zip压缩
- (NSData *)gzipDeflate;

///zlib 解压缩
- (NSData *)zlibInflate;

//// zlib 压缩
- (NSData *)zlibDeflate;

#pragma mark - Others
///=============================================================================
/// @name Others
///=============================================================================

/**
 Create data from the file in main bundle (similar to [UIImage imageNamed:]).
 
 @param name The file name (in main bundle).
 
 @return A new data create from the file.
 */
+ (nullable NSData *)dataNamed:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
