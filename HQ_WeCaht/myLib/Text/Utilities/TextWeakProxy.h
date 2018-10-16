//
//  TextWeakProxy.h
//  YYStudyDemo
//
//  Created by hqz on 2018/8/14.
//  Copyright © 2018年 hqz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TextWeakProxy : NSProxy

///target
@property (nullable, nonatomic,weak,readonly)id target;
- (instancetype)initWithTarget:(id)target;
+ (instancetype)proxyWithTarget:(id)target;
    

@end


NS_ASSUME_NONNULL_END
