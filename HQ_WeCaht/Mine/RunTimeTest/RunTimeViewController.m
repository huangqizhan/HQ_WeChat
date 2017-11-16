//
//  RunTimeViewController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/10/31.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "RunTimeViewController.h"
#import "Message.h"
#import "MessageForwarding.h"
#import <objc/runtime.h>


@interface RunTimeViewController ()

@end

@implementation RunTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"RunTime";
    self.view.backgroundColor = [UIColor whiteColor];
    Message *message = [Message new];
    [message sendMessage:@"wechat"];
  size_t t =  class_getInstanceSize([Message class]);
    NSLog(@"t = %zuu",t);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
