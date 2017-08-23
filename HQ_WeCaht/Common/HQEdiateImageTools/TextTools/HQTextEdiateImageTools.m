//
//  HQTextEdiateImageTools.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/25.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQTextEdiateImageTools.h"
#import "HQEdiateImageController.h"
#import "HQEdiateImageTextView.h"

@interface HQTextEdiateImageTools ()<UITextViewDelegate>


@property (nonatomic) UIView *drawMenuView;
@property (nonatomic) UISlider *colorSlider;
@property (nonatomic) UITextView *textView;
@property (nonatomic) UIView *topView;
@property (nonatomic) UIView *begView;



@end



@implementation HQTextEdiateImageTools

- (instancetype)initWithEdiateController:(HQEdiateImageController *)ediateController andEdiateToolInfo:(HQEdiateToolInfo *)toolInfo{
    return [super initWithEdiateController:ediateController  andEdiateToolInfo:toolInfo];
}
- (void)setUpCurrentEdiateStatus{
    [super setUpCurrentEdiateStatus];
    _drawMenuView =  [[UIView alloc] initWithFrame:CGRectMake(0, APP_Frame_Height, App_Frame_Width, 80)];
    _drawMenuView.backgroundColor = [UIColor clearColor];//BOTTOMBARCOLOR
    UIButton *cancelBut = [[UIButton alloc] initWithFrame:CGRectMake(10, 5, 40, 40)];
    [cancelBut setImage:[UIImage imageNamed:@"EdiateImageDismissBut"] forState:UIControlStateNormal];
    [cancelBut addTarget:self action:@selector(clearDrawViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_drawMenuView addSubview:cancelBut];
    
    UIButton *addButton  = [[UIButton alloc] initWithFrame:CGRectMake(App_Frame_Width-50, 5, 40, 40)];
    [addButton setImage:[UIImage imageNamed:@"addActionIcon"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_drawMenuView addSubview:addButton];
    
    [self.imageEdiateController.view addSubview:_drawMenuView];
    
    [self setMenuView];

    [UIView animateWithDuration:0.15 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionCurlDown animations:^{
        _drawMenuView.top = APP_Frame_Height- 80;
    } completion:nil];
    
}
- (void)setMenuView{
    _colorSlider = [self defaultSliderWithWidth:_drawMenuView.width - 40];
    _colorSlider.left = 20;
    _colorSlider.top  = 40;
    [_colorSlider addTarget:self action:@selector(colorSliderDidChange:) forControlEvents:UIControlEventValueChanged];
    _colorSlider.backgroundColor = [UIColor colorWithPatternImage:[self colorSliderBackground]];
    _colorSlider.value = 0;
    [_drawMenuView addSubview:_colorSlider];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake((App_Frame_Width-100)/2.0, 5, 100, 20)];
    title.text = @"滑动调整色值";
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont systemFontOfSize:14];
    title.textColor = CANCELBUTTONCOLOR;
    [_drawMenuView addSubview:title];
    
}
- (UISlider*)defaultSliderWithWidth:(CGFloat)width{
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, width, 30)];
    
    [slider setMaximumTrackImage:[UIImage new] forState:UIControlStateNormal];
    [slider setMinimumTrackImage:[UIImage new] forState:UIControlStateNormal];
    [slider setThumbImage:[UIImage new] forState:UIControlStateNormal];
    slider.thumbTintColor = [UIColor whiteColor];
    
    return slider;
}
- (void)clearDrawViewButtonAction:(UIButton *)sender{
    [self clearCurrentEdiateStatus];
    self.imageEdiateController.scrollView.panGestureRecognizer.minimumNumberOfTouches = 1;
    [UIView animateWithDuration:0.15 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionCurlDown animations:^{
        _drawMenuView.top = APP_Frame_Height;
    } completion:^(BOOL finished){
        [_drawMenuView removeFromSuperview];
        [self.imageEdiateController resetBottomViewEdiateStatus];
    }];
}
- (void)addButtonAction:(UIButton *)sender{
    [self showTextViewWithText:nil];
}
- (void)colorSliderDidChange:(UISlider *)slider{
    if(slider.value<1/3.0){
         _colorSlider.thumbTintColor =  [UIColor colorWithWhite:slider.value/0.3 alpha:1];
    }else {
     _colorSlider.thumbTintColor = [UIColor colorWithHue:((slider.value-1/3.0)/0.7)*2/3.0 saturation:1 brightness:1 alpha:1];
  }
}


