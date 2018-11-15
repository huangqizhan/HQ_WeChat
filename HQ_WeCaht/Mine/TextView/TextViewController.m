//
//  TextViewController.m
//  HQ_WeChat
//
//  Created by 黄麒展  QQ 757618403 on 2018/10/16.
//  Copyright © 2018年 黄麒展  QQ 757618403. All rights reserved.
//

#import "TextViewController.h"
#import "AnimatedImageView.h"
#import "MyImage.h"

@interface TextViewController ()

@end

@implementation TextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    AnimatedImageView *anView = [[AnimatedImageView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    NSString *path = [[NSBundle mainBundle]pathForResource:@"Tuzki_15" ofType:@".gif"];
    anView.image = [MyImage imageWithContentsOfFile:path];
    [self.view addSubview:anView];
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
