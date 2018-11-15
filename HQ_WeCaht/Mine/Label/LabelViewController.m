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


@interface LabelViewController ()
@property (nonatomic,strong) HQLabel *lable;

@end

@implementation LabelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    _lable = [[HQLabel alloc] initWithFrame:CGRectMake(20, 20, 250,650)];
    _lable.textVerticalAlignment = TextVerticalAlignmentTop;
    _lable.textAlignment = NSTextAlignmentCenter;
    _lable.numberOfLines = 0;
    _lable.isLongPressShowSelectionView = YES;
//    _lable.textContainerInset = UIEdgeInsetsMake(20, 20, 20, 20);
    _lable.backgroundColor = [UIColor greenColor];
    [self.view addSubview:_lable];
    
    NSString *content = @"先帝创业未半而中道崩殂，今天下三分，益州疲弊，此诚危急存亡之秋也。然侍卫之臣不懈于内，忠志之士忘身于外者，https://blog.csdn.net/j_av_a/article/details/702 盖追先帝之殊遇，欲报之于陛下也。诚宜开张圣听，以光先帝遗德，恢弘志士之气，不宜妄自菲薄，引喻失义，以塞忠谏之路也。\n https://blog.csdn.net/j_av_a/article/details/702   宫中府中，俱为一体，陟罚臧否，[爱你]不宜异同。[爱你]若有作奸犯科及为忠善者，86-15829690862 宜付有司论其刑赏，以昭陛下平明之理，不宜偏私，使内外异法也。\n [刀]   侍中、侍郎郭攸之、费祎、董允等，此皆良实，[色]志虑忠纯，https://blog.csdn.net/j_av_a/article/details/702  是以先帝简拔以遗陛下。 尽可能的 此皆良实，[色]志虑忠纯，https://blog.csdn.net/j_av_a/article/details/702  是以先帝简拔以遗陛下。 尽可能的  skdjfv阿卡丽；你是东方饭";
    ChatMessageModel *model = [ChatMessageModel creatAnSnedMesssageWith:content andReceiverId:12 andUserName:@"23" andUserPic:@"122"];
    CellTextLayout *layout = [[CellTextLayout alloc] initWith:model];
    _lable.height = layout.textHeight;
    _lable.textLayout = layout.textLayout;
//    _lable.width = layout.textLayout.textBoundingRect.size.width;
    
//    _lable.height = layout.textLayout.textBoundingRect.size.height;
//
//    NSString *content = @"先帝创业未半而中道崩殂，今天下三分，益州疲弊，此诚危急存亡之秋也。然侍卫之臣不懈于内，忠志之士忘身于外者，盖追先帝之殊遇，欲报之于陛下也。诚宜开张圣听，以光先帝遗德，恢弘志士之气，不宜妄自菲薄，引喻失义，以塞忠谏之路也。\n    宫中府中，俱为一体，陟罚臧否，不宜异同。若有作奸犯科及为忠善者，宜付有司论其刑赏，以昭陛下平明之理，不宜偏私，使内外异法也。\n    侍中、侍郎郭攸之、费祎、董允等，此皆良实，志虑忠纯，是以先帝简拔以遗陛下。";
//
//    ///愚以为宫中之事，事无大小，悉以咨之，然后施行，必能裨补阙漏，有所广益。\n    将军向宠，性行淑均，晓畅军事，试用之于昔日，先帝称之曰能，是以众议举宠为督。愚以为营中之事，悉以咨之，必能使行阵和睦，优劣得所。\n    亲贤臣，远小人，此先汉所以兴隆也；亲小人，远贤臣，此后汉所以倾颓也。先帝在时，每与臣论此事，未尝不叹息痛恨于桓、灵也。侍中、尚书、长史、参军，此悉贞良死节之臣，愿陛下亲之信之，则汉室之隆，可计日而待也。
//
//    NSString *secContent = @" 臣本布衣，躬耕于南阳，苟全性命于乱世，不求闻达于诸侯。先帝不以臣卑鄙，猥自枉屈，三顾臣于草庐之中，咨臣以当世之事，由是感激，遂许先帝以驱驰。后值倾覆，受任于败军之际，奉命于危难之间，尔来二十有一年矣。\n";
//    ////    先帝知臣谨慎，故临崩寄臣以大事也。受命以来，夙夜忧叹，恐托付不效，以伤先帝之明，故五月渡泸，深入不毛。今南方已定，兵甲已足，当奖率三军，北定中原，庶竭驽钝，攘除奸凶，兴复汉室，还于旧都。此臣所以报先帝而忠陛下之职分也。至于斟酌损益，进尽忠言，则攸之、祎、允之任也。
//    NSString *thedStr = @"  愿陛下托臣以讨贼兴复之效，不效，";
//
//    ///。则治臣之罪，以告先帝之灵 若无兴德之言，则责攸之、祎、允等之慢，以彰其咎；陛下亦宜自谋，以咨诹善道，察纳雅言，深追先帝遗诏，臣不胜受恩感激。\n    今当远离，临表涕零，不知所言。
//
//
//
//    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:content attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:16]}];
//
//    NSMutableAttributedString *tapAtt = [[NSMutableAttributedString alloc] initWithString:@"tapAction"];
//
//
//    tapAtt.foreColor = [UIColor redColor];
//    tapAtt.font = [UIFont systemFontOfSize:28];
//
//    TextBorder *border = [TextBorder new];
//    border.cornerRadius = 3;
//    border.insets = UIEdgeInsetsMake(-2, -1, -2, -1);
//    border.fillColor = [UIColor colorWithWhite:0.000 alpha:0.220];
//
//    TextHeightLight *highlight = [TextHeightLight new];
//    [highlight setBorder:border];
//    highlight.tapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
//        NSLog(@"tapAction");
//    };
//    [tapAtt h_setTextHighlight:highlight range:NSMakeRange(0, tapAtt.length)];
//
//    [text appendAttributedString:tapAtt];
//
//    TextHeightLight *h2  = [TextHeightLight new];
//    h2.attributes = @{NSForegroundColorAttributeName:[UIColor blueColor],NSFontAttributeName:[UIFont systemFontOfSize:28]};
//    h2.longPressAction = ^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
//        NSLog(@"longpress");
//    };
//
//
//    NSAttributedString *secAtt = [[NSAttributedString alloc] initWithString:secContent attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:16]}];
//    [text appendAttributedString:secAtt];
//
//
//    NSMutableAttributedString *longAtt = [[NSMutableAttributedString alloc] initWithString:@"longpressAction"];
//
//    longAtt.foreColor = [UIColor redColor];
//    longAtt.font = [UIFont systemFontOfSize:28];
//
//    TextBorder *border2 = [TextBorder new];
//    border2.cornerRadius = 3;
//    border2.insets = UIEdgeInsetsMake(-2, -1, -2, -1);
//    border2.fillColor = [UIColor colorWithWhite:0.000 alpha:0.220];
//    [h2 setBorder:border2];
//
//    [longAtt h_setTextHighlight:h2 range:NSMakeRange(0, longAtt.length)];
//
//    [text appendAttributedString:longAtt];
//
//
//
//    NSAttributedString *thdAtt = [[NSAttributedString alloc] initWithString:thedStr attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:16]}];
//    [text appendAttributedString:thdAtt];
//
//
//    _lable.attributedText = text;
    
}

@end
