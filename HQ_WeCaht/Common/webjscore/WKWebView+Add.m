//
//  WKWebView+Add.m
//  HQ_WeChat
//
//  Created by 黄麒展  QQ 757618403 on 2018/1/19.
//  Copyright © 2018年 黄麒展  QQ 757618403. All rights reserved.
//

#import "WKWebView+Add.h"

@implementation WKWebView (Add)


/**清除缓存和cookie*/
+ (void)cleanCacheAndCookie{
    //清除cookies
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]){
        [storage deleteCookie:cookie];
    }
    //清除UIWebView的缓存
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
    
    NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
    
    //// Date from
    
    NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
    
    //// Execute
    
    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
    }];
}



- (void)addCustomerJavaScriptWith:(WKUserContentController *)userController{
    if (!userController) {
        return;
    }
    ///样式   -webkit-user-select: text; document.removeElement
    NSString *styleJSCode = @"var style = document.createElement('style'); \
    style.type = 'text/css'; \
    style.innerText = '*:not(input):not(textarea) {-webkit-touch-callout: none; -webkit-user-select: text;}'; \
    var head = document.getElementsByTagName('head')[0];\
    head.appendChild(style);";
    ///手势
    NSString * kTouchJavaScriptString=
    @"document.ontouchstart=function(event){\
    x=event.targetTouches[0].clientX;\
    y=event.targetTouches[0].clientY;\
    document.location=\"myweb:touch:start:\"+x+\":\"+y;};\
    document.ontouchmove=function(event){\
    x=event.targetTouches[0].clientX;\
    y=event.targetTouches[0].clientY;\
    document.location=\"myweb:touch:move:\"+x+\":\"+y;};\
    document.ontouchcancel=function(event){\
    document.location=\"myweb:touch:cancel\";};\
    document.ontouchend=function(event){\
    document.location=\"myweb:touch:end\";};";
    
    WKUserScript *script = [[WKUserScript alloc] initWithSource:styleJSCode injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
    WKUserScript *script2 = [[WKUserScript alloc] initWithSource:kTouchJavaScriptString injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
    
    ///注入JS
    [userController addUserScript:script];
    [userController addUserScript:script2];
}

- (void)addJavaScriptMessageHandlerWithDelegate:(id)delegate{
    [self.configuration.userContentController addScriptMessageHandler:delegate name:LOCAIOTNACTION];
    [self.configuration.userContentController addScriptMessageHandler:delegate name:SCANACTION];
    [self.configuration.userContentController addScriptMessageHandler:delegate name:SHAKEACTION];
}


- (void)removeAllJavaScriptMessageHandler{
    [self.configuration.userContentController removeScriptMessageHandlerForName:LOCAIOTNACTION];
    [self.configuration.userContentController removeScriptMessageHandlerForName:SCANACTION];
    [self.configuration.userContentController removeScriptMessageHandlerForName:SHAKEACTION];
}




@end

