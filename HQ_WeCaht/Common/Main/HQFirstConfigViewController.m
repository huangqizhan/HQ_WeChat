//
//  HQFirstConfigViewController.m
//  HQ_WeChat
//
//  Created by hqz on 2018/3/22.
//  Copyright © 2018年 黄麒展. All rights reserved.
//

#import "HQFirstConfigViewController.h"
#import "AppDelegate.h"
#import "ContractModel+Action.h"

@interface HQFirstConfigViewController ()

@end

@implementation HQFirstConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [ContractModel searchUserModelOnAsyThread:^(NSArray *resultList, NSArray *locaArr) {
        if (resultList.count == 0 && locaArr.count == 0) {
            [HQHUDHelper showHUDForView:self.view];
            [ContractModel applicationDidFinishLaunchedComplite:^{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self configApplicationWindow];
                });
            }];
        }
    }];
}
- (void)configApplicationWindow{
    [HQHUDHelper hiddenHUD];
    AppDelegate *dele = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [dele configerUI];
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
