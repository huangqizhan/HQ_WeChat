//
//  SecurityPolicy.h
//  AFDemo
//
//  Created by hqz on 2018/11/6.
//  Copyright © 2018年 8km. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 1> 首先客户端先发第一个随机数N1，
 2> 然后服务器回了第二个随机数N2（这个过程同时把之前提到的证书发给客户端 客户端需要验证证书），这两个随机数都是明文的；
 3> 客户端根据公钥生成第三个随机数N3（这个随机数被称为Premaster secret），客户端用数字证书的公钥进行非对称加密，发给服务器；而服务器用只有自己知道的私钥来解密，获取第三个随机数。
 这样，服务端和客户端都有了三个随机数N1+N2+N3，然后两端就使用这三个随机数来生成“对话密钥”，在此之后的通信都是使用这个“对话密钥”来进行对称加密解密。因为这个过程中，服务端的私钥只用来解密第三个随机数，从来没有在网络中传输过，这样的话，只要私钥没有被泄露，那么数据就是安全的。
 */



/*

 私钥和公钥都存放在服务端  
 
 >> htps 单项认证 ----
 
 1，客户端向服务端发送SSL协议版本号、加密算法种类、随机数等信息。
 2，服务端给客户端返回SSL协议版本号、加密算法种类、随机数等信息，同时也返回服务器端的证书，即公钥证书
 客户端使用服务端返回的信息验证服务器的合法性，包括：
 
 3， 证书是否过期
 发型服务器证书的CA是否可靠
 返回的公钥是否能正确解开返回证书中的数字签名
 服务器证书上的域名是否和服务器的实际域名相匹配
 验证通过后，将继续进行通信，否则，终止通信
 
 4，客户端向服务端发送用公钥加密的随机数及自己所能支持的对称加密方案，供服务器端进行选择
 5，服务器端在客户端提供的加密方案中选择加密程度最高的加密方式。
 6，服务器将选择好的加密方案通过明文方式返回给客户端
 7，客户端接收到服务端返回的加密方式后，使用该加密方式生成产生随机码，用作通信过程中对称加密的密钥，使用服务端返回的公钥进行加密，将加密后的随机码发送至服务器
 8，服务器收到客户端返回的加密信息后，使用自己的私钥进行解密，获取对称加密密钥。
 在接下来的会话中，服务器和客户端将会使用该密码进行对称加密，保证通信过程中信息的安全。
 
 >>https  双向认证  ------
 
 
 1，客户端向服务端发送SSL协议版本号、加密算法种类、随机数等信息。
 2，服务端给客户端返回SSL协议版本号、加密算法种类、随机数等信息，同时也返回服务器端的证书，即公钥证书
 3，客户端使用服务端返回的信息验证服务器的合法性，包括：
 
 证书是否过期
 发型服务器证书的CA是否可靠
 返回的公钥是否能正确解开返回证书中的数字签名
 服务器证书上的域名是否和服务器的实际域名相匹配
 验证通过后，将继续进行通信，否则，终止通信
 
 4，服务端要求客户端发送客户端的证书，客户端会将自己的证书发送至服务端
 5，验证客户端的证书，通过验证后，会获得客户端的公钥
 6，客户端向服务端发送自己所能支持的对称加密方案，供服务器端进行选择
 7，服务器端在客户端提供的加密方案中选择加密程度最高的加密方式
 8，将加密方案通过使用之前获取到的公钥进行加密，返回给客户端
 9，客户端收到服务端返回的加密方案密文后，使用自己的私钥进行解密，获取具体加密方式，而后，产生该加密方式的随机码，用作加密过程中的密钥，使用之前从服务端证书中获取到的公钥进行加密后，发送给服务端
 10，服务端收到客户端发送的消息后，使用自己的私钥进行解密，获取对称加密的密钥，在接下来的会话中，服务器和客户端将会使用该密码进行对称加密，保证通信过程中信息的安全。
 
 */


/*
 认证证书是否有效   可以系统认证  也可自己认证
 */

///SSL 证书类型
typedef NS_ENUM(NSInteger,SSLPinningMode) {
    ///不用认证
    SSLPinningModeNone,
    ///只认证公钥
    SSLPinningModePublicKey,
    ///全部认证
    SSLPinningModeCertificate,
};

NS_ASSUME_NONNULL_BEGIN

@interface SecurityPolicy : NSObject<NSSecureCoding,NSCopying>

///认证类型
@property (readonly, nonatomic, assign) SSLPinningMode SSLPinningMode;

///本地证书集合
@property (nonatomic, strong, nullable) NSSet <NSData *> *pinnedCertificates;

///是否认证无效的证书
@property (nonatomic, assign) BOOL allowInvalidCertificates;

///是否验证这书中的域名
@property (nonatomic, assign) BOOL validatesDomainName;

///boundle 中的所有证书
+ (NSSet <NSData *> *)certificatesInBundle:(NSBundle *)bundle;


+ (instancetype)defaultPolicy;

+ (instancetype)policyWithPinningMode:(SSLPinningMode)pinningMode;

+ (instancetype)policyWithPinningMode:(SSLPinningMode)pinningMode withPinnedCertificates:(NSSet <NSData *> *)pinnedCertificates;

/// 服务器是否信任
- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust
                  forDomain:(nullable NSString *)domain;
@end

NS_ASSUME_NONNULL_END
