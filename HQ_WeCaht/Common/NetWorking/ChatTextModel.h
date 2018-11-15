//
//  ChatTextModel.h
//  HQ_WeChat
//
//  Created by 黄麒展  QQ 757618403 on 2018/11/15.
//  Copyright © 2018年 8km. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatTextModel : NSObject

@property (nonatomic,copy) NSString *content;

- (void)sendMessage;

@end

NS_ASSUME_NONNULL_END
