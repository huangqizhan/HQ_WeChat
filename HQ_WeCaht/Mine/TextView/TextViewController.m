//
//  TextViewController.m
//  HQ_WeChat
//
//  Created by 黄麒展 on 2018/10/16.
//  Copyright © 2018年 黄麒展. All rights reserved.
//

#import "TextViewController.h"
#import "UIImage+Resize.h"

@interface TextViewController ()

@end

@implementation TextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    ImageControll *imageView = [[ImageControll alloc] initWithFrame:CGRectMake(50, 100, 120, 400)];
    UIImage *image = [UIImage imageNamed:@"SenderTextNodeBkg"];
    image = [image resizedImage:CGSizeMake(120, 400) interpolationQuality:kCGInterpolationNone];
    imageView.image = image;
    
    [self.view addSubview:imageView];
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
