//
//  HQBaseViewController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/2/20.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQBaseViewController.h"

@interface HQBaseViewController ()

@end

@implementation HQBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    NSShadow *shadow=[[NSShadow alloc]init];
    shadow.shadowOffset=CGSizeMake(0, 0);
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], NSForegroundColorAttributeName,shadow, NSShadowAttributeName,[UIFont fontWithName:@"Helvetica-Bold" size:18], NSFontAttributeName, nil]];
}
- (void)refershCurrnetListViewIsAppear:(BOOL)isAppear{
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
