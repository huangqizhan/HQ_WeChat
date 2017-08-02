//
//  HQDrawEdiateImageTools.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/25.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQDrawEdiateImageTools.h"
#import "HQEdiateImageController.h"


@interface HQDrawEdiateImageTools (){
     CGSize _originalImageSize;        //初始大小
}

@property (nonatomic) UIView *drawMenuView;
@property (nonatomic) UIImageView *drawImageView;
@property (nonatomic) UISlider *colorSlider;
@property (nonatomic) UISlider *widthSlider;
@property (nonatomic) UIView *strokePreview;
@property (nonatomic) UIView *strokePreviewBackground;
@property (nonatomic) UIImageView *eraserIcon; //橡皮擦



@end

@implementation HQDrawEdiateImageTools

- (instancetype)initWithEdiateController:(HQEdiateImageController *)ediateController andEdiateToolInfo:(HQEdiateToolInfo *)toolInfo{
    return [super initWithEdiateController:ediateController andEdiateToolInfo:toolInfo];
}

- (void)setUpCurrentEdiateStatus{
    [super setUpCurrentEdiateStatus];
    
    _originalImageSize = self.imageEdiateController.ediateImageView.image.size;
    
    _drawImageView = [[UIImageView alloc] initWithFrame:self.imageEdiateController.ediateImageView.bounds];
    _drawImageView.backgroundColor = [UIColor redColor];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drawingViewDidPan:)];
    panGesture.maximumNumberOfTouches = 1;
    
    _drawImageView.userInteractionEnabled = YES;
    [_drawImageView addGestureRecognizer:panGesture];
    
    [self.imageEdiateController.ediateImageView addSubview:_drawImageView];
    self.imageEdiateController.ediateImageView.userInteractionEnabled = YES;
    self.imageEdiateController.scrollView.panGestureRecognizer.minimumNumberOfTouches = 2;
    self.imageEdiateController.scrollView.panGestureRecognizer.delaysTouchesBegan = NO;
    self.imageEdiateController.scrollView.pinchGestureRecognizer.delaysTouchesBegan = NO;
    
    
    _drawMenuView =  [[UIView alloc] initWithFrame:CGRectMake(0, APP_Frame_Height, App_Frame_Width, 120)];
    _drawMenuView.backgroundColor = [UIColor redColor];
    UIButton *cancelBut = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [cancelBut setImage:[UIImage imageNamed:@"EmoticonCloseButton_16x16_"] forState:UIControlStateNormal];
    [cancelBut addTarget:self action:@selector(clearDrawViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_drawMenuView addSubview:cancelBut];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(App_Frame_Width-80, 0, 60, 40)];
    [backButton setImage:[UIImage imageNamed:@"EditImageRevokeDisable_21x21_"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_drawMenuView addSubview:backButton];
    
    
    [self.imageEdiateController.view addSubview:_drawMenuView];
    
    [self setMenuView];
    
    [UIView animateWithDuration:0.15 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionCurlDown animations:^{
        _drawMenuView.top = APP_Frame_Height- 120;
    } completion:nil];
}


- (void)clearDrawViewButtonAction:(UIButton *)sender{
    [self clearCurrentEdiateStatus];
    [UIView animateWithDuration:0.15 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionCurlDown animations:^{
        _drawMenuView.top = APP_Frame_Height;
    } completion:^(BOOL finished){
        [_drawMenuView removeFromSuperview];
        [_drawImageView removeFromSuperview];
        [self.imageEdiateController resetBottomViewEdiateStatus];
    }];
}
- (void)clearCurrentEdiateStatus{
    [super clearCurrentEdiateStatus];
    [UIView animateWithDuration:0.15 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionCurlDown animations:^{
         _drawMenuView.top = APP_Frame_Height;
    } completion:^(BOOL finished){
        [_drawMenuView removeFromSuperview];
        [_drawImageView removeFromSuperview];
    }];
}


