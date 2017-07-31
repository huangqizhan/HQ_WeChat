//
//  HQDisPlayTextController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/5/31.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQDisPlayTextController.h"
#import "HQAttrubuteTextLabel.h"

@interface HQDisPlayTextController () <UIGestureRecognizerDelegate>{
    UIFont *labelFont;
    UITapGestureRecognizer *tap;
}


@property (nonatomic) HQAttrubuteTextLabel *contentLabel;
@property (nonatomic) UIView *screenSnapshot;
@property (nonatomic) UIWindow *targetWindow;


@end

@implementation HQDisPlayTextController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    labelFont = [UIFont systemFontOfSize:27];
    tap = [self addTapGestureRecognizer:@selector(tapHandler:) target:self];
    tap.delegate = self;
}
- (void)setupContentLabel {
    self.contentLabel = [[HQAttrubuteTextLabel alloc] init];
    
    self.contentLabel.frame = self.view.bounds;
    self.contentLabel.backgroundColor = [UIColor whiteColor];
    self.contentLabel.textContainer.lineFragmentPadding = 0;
    self.contentLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.contentLabel.editable = NO;
    self.contentLabel.scrollEnabled = YES;
    self.contentLabel.selectable = NO;
    self.contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentLabel.showsVerticalScrollIndicator = YES;
    self.contentLabel.font = labelFont;
    NSAttributedString *richText = [HQAttrubuteTextLabel createAttributedStringWithEmotionString:self.messageModel.contentString font:labelFont lineSpacing:2];
    self.contentLabel.textContainerInset = [self calLabelTextContainerInset:self.contentLabel attributedString:richText];
    self.contentLabel.attributedText = richText;
    [self.view addSubview:self.contentLabel];
    
    WEAK_SELF;
    self.contentLabel.longPressAction = ^(HQAttrubuteTextData *data,UIGestureRecognizerState state) {
        if (!data)return;
        
        if (state == UIGestureRecognizerStateEnded) {
            if (data.type == HQAttrubuteTextTypeURL) {
                NSLog(@"url = %@",data.url.absoluteString);
            }else if (data.type == HQAttrubuteTextTypePhoneNumber) {
                NSLog(@"number = %@",data.phoneNumber);
            }
            
            [weakSelf exit];
        }
        
    };
    
    self.contentLabel.tapAction = ^(HQAttrubuteTextData *data) {
        if (!data)return;
        
        if (data.type == HQAttrubuteTextTypeURL) {
            NSLog(@"url = %@",data.url.absoluteString);
        }else if (data.type == HQAttrubuteTextTypePhoneNumber) {
            NSLog(@"number = %@",data.phoneNumber);
        }
        [weakSelf exit];
    };
}
- (void)showInWindown{
    
    NSArray *windows = [UIApplication sharedApplication].windows;
    NSInteger maxWindowLevel = 0;
    for (UIWindow *window in windows) {
        if (window.windowLevel > maxWindowLevel) {
            maxWindowLevel = window.windowLevel;
        }
    }
    UIWindow *targetWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    targetWindow.backgroundColor = [UIColor clearColor];
    targetWindow.windowLevel = maxWindowLevel + 1;
    targetWindow.rootViewController = self;
    targetWindow.hidden = NO;
    self.targetWindow = targetWindow;
    [self setupContentLabel];
    self.contentLabel.alpha = 0;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.contentLabel.alpha = 1;
    }];
}
- (void)tapHandler:(UIGestureRecognizer *)tap {
    [self exit];
}

- (void)exit {
    if (self.contentLabel.alpha == 0)
        return;
    
    [UIView animateWithDuration:.25 animations:^{
        self.contentLabel.alpha = 0;
    } completion:^(BOOL finished) {
        self.targetWindow.hidden = YES;
        self.targetWindow = nil;
    } ];
}

- (UIEdgeInsets)calLabelTextContainerInset:(HQAttrubuteTextLabel *)label attributedString:(NSAttributedString *)attributedString {
    UIEdgeInsets defaultEdgeInset = UIEdgeInsetsMake(32, 20, 45, 20);
    
    CGRect frame = [attributedString boundingRectWithSize:CGSizeMake(CGRectGetWidth(label.frame) - defaultEdgeInset.left - defaultEdgeInset.right, MAXFLOAT) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
    
    CGFloat textWidth = CGRectGetWidth(frame);
    CGFloat textHeight = CGRectGetHeight(frame);
    
    //水平左右间隔最小各为20，但是布局完毕后如果两侧空白有较多剩余
    //则适当调大左右间隔,避免左右两个间距差别太大，不对称。
    defaultEdgeInset.left = round((CGRectGetWidth(label.frame) - textWidth) / 2);
    defaultEdgeInset.right = floor(CGRectGetWidth(label.frame) - textWidth - defaultEdgeInset.left);
    
    //垂直方向：不满一屏时，上面空白与下面空白比例为0.4：0.6, 稍微向上偏移
    if (textHeight + defaultEdgeInset.top + defaultEdgeInset.bottom < CGRectGetHeight(label.frame)) {
        defaultEdgeInset.top = round(0.4 *(CGRectGetHeight(label.frame) - textHeight));
        defaultEdgeInset.bottom = 0;
    }
    
    return defaultEdgeInset;
}

- (UITapGestureRecognizer *)addTapGestureRecognizer:(SEL)action target:(id)target {
    UITapGestureRecognizer *temptap = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    temptap.numberOfTapsRequired = 1;
    temptap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:temptap];
    return temptap;
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
