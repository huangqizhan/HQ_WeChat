//
//  HQImageStretchController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/11/22.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQImageStretchController.h"

@interface HQImageStretchController ()

@property (nonatomic,strong) UIImageView *originImageView;
@property (nonatomic,strong) UIImageView *leftImageView;
@property (nonatomic,strong) UIImageView *rightImageView;

@end

@implementation HQImageStretchController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.originImageView];
    [self.view addSubview:self.leftImageView];
    [self.view addSubview:self.rightImageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImageView *)originImageView{
    if (_originImageView == nil) {
        _originImageView = [[UIImageView alloc] initWithFrame:CGRectMake((App_Frame_Width-30)/2.0, 0, 30, 64)];
        _originImageView.image = [UIImage imageNamed:@"stretch"];
    }
    return _originImageView;
}
- (UIImageView *)leftImageView{
    if (_leftImageView == nil) {
        _leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 120, 90, 192)];
        UIImage *image = [UIImage imageNamed:@"stretch"];
      image =  [image resizableImageWithCapInsets:UIEdgeInsetsMake(50, 0, 0, 0) resizingMode:UIImageResizingModeTile];
        _leftImageView.image = image;
    }
    return _leftImageView;
}
- (UIImageView *)rightImageView{
    if (_rightImageView == nil) {
        _rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(App_Frame_Width-100, 120, 90, 192)];
        //CGRectMake(App_Frame_Width-100, 120, 90, 192)
        UIImage *image = [UIImage imageNamed:@"stretch"];
        image =  [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0) resizingMode:UIImageResizingModeTile];
        _rightImageView.image = image;
    }
    return _rightImageView;
}
@end


/*
 UIImageResizingModeTile,  自动填充
 
 UIImageResizingModeStretch  自动拉伸
 
 */
