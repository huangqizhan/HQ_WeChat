//
//  AR2DTestViewController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/10/18.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "AR2DTestViewController.h"
#import "UIImage+Gallop.h"



@interface AR2DTestViewController ()

@property (nonatomic,strong) UIButton *backButton;

@end

@implementation AR2DTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.backButton];
}
- (void)backButtonClick:(UIButton *)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (UIButton *)backButton{
    if (_backButton == nil) {
        _backButton = [[UIButton alloc] initWithFrame:CGRectMake((App_Frame_Width-50)/2.0, APP_Frame_Height-60, 50, 50)];
        UIImage *image = [UIImage imageNamedFromMyBundle:@"navi_back.png"];
        image = [image lw_imageRotatedByDegrees:270];
        [_backButton setImage: image forState:UIControlStateNormal];
        [_backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];    }
    return _backButton;
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
