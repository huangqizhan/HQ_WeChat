//
//  ChatTextModel.m
//  HQ_WeChat
//
//  Created by 黄麒展  QQ 757618403 on 2018/11/15.
//  Copyright © 2018年 8km. All rights reserved.
//

#import "ChatTextModel.h"
#import "NetWorkingOperationManager.h"

@interface ChatTextModel ()

@property (nonatomic,assign) NSUInteger status;

@end

@implementation ChatTextModel

- (void)sendMessage{
    
    NetworkingCahtTextOperation *operation = [[NetworkingCahtTextOperation alloc] init];
    
    [NetWorkingOperationManager addChatTextOperation:operation complition:^(NetworkingOperationStatus status, id responseObject) {
        NSLog(@"%@ status = %lu responseObj = %@",self.content,status,responseObject);
    }];
}
- (void)dealloc{
    NSLog(@"content = %@",self.content);
}
@end
