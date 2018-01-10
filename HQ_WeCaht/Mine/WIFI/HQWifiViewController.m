//
//  HQWifiViewController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/5/19.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQWifiViewController.h"
#import "HQWiFiTools.h"

@interface HQWifiViewController (){
    
    UILabel *_currentWifi;
    UILabel *_iplabel;
    UIButton *_button;
}

@end

@implementation HQWifiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _button = [[UIButton alloc] initWithFrame:CGRectMake(20, 30, 60, 30)];
    [_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_button setTitle:@"wifi" forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
    
    UIButton *ipBUt = [[UIButton alloc] initWithFrame:CGRectMake(20, 100, 50, 50)];
    [ipBUt setTitle:@"ip" forState:UIControlStateNormal];
    [ipBUt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [ipBUt addTarget:self action:@selector(ipBUttonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:ipBUt];
    
    
    _currentWifi = [[UILabel alloc] initWithFrame:CGRectMake(100, 30, 200, 30)];
    [self.view addSubview:_currentWifi];
    
    _iplabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 200, 30)];
    [self.view addSubview:_iplabel];
    
    
    NSURL *url = [NSURL URLWithString:@"http://120.25.226.186:32812/resources/videos/minion_%02d.mp4"];
    NSLog(@"url pathExtern = %@",url.pathExtension);
    NSLog(@"url lastPathComponent = %@",url.lastPathComponent);
    NSLog(@"url stringByDeletingPathExtension = %@",url.URLByDeletingPathExtension);
    
}
- (void)ipBUttonAction{
    NSDictionary *dic = [[HQWiFiTools defaultInstance] getLocalInfoForCurrentWiFi];
    _iplabel.text = [dic objectForKey:@"localIp"];
}
- (void)buttonAction{
    [[HQWiFiTools defaultInstance] scanNetworksWithCompletionHandler:^(NSArray<HQWiFi *> * _Nullable networks, HQWiFi * _Nullable currentWiFi, NSError * _Nullable error) {
        _currentWifi.text = [NSString stringWithFormat:@"%@ ",currentWiFi.wifiName];
    }];
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
