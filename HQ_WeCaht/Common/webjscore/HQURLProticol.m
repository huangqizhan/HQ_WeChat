//
//  HQURLProticol.m
//  HQ_WeChat
//
//  Created by 黄麒展 on 2018/1/19.
//  Copyright © 2018年 黄麒展. All rights reserved.
//

#import "HQURLProticol.h"
#import <UIKit/UIKit.h>


static NSString* const HQURLProticolKey = @"KHybridNSURLProtocol";

@interface  HQURLProticol () <NSURLSessionDelegate>
///记录当前的requerst 请求
@property (nonnull,strong) NSURLSessionDataTask *task;

@end

@implementation HQURLProticol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request{
    NSString *scheme = [[request URL] scheme];
    if ( ([scheme caseInsensitiveCompare:@"http"]  == NSOrderedSame ||
          [scheme caseInsensitiveCompare:@"https"] == NSOrderedSame )){
        //看看是否已经处理过了，防止无限循环
        id res =[NSURLProtocol propertyForKey:HQURLProticolKey inRequest:request];
        if (res)
            return NO;
        return YES;
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request{
    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
    //request截取重定向
    //    if ([request.URL.absoluteString isEqualToString:sourUrl])
    //    {
    //        NSURL* url1 = [NSURL URLWithString:localUrl];
    //        mutableReqeust = [NSMutableURLRequest requestWithURL:url1];
    //    }
    
    return mutableReqeust;
}
+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b{
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading{
    NSMutableURLRequest *mutableReqeust = [[self request] mutableCopy];
    //给我们处理过的请求设置一个标识符, 防止无限循环,
    [NSURLProtocol setProperty:@YES forKey:HQURLProticolKey inRequest:mutableReqeust];
    //判断图片是否已经下载  如果没有就继续下载  如果已经下载从缓存中读取 
//    if ([mutableReqeust.URL.absoluteString isEqualToString:sourIconUrl]){
//        UIImage *image = [UIImage imageNamed:@"medlinker"];
//        NSData* data = UIImagePNGRepresentation(image);
//        NSURLResponse* response = [[NSURLResponse alloc] initWithURL:self.request.URL MIMEType:@"image/png" expectedContentLength:data.length textEncodingName:nil];
//        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
//        [self.client URLProtocol:self didLoadData:data];
//        [self.client URLProtocolDidFinishLoading:self];
//    }else{
//        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
//        self.task = [session dataTaskWithRequest:self.request];
//        [self.task resume];
//    }
}
- (void)stopLoading{
    if (self.task != nil){
        [self.task  cancel];
    }
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
//    if ([dataTask.response.URL.absoluteString isEqualToString:sourUrl]){
//        [[self client] URLProtocol:self didLoadData: [@"123" dataUsingEncoding:NSUTF8StringEncoding]];
//    }else{
//        [[self client] URLProtocol:self didLoadData: [@"321" dataUsingEncoding:NSUTF8StringEncoding]];
//    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    [self.client URLProtocolDidFinishLoading:self];
}

@end
