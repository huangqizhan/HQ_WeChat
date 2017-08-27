//
//  GestureViewController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/8/25.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "GestureViewController.h"
#import "SPUserResizableView.h"


@interface GestureViewController (){
    
    SPUserResizableView *_reszableView;
    
}

@end

@implementation GestureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _reszableView = [[SPUserResizableView alloc] initWithFrame:CGRectMake(30, 80, 200, 200)];
    _reszableView.backgroundColor = [UIColor clearColor];
    [_reszableView showEditingHandles];
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(30, 80, 200, 200)];
    [contentView setBackgroundColor:[UIColor redColor]];
    _reszableView.contentView = contentView;
    [self.view addSubview:_reszableView];
    
    NSLog(@"center = %@",NSStringFromCGPoint(_reszableView.center));
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
