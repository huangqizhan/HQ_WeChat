//
//  HQReCodeResultController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/9/6.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQReCodeResultController.h"

@interface HQReCodeResultController ()

@property(nonatomic,strong) UILabel *conentLabel;

@end

@implementation HQReCodeResultController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //得到当前视图控制器中的所有控制器
    NSMutableArray *array = [self.navigationController.viewControllers mutableCopy];
    //把B从里面删除
    [array removeObjectAtIndex:1];
    //把删除后的控制器数组再次赋值
    [self.navigationController setViewControllers:[array copy] animated:YES];
    
    [self.view addSubview:self.conentLabel];
    self.conentLabel.text = _codeString;
}


- (UILabel *)conentLabel{
    if (_conentLabel  == nil) {
        _conentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, App_Frame_Width-20, 100)];
    }
    return _conentLabel;
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
