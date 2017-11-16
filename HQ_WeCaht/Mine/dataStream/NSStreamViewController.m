//
//  NSStreamViewController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/5/18.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "NSStreamViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface NSStreamViewController () <NSStreamDelegate>

@end

@implementation NSStreamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self streamTest];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(50, 50, 50, 50)];
    [button setTitle:@"播放" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}
- (void)buttonAction{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"m1" ofType:@"mp4"];
    NSURL *url = [NSURL fileURLWithPath:path];
    MPMoviePlayerViewController *mpc = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    [self.navigationController presentViewController:mpc animated:YES completion:nil];

}
- (void)streamTest{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"m1" ofType:@"mp4"];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    NSInputStream *inputStream = [[NSInputStream alloc] initWithURL:url];
    inputStream.delegate = self;
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
    
    
//    NSOutputStream *outStream = [[NSOutputStream alloc] initWithURL:[NSURL URLWithString:@""] append:YES];
    
}
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode{
    switch (eventCode) {
        case NSStreamEventHasBytesAvailable:{
            
            uint8_t buf[1024];
            
            NSInputStream *reads = (NSInputStream *)aStream;
            NSInteger blength = [reads read:buf maxLength:sizeof(buf)]; //把流的数据放入buffer
            NSData *data = [NSData dataWithBytes:(void *)buf length:blength];
            
//            NSString *string = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%ld",data.length);
        }
            break;
            //错误和无事件处理
        case NSStreamEventErrorOccurred:{
            
        }
            break;
        case NSStreamEventNone:
            break;
            //打开完成
        case NSStreamEventOpenCompleted: {
            NSLog(@"NSStreamEventOpenCompleted");
        }
            break;
            
        default:
            break;
    }

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
