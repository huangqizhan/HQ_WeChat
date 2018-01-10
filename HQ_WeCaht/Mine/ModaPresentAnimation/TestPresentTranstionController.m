//
//  TestPresentTranstionController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/4/12.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "TestPresentTranstionController.h"
#import "UIViewController+HQPresentTranstion.h"
#import "ControllerPresentTranstionAnimation.h"



@interface TestPresentTranstionController ()<ControllerPresentTranstionAnimationDelegate>{
    
    UIButton *_button;
}

@end

@implementation TestPresentTranstionController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    [self setTranstionDelegate];
    
    _button = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    _button.backgroundColor = [UIColor blackColor];
    [_button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
}
- (void)buttonAction:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UIButton *)presentTranstionButton{
    return _button;
}
- (UIButton *)dismissTranstionButton{
    return _button;
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
