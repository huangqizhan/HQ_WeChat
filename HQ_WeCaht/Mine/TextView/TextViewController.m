//
//  TextViewController.m
//  HQ_WeChat
//
//  Created by 黄麒展  QQ 757618403 on 2018/10/16.
//  Copyright © 2018年 黄麒展  QQ 757618403. All rights reserved.
//

#import "TextViewController.h"
#import "ImageControll.h"

@interface TextViewController ()

@end

@implementation TextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIImage *hightedImage = [UIImage imageNamed:@"SenderTextNodeBkgHL"];
    ImageControll *controllView = [[ImageControll alloc] initWithFrame:CGRectMake(100, 30, 200, 500)];
    hightedImage = [hightedImage  resizableImageWithCapInsets:UIEdgeInsetsMake(hightedImage.size.height*0.5, hightedImage.size.width*0.5, hightedImage.size.width*0.5, hightedImage.size.width*0.5) resizingMode:UIImageResizingModeStretch];
    controllView.image = hightedImage;
    controllView.layer.contentsScale = [UIScreen mainScreen].scale;
    controllView.layer.contentMode =  UIViewContentModeScaleToFill;
    [self.view addSubview:controllView];
    
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
