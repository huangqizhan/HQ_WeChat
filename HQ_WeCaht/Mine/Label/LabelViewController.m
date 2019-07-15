//
//  LabelViewController.m
//  HQ_WeChat
//
//  Created by 黄麒展  QQ 757618403 on 2018/10/16.
//  Copyright © 2018年 黄麒展  QQ 757618403. All rights reserved.
//

#import "LabelViewController.h"
#import "HQLabel.h"
#import "NSAttributedString+Add.h"
#import "CellTextLayout.h"
#import "TextCore.h"


@interface LabelViewController ()
@property (nonatomic,strong) HQLabel *lable;

@end

@implementation LabelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.navigationController.navigationBar.translucent = NO;
//    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    _lable = [[HQLabel alloc] initWithFrame:CGRectMake(20, 20, 250,9999)];
    _lable.textVerticalAlignment = TextVerticalAlignmentTop;
    _lable.isLongPressShowSelectionView = YES;
    _lable.textAlignment = NSTextAlignmentCenter;
    _lable.numberOfLines = 0;
//    _lable.isLongPressShowSelectionView = YES;
    _lable.backgroundColor = [UIColor greenColor];
    [self.view addSubview:_lable];
    NSString *content = @"先帝创业未半而中道崩殂，今天下三分，益州疲弊，[爱你] 此诚危急存亡之秋也。 ";
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:content];
    att.foreColor = [UIColor redColor];
    att.font = [UIFont systemFontOfSize:16];
    att.linespace = 10;

    _lable.attributedText = att;
    _lable.height = _lable.textLayout.textBoundingSize.height;

    NSLog(@"11count = %ld",_lable.textLayout.lines.count);
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(300, 100, 60, 40)];
    [button setTitle:@"test" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];


}

- (void)buttonAction{
    _lable.height = 999;
    NSString *content = @"离开的首付 \n ";
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:content];
    att.foreColor = [UIColor redColor];
    att.font = [UIFont systemFontOfSize:16];
    att.linespace = 10;
    UIView *cview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    cview.backgroundColor = [UIColor redColor];
    NSMutableAttributedString *att1 = [NSMutableAttributedString  h_attachmentStringWithContent:cview contentMode:UIViewContentModeCenter attachmentSize:cview.size alignToFont:[UIFont systemFontOfSize:16] alignment:TextVerticalAlignmentCenter];
    att1.aligenment = NSTextAlignmentCenter;
    [att appendAttributedString:att1];
    
    
    NSAttributedString *att5 = [[NSAttributedString alloc] initWithString:@"良实，[色]志虑忠纯，https://blog.csdn.net/付有司论其刑赏，以昭陛下平明之理，不宜偏私，使内外异法也。\n [刀] \n " attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    
    
    [att appendAttributedString:att5];
    
    UIImage *image = [UIImage imageNamed:@"bottomTipsBg"];
    
    NSAttributedString *att3 = [NSAttributedString h_attachmentStringWithEmojiImage:image fontSize:49];
    [att appendAttributedString:att3];
    
    
    NSAttributedString *att6 = [[NSAttributedString alloc] initWithString:@"\n良实，[色]志虑忠纯，https://blog.csdn.net/j_av_a/article/details/702  是以先帝简拔以遗陛下。 尽可能的刀] \n " attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[UIColor blueColor]}];
    
    [att appendAttributedString:att6];
    
    
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 90, 120)];
    imageV.image = [UIImage imageNamed:@"bottomTipsBg"];
    NSAttributedString *att4 = [NSMutableAttributedString  h_attachmentStringWithContent:imageV contentMode:UIViewContentModeCenter attachmentSize:imageV.size alignToFont:[UIFont systemFontOfSize:16] alignment:TextVerticalAlignmentCenter];
    [att appendAttributedString:att4];
    
    NSAttributedString * att2 = [[NSAttributedString alloc] initWithString:@"\n然侍卫之臣不懈于内，忠志之士忘身于外者 者，86-15829690862 宜付有司论其刑赏，以昭陛下平明之理，不宜偏私，使内外异法也。\n [刀]   侍中、侍郎郭攸之、费祎、董允等，此皆良实，[色]志虑忠纯，https://blog.csdn.net/j_av_a/article/details/702  是以先帝简拔以遗陛下。 志虑忠纯，https://blog.csdn.net/j_av_a/article/details/702  是以先帝简拔以遗陛下。 尽可能的  skdjfv阿卡丽；你是东方饭"];
    [att appendAttributedString:att2];
    
    _lable.attributedText = att;
    
    _lable.height = _lable.textLayout.textBoundingSize.height;
    NSLog(@"linesCout = %lu",_lable.textLayout.lines.count);
}
//
@end
