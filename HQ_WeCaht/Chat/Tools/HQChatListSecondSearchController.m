//
//  HQChatListSecondSearchController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/19.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HQChatListSecondSearchController.h"

@interface HQChatListSecondSearchController ()

@end

@implementation HQChatListSecondSearchController

- (instancetype)init{
    self = [super init];
    if (self) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BACKGROUNDCOLOR;
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
