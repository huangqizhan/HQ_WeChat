//
//  NetworkingOperation.m
//  HQ_WeChat
//
//  Created by 黄麒展  QQ 757618403 on 2018/11/14.
//  Copyright © 2018年 8km. All rights reserved.
//

#import "NetworkingOperation.h"
#import "HTTPURLSessionManager.h"
#import "URLSessionManager.h"


@interface NetworkingBaseOperation ()

@end

@implementation NetworkingBaseOperation

///chat text  demo
- (NSUInteger )startChatTextRequestWith:(NetworkingOperationTextBlock)block{
    self.status = NetworkingOperationLoadingStatus;
    _task = [[HTTPURLSessionManager shareChatSession] POST:[self urlMethod] parameters:[self requestParmars] success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        self.status = NetworkingOperationSuccessStatus;
        if (block) block(self.status,task,responseObject);
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        self.status = NetworkingOperationFaildStatus;
        if (block) block(self.status,task,nil);
    }];
    return _task.taskIdentifier;
}

#pragma mark ---- subClass over ride  ----
///host
- (NSString *)baseUrl{
    return @"https://ssl.haimianyikao.com";
}
///url action
- (NSString *)urlMethod{
    return @"/svr/app/?meth=video.getHome8&user=0";
}
///absolute url
- (NSString *)absoluteUrlString{
    return [NSURL URLWithString:[self urlMethod] relativeToURL:[NSURL URLWithString:[self baseUrl]]].absoluteString;
}

- (NSDictionary *)requestParmars{
    return @{
             @"appver":@"2.3.1",
             @"data":@{
                     @"projectId":@(1201),
                     },
             @"device": @"855C5762-4759-4894-9BCD-781B9B1FC00D",
             @"idfa":@"60FBBAC0-9249-4B7C-BAC0-C21DB7452211",
             @"phoneType":@(2),
             };
}
@end

@implementation NetworkingCahtTextOperation

///host
- (NSString *)baseUrl{
    return @"https://ssl.haimianyikao.com";
}
///url action
- (NSString *)urlMethod{
    return @"/svr/app/?meth=video.getHome8&user=0";
}
///absolute url
- (NSString *)absoluteUrlString{
    return [NSURL URLWithString:[self urlMethod] relativeToURL:[NSURL URLWithString:[self baseUrl]]].absoluteString;
}

- (NSDictionary *)requestParmars{
    return @{
             @"appver":@"2.3.1",
             @"data":@{
                     @"projectId":@(1201),
                     },
             @"device": @"855C5762-4759-4894-9BCD-781B9B1FC00D",
             @"idfa":@"60FBBAC0-9249-4B7C-BAC0-C21DB7452211",
             @"phoneType":@(2),
             };
}

@end
