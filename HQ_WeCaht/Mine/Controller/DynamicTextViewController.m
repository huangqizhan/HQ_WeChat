//
//  DynamicTextViewController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/5/10.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "DynamicTextViewController.h"
#import "YYText.h"
#import "YYTextContainerView.h"
#import "UIImage+YYWebImage.h"
#import "YYImage.h"
#import "YYAnimatedImageView.h"



@interface DynamicTextViewController ()

@property (nonatomic,strong) UISlider *sliderView;

@property (nonatomic,strong) UIImageView *imageView;

@end

@implementation DynamicTextViewController

- (void)viewDidLoad{
    [super viewDidLoad];

//    _sliderView = [[UISlider alloc] initWithFrame:CGRectMake((App_Frame_Width-200)/2.0, 20, 200, 40)];
//    [_sliderView addTarget:self action:@selector(sliderButtonAction:) forControlEvents:UIControlEventValueChanged];
//    [self.view addSubview:self.sliderView];
//    
//    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake((App_Frame_Width-100)/2.0, _sliderView.bottom+10, 100, 100)];
//    _imageView.image = [UIImage imageNamed:@"mayun"];
//    [self.view addSubview:_imageView];
    
    
    NSString *contentStr = @"[色][色][色][色][色]他自己會長、你有機會可以見到有罪案及一批由我負責管理青年廣場[吐]http://www.baidu.com 对这个世界如果你有太多的抱怨  @我是帕克  @我是莱昂纳德   你不服你就来     [胜利][握手]";
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:contentStr];
    //字体
    [text yy_setFont:[UIFont systemFontOfSize:16] range:text.yy_rangeOfAll];
    //行间距
    text.yy_lineSpacing = 5;
    NSRange range0 = [[text string] rangeOfString:@"对这个世界如果你有太多的抱怨" options:NSCaseInsensitiveSearch];
    //字体
    [text yy_setFont:[UIFont systemFontOfSize:25] range:range0];
    //文字颜色
    [text yy_setColor:[UIColor purpleColor] range:range0];
    //文字间距
    [text yy_setKern:@(2) range:range0];
    {
        ///图片表情

    }
    
//    {
//        UIFont *font = [UIFont systemFontOfSize:16];
//        NSString *title = @"This is UIImage attachment:";
//        [text appendAttributedString:[[NSAttributedString alloc] initWithString:title attributes:nil]];
//        
//        UIImage *image = [UIImage imageNamed:@"mayun.jpg"];
//        image = [image yy_imageByResizeToSize:CGSizeMake(30, 30)];
//        image = [UIImage imageWithCGImage:image.CGImage scale:2 orientation:UIImageOrientationUp];
//        
//        NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:image contentMode:UIViewContentModeCenter attachmentSize:image.size alignToFont:font alignment:YYTextVerticalAlignmentCenter];
//        [text appendAttributedString:attachText];
//        [text appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:nil]];
//        
//    }
//    NSArray *names = @[@"001@2x", @"002@2x", @"003@2x",@"004@2x",@"005@2x"];
//    for (NSString *name in names) {
//        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"gif"];
//        NSData *data = [NSData dataWithContentsOfFile:path];
//        YYImage *image = [YYImage imageWithData:data scale:2];
//        image.preloadAllAnimatedImageFrames = YES;
//        YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] initWithImage:image];
//        UIFont *font = [UIFont systemFontOfSize:16];
//        NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:imageView contentMode:UIViewContentModeCenter attachmentSize:imageView.size alignToFont:font alignment:YYTextVerticalAlignmentCenter];
//        [text appendAttributedString:attachText];
//    }
    YYLabel *label  = [[YYLabel alloc] initWithFrame:CGRectZero];
    YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake((App_Frame_Width - 100), MAXFLOAT)];
    YYTextLayout *layout = [YYTextLayout layoutWithContainer:container text:text];
    label.textLayout = layout;
    label.top = 10;label.left = 10;
    label.attributedText = text;
    label.width = layout.textBoundingRect.size.width;
    label.height = layout.textBoundingRect.size.height;
    label.backgroundColor = [UIColor grayColor];
    [self.view addSubview:label];
    
}
//- (void)sliderButtonAction:(UISlider *)slider{
//    
//}
@end
