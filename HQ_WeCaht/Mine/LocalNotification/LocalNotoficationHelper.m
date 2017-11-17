//
//  LocalNotoficationHelper.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/11/16.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "LocalNotoficationHelper.h"
#import <UserNotifications/UserNotifications.h>
#import <MobileCoreServices/MobileCoreServices.h>



@implementation LocalNotoficationHelper

+ (void)addLoaclNotification{
    // 1、创建通知内容
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = @"HQ_WeChat Loacl notification";
    content.subtitle = @"Good Good  Study Day Day Up";
    content.body = @"平心静气，安心工作";
    // 设置消息提醒的数目
    NSInteger count = [UIApplication sharedApplication].applicationIconBadgeNumber+1;
    content.badge = [NSNumber numberWithInteger:count];
    
    NSError *error = nil;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"IMG_0373" ofType:@"jpg"];
    
    // 2、设置通知附件内容
    UNNotificationAttachment *att = [UNNotificationAttachment attachmentWithIdentifier:@"att1" URL:[NSURL fileURLWithPath:path?path:@""] options:nil error:&error];
    
    if (error) {
        NSLog(@"attachment error %@",error);
    }
    content.attachments = @[att];
    content.launchImageName = @"1";
    
    // 2、设置声音
    UNNotificationSound *sound = [UNNotificationSound defaultSound];
    content.sound = sound;
    
//    // 3、触发模式1
//    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:5 repeats:NO];
    
    ///出发模式2
    NSDateComponents *com = [[NSDateComponents alloc] init];
    com.hour =  9;
    com.minute = 5;
    UNCalendarNotificationTrigger *trigger1 = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:com repeats:YES];
    
      ///出发模式2
//    UNLocationNotificationTrigger  
    // 4、设置UNNotificationRequest
    NSString *requestIdentifier = @"TestRequest";
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifier content:content trigger:trigger1];
    
    
    NSDateComponents *com2 = [[NSDateComponents alloc] init];
    com2.hour =  11;
    com2.minute = 50;
    UNCalendarNotificationTrigger *trigger2 = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:com2 repeats:YES];
    
    ///出发模式2
    //    UNLocationNotificationTrigger
    // 4、设置UNNotificationRequest
    NSString *requestIdentifier2 = @"TestRequest2";
    UNNotificationRequest *request2 = [UNNotificationRequest requestWithIdentifier:requestIdentifier2 content:content trigger:trigger2];

    NSDateComponents *com3 = [[NSDateComponents alloc] init];
    com3.hour =  10;
    com3.minute = 0;
    UNCalendarNotificationTrigger *trigger3 = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:com3 repeats:YES];
    
    ///出发模式2
    //    UNLocationNotificationTrigger
    // 4、设置UNNotificationRequest
    NSString *requestIdentifier3 = @"TestRequest3";
    UNNotificationRequest *request3 = [UNNotificationRequest requestWithIdentifier:requestIdentifier3 content:content trigger:trigger3];

    // 5、把通知加到UNUserNotificationCenter，到指定触发点会被触发
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        NSLog(@"通知");
    }];
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request2 withCompletionHandler:^(NSError * _Nullable error) {
        NSLog(@"2通知");
    }];
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request3 withCompletionHandler:^(NSError * _Nullable error) {
        NSLog(@"3通知");
    }];


}
+ (void)removeLoaclnotification{
        [[UNUserNotificationCenter currentNotificationCenter] removeAllDeliveredNotifications];
        [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
}

@end