- (void)showTextViewWithText:(NSString *)text{
    if (_begView == nil) {
        _begView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, APP_Frame_Height-80)];
        _begView.backgroundColor = [UIColor  clearColor];
        [self.imageEdiateController.view addSubview:_begView];
        
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, 40)];
        _topView.backgroundColor = [UIColor clearColor];
        [_begView addSubview:_topView];
        
        UIButton *cancelButton  = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 40, 40)];
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_topView addSubview:cancelButton];
        
        UIButton *finishButton = [[UIButton alloc] initWithFrame:CGRectMake(App_Frame_Width-50, 0, 40, 40)];
        [finishButton setTitle:@"完成" forState:UIControlStateNormal];
        [finishButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [finishButton setTitleColor:CANCELBUTTONCOLOR forState:UIControlStateNormal];
        [finishButton addTarget:self action:@selector(finishButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_topView addSubview:finishButton];
        
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 40, [UIScreen mainScreen].bounds.size.width,APP_Frame_Height-40)];
        UIColor *textViewBgColor = [UIColor blackColor];
        _textView.backgroundColor = [textViewBgColor colorWithAlphaComponent:0.85];
        [_textView setTextColor:[UIColor whiteColor]];
        [_textView setFont:[UIFont systemFontOfSize:30]];
        [_textView setReturnKeyType:UIReturnKeyDone];
        _textView.delegate = self;
        [_begView addSubview:_textView];
    }
    [_textView setText:text];
    _begView.transform = CGAffineTransformMakeTranslation(0, 600);
    _topView.hidden = YES;
    [UIView animateWithDuration:0.35  animations:^{
        _begView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        _topView.hidden = NO;
    }];
    [_textView becomeFirstResponder];
}

- (void)clearCurrentEdiateStatus{
    [super clearCurrentEdiateStatus];
}
- (void)cancelButtonAction:(UIButton *)sender{
    [self dismissBegView];
}
- (void)finishButtonAction:(UIButton *)sender{
    [self dismissBegView];
    if (_textView.text.length <= 0) {
        return;
    }
    NSAttributedString *att = [[NSAttributedString alloc] initWithString:_textView.text attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20],NSFontAttributeName:[UIColor redColor]}];
//    HQEdiateImageTextView *textView = [[HQEdiateImageTextView alloc] initWithTextTool:self  withSuperView:self.imageEdiateController.ediateImageView  andAttrubuteString:att];
    HQEdiateImageTextView *textView  = [[HQEdiateImageTextView alloc] initWithFrame:CGRectMake(10, 100, 200, 100)];
    textView.backgroundColor = [UIColor  redColor];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(150, 10, 50, 50)];
    button.backgroundColor = [UIColor grayColor];
    [button addTarget:self action:@selector(textViewTestAction:) forControlEvents:UIControlEventTouchUpInside];
    [textView addSubview:button];
//    [textView refreshContentImageView];
//    [textView setUpGesture];
    [self.imageEdiateController.ediateImageView addSubview:textView];
}
- (void)textViewTestAction:(UIButton *)sender{
    NSLog(@"textViewTestAction");
}
- (void)dismissBegView{
    _topView.hidden =  YES;
    [_textView resignFirstResponder];
    [UIView animateWithDuration:0.35  animations:^{
        _begView.transform = CGAffineTransformMakeTranslation(0, 600);
    }   completion:^(BOOL finished) {
        [_begView removeFromSuperview];
        _begView = nil;
    }];
}




- (UIImage*)colorSliderBackground{
    CGSize size = _colorSlider.frame.size;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect frame = CGRectMake(5, (size.height-10)/2, size.width-10, 5);
    CGPathRef path = [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:5].CGPath;
    CGContextAddPath(context, path);
    CGContextClip(context);
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGFloat components[] = {
        0.0f, 0.0f, 0.0f, 1.0f,
        1.0f, 1.0f, 1.0f, 1.0f,
        1.0f, 0.0f, 0.0f, 1.0f,
        1.0f, 1.0f, 0.0f, 1.0f,
        0.0f, 1.0f, 0.0f, 1.0f,
        0.0f, 1.0f, 1.0f, 1.0f,
        0.0f, 0.0f, 1.0f, 1.0f
    };
    
    size_t count = sizeof(components)/ (sizeof(CGFloat)* 4);
    CGFloat locations[] = {0.0f, 0.9/3.0, 1/3.0, 1.5/3.0, 2/3.0, 2.5/3.0, 1.0};
    
    CGPoint startPoint = CGPointMake(5, 0);
    CGPoint endPoint = CGPointMake(size.width-5, 0);
    
    CGGradientRef gradientRef = CGGradientCreateWithColorComponents(colorSpaceRef, components, locations, count);
    
    CGContextDrawLinearGradient(context, gradientRef, startPoint, endPoint, kCGGradientDrawsAfterEndLocation);
    
    UIImage *tmp = UIGraphicsGetImageFromCurrentImageContext();
    
    CGGradientRelease(gradientRef);
    CGColorSpaceRelease(colorSpaceRef);
    
    UIGraphicsEndImageContext();
    
    return tmp;
}

- (void)executeWithCompletionBlock:(void (^)(UIImage *, NSError *, NSDictionary *))completionBlock{
    
}
//图片
+ (UIImage*)defaultIconImage{
    return [UIImage imageNamed:@"ToolText"];
}

//工具名称
+ (NSString*)defaultTitle{
    return nil;
    
}
//显示顺序
+ (NSUInteger)orderNum{
    return 5;
}

@end