- (void)setMenuView{
    CGFloat W = 80;
    
    _colorSlider = [self defaultSliderWithWidth:_drawMenuView.width - W - 20];
    _colorSlider.left = 10;
    _colorSlider.top  = 40;
    [_colorSlider addTarget:self action:@selector(colorSliderDidChange:) forControlEvents:UIControlEventValueChanged];
    _colorSlider.backgroundColor = [UIColor colorWithPatternImage:[self colorSliderBackground]];
    _colorSlider.value = 0;
    [_drawMenuView addSubview:_colorSlider];
    
    _widthSlider = [self defaultSliderWithWidth:_colorSlider.width];
    _widthSlider.left = 10;
    _widthSlider.top = _colorSlider.bottom + 5;
    [_widthSlider addTarget:self action:@selector(widthSliderDidChange:) forControlEvents:UIControlEventValueChanged];
    _widthSlider.value = 0.1;
    _widthSlider.backgroundColor = [UIColor colorWithPatternImage:[self widthSliderBackground]];
    [_drawMenuView addSubview:_widthSlider];
    
    
    _strokePreview = [[UIView alloc] initWithFrame:CGRectMake(0, 35, W - 10, W - 10)];
    _strokePreview.layer.cornerRadius = _strokePreview.height/2;
    _strokePreview.layer.borderWidth = 1;
    _strokePreview.layer.borderColor = [[UIColor blackColor] CGColor];
    _strokePreview.center = CGPointMake(_drawMenuView.width-W/2-10, (_drawMenuView.height-40)/2+35);
    [_drawMenuView addSubview:_strokePreview];
    
    _strokePreviewBackground = [[UIView alloc] initWithFrame:_strokePreview.frame];
    _strokePreviewBackground.layer.cornerRadius = _strokePreviewBackground.height/2;
    _strokePreviewBackground.alpha = 0.3;
    [_strokePreviewBackground addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(strokePreviewDidTap:)]];
    [_drawMenuView insertSubview:_strokePreviewBackground aboveSubview:_strokePreview];

    _eraserIcon = [[UIImageView alloc] initWithFrame:_strokePreview.frame];
    _eraserIcon.image  =  [UIImage imageNamed:@"eraser"];
    _eraserIcon.hidden = YES;
    [_drawMenuView addSubview:_eraserIcon];
    
    [self colorSliderDidChange:_colorSlider];
    [self widthSliderDidChange:_widthSlider];
    
    _drawMenuView.clipsToBounds = NO;
}

#pragma mark  ------ SliderAction -------
- (void)widthSliderDidChange:(UISlider *)sender{
    
}
- (void)colorSliderDidChange:(UISlider *)sender{
    
}
- (void)strokePreviewDidTap:(UITapGestureRecognizer *)tap{
    
}
- (void)drawingViewDidPan:(UIPanGestureRecognizer *)sender{
    NSLog(@"drawingViewDidPan");
}
- (void)backButtonAction:(UIButton *)sender{
    
}
#pragma mark- other

- (UISlider*)defaultSliderWithWidth:(CGFloat)width{
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, width, 34)];
    
    [slider setMaximumTrackImage:[UIImage new] forState:UIControlStateNormal];
    [slider setMinimumTrackImage:[UIImage new] forState:UIControlStateNormal];
    [slider setThumbImage:[UIImage new] forState:UIControlStateNormal];
    slider.thumbTintColor = [UIColor whiteColor];
    
    return slider;
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

- (UIImage*)widthSliderBackground{
    CGSize size = _widthSlider.frame.size;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor *color = [UIColor blackColor];
    
    CGFloat strRadius = 1;
    CGFloat endRadius = size.height/2 * 0.6;
    
    CGPoint strPoint = CGPointMake(strRadius + 5, size.height/2 - 2);
    CGPoint endPoint = CGPointMake(size.width-endRadius - 1, strPoint.y);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path, NULL, strPoint.x, strPoint.y, strRadius, -M_PI/2, M_PI-M_PI/2, YES);
    CGPathAddLineToPoint(path, NULL, endPoint.x, endPoint.y + endRadius);
    CGPathAddArc(path, NULL, endPoint.x, endPoint.y, endRadius, M_PI/2, M_PI+M_PI/2, YES);
    CGPathAddLineToPoint(path, NULL, strPoint.x, strPoint.y - strRadius);
    
    CGPathCloseSubpath(path);
    
    CGContextAddPath(context, path);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillPath(context);
    
    UIImage *tmp = UIGraphicsGetImageFromCurrentImageContext();
    
    CGPathRelease(path);
    
    UIGraphicsEndImageContext();
    
    return tmp;
}
//图片
+ (UIImage*)defaultIconImage{
    return [UIImage imageNamed:@"ToolDraw"];
}

//工具名称
+ (NSString*)defaultTitle{
    return nil;
    
}
//显示顺序
+ (NSUInteger)orderNum{
    return 1;
}

@end
