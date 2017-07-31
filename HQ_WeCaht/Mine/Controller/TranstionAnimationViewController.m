//
//  TranstionAnimationViewController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/5/2.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "TranstionAnimationViewController.h"
#import "TestPresentTranstionController.h"
#import "UIViewController+HQPresentTranstion.h"
#import "ControllerPresentTranstionAnimation.h"


@interface TranstionAnimationViewController ()<ControllerPresentTranstionAnimationDelegate>{
    
    UIButton *_button;
    
}

@end

@implementation TranstionAnimationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _button = [[UIButton alloc] initWithFrame:CGRectMake(100, 300, 100, 100)];
    [_button setImage:[UIImage imageNamed:@"mayun.jpg"] forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
    [self setTranstionDelegate];
}
- (void)buttonAction:(UIButton *)sender{
    TestPresentTranstionController *testvc = [[TestPresentTranstionController alloc] init];
    [self presentViewController:testvc animated:YES completion:nil];
}
- (UIButton *)presentTranstionButton{
    return _button;
}
- (UIButton *)dismissTranstionButton{
    return _button;
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
