//
//  ProcessController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/5/2.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "ProcessController.h"
#import "DownLoadPercentView.h"



@interface ProcessController ()

@property (nonatomic,strong) DownLoadPercentView *percentView;
@property (nonatomic,strong) UISlider *sliderView;
@property (nonatomic,strong) CustomerProcessView *processView;

@end

@implementation ProcessController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _sliderView = [[UISlider alloc] initWithFrame:CGRectMake(50, 10, 200, 30)];
    [_sliderView addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_sliderView];
    
    _percentView = [[DownLoadPercentView alloc] initWithFrame:CGRectMake(50, 150, 100, 100)];
    [self.view addSubview:_percentView];
    
    _processView = [[CustomerProcessView alloc] initWithFrame:CGRectMake(50, 300, 150, 30)];
//    _processView.progressViewStyle = UIProgressViewStyleBar;
////    _processView.tintColor = [UIColor blackColor];
//    _processView.progressTintColor = [UIColor greenColor];
//    _processView.trackTintColor = [UIColor redColor];
//    _processView.transform = CGAffineTransformMakeScale(1.0f,8.0f);
    _processView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_processView];
}
- (void)sliderAction:(UISlider *)slider{
    [_percentView drawCircleWithPercent:slider.value*100];
    _processView.process = slider.value;
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
