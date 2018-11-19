//
//  TestOperation.m
//  LunchOPeration
//
//  Created by hjb_mac_mini on 2018/10/16.
//  Copyright © 2018年 8km. All rights reserved.
//

#import "TestOperation.h"
#import <UIKit/UIKit.h>


@implementation TestOperation
///队列的类型
+ (HQOperationQueueType)_queueType{
    return HQOperationQueueSerialQueueType;
}
- (BOOL)_execIsOnMain{
    return NO;
}
- (void)_execOnAsync{
    for (int i = 0; i < 1000; i++) {
        NSLog(@"title = %@ thread = %@",_title,[NSThread currentThread]);
    }
    [self done];
}
@end


@implementation TestOperationA
///队列的类型
+ (HQOperationQueueType)_queueType{
    return HQOperationQueueSerialQueueType;
}
- (BOOL)_execIsOnMain{
    return NO;
}
- (void)_execOnAsync{
    for (int i = 0; i < 1000; i++) {
        NSLog(@"title = %@ thread = %@",_title,[NSThread currentThread]);
    }
    [self done];
}
@end

@implementation TestOperationB
///队列的类型
+ (HQOperationQueueType)_queueType{
    return HQOperationQueueSerialQueueType;
}
- (BOOL)_execIsOnMain{
    return YES;
}
- (void)_execOnAsync{
//    for (int i = 0; i < 1000; i++) {
//        NSLog(@"title = %@ thread = %@",_title,[NSThread currentThread]);
//    }
//    [self done];
}
- (void)_execOnMain{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"title" message:@"msg" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"action" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"p3 thread = %@",[NSThread currentThread]);
            [self done];
        }];
        [alertVC addAction:action];
        [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:alertVC animated:YES completion:nil];
    });
}
@end


@implementation TestOperationC
///队列的类型
+ (HQOperationQueueType)_queueType{
    return HQOperationQueueSerialQueueType;
}
- (BOOL)_execIsOnMain{
    return NO;
}
- (void)_execOnAsync{
    for (int i = 0; i < 1000; i++) {
        NSLog(@"title = %@ thread = %@",_title,[NSThread currentThread]);
    }
    [self done];
}
@end
