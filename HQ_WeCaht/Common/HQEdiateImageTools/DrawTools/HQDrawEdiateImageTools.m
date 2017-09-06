//
//  HQDrawEdiateImageTools.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/25.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQDrawEdiateImageTools.h"
#import "HQEdiateImageController.h"
#import "UIColor+Extern.h"

static CGFloat LINEWIDTH = 5;



@interface HQDrawEdiateImageTools (){
     CGSize _originalImageSize;        //初始大小
    CGPoint _prevDraggingPosition; //拖动的起点
}
@property (nonatomic) UIView *drawMenuView;
@property (nonatomic) UIImageView *drawImageView;
@property (nonatomic) UISlider *colorSlider;
@property (nonatomic) UISlider *widthSlider;
@property (nonatomic) UIView *strokePreview;
@property (nonatomic) UIView *strokePreviewBackground;
@property (nonatomic) UIImageView *eraserIcon; //橡皮擦
@property (nonatomic) NSMutableArray *lineArray;
@property (nonatomic,strong) UIButton *backButton;



@end

@implementation HQDrawEdiateImageTools

- (instancetype)initWithEdiateController:(HQEdiateImageController *)ediateController andEdiateToolInfo:(HQEdiateToolInfo *)toolInfo{
    return [super initWithEdiateController:ediateController andEdiateToolInfo:toolInfo];
}

- (void)setUpCurrentEdiateStatus{
    [super setUpCurrentEdiateStatus];
    
    _originalImageSize = self.imageEdiateController.ediateImageView.image.size;
    
    [self setDrawImageView];
    
    self.imageEdiateController.ediateImageView.userInteractionEnabled = YES;
    self.imageEdiateController.scrollView.panGestureRecognizer.minimumNumberOfTouches = 2;
    self.imageEdiateController.scrollView.panGestureRecognizer.delaysTouchesBegan = NO;
    self.imageEdiateController.scrollView.pinchGestureRecognizer.delaysTouchesBegan = NO;
    
    
    _drawMenuView =  [[UIView alloc] initWithFrame:CGRectMake(0, APP_Frame_Height, App_Frame_Width, 80)];
    _drawMenuView.backgroundColor = [UIColor clearColor];//BOTTOMBARCOLOR
    UIButton *cancelBut = [[UIButton alloc] initWithFrame:CGRectMake(0, 5, 40, 40)];
    [cancelBut setImage:[UIImage imageNamed:@"EdiateImageDismissBut"] forState:UIControlStateNormal];
    [cancelBut addTarget:self action:@selector(clearDrawViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_drawMenuView addSubview:cancelBut];
    
   _backButton  = [[UIButton alloc] initWithFrame:CGRectMake(App_Frame_Width-40, 5, 40, 30)];
    [_backButton setImage:[UIImage imageNamed:@"EditImageRevokeDisable_21x21_"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_drawMenuView addSubview:_backButton];
    
    [self.imageEdiateController.view addSubview:_drawMenuView];
    
    [self setMenuView];
    
    [UIView animateWithDuration:0.15 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionCurlDown animations:^{
        _drawMenuView.top = APP_Frame_Height- 80;
    } completion:nil];
}

- (void)executeWithCompletionBlock:(void (^)(UIImage *, NSError *, NSDictionary *))completionBlock{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [self buildImage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(image, nil, nil);
            self.imageEdiateController.scrollView.panGestureRecognizer.minimumNumberOfTouches = 1;
            [self clearDrawViewButtonAction:nil];
        });
    });
}
- (void)clearDrawViewButtonAction:(UIButton *)sender{
    [self clearCurrentEdiateStatus];
    self.imageEdiateController.scrollView.panGestureRecognizer.minimumNumberOfTouches = 1;
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
- (void)setDrawImageView{
    _drawImageView = [[UIImageView alloc] initWithFrame:self.imageEdiateController.ediateImageView.bounds];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drawingViewDidPan:)];
    panGesture.maximumNumberOfTouches = 1;
    
    _drawImageView.userInteractionEnabled = YES;
    [_drawImageView addGestureRecognizer:panGesture];
    
    [self.imageEdiateController.ediateImageView addSubview:_drawImageView];
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
    
//    _widthSlider = [self defaultSliderWithWidth:_colorSlider.width];
//    _widthSlider.left = 10;
//    _widthSlider.top = _colorSlider.bottom + 5;
//    [_widthSlider addTarget:self action:@selector(widthSliderDidChange:) forControlEvents:UIControlEventValueChanged];
//    _widthSlider.value = 0;
//    _widthSlider.backgroundColor =    [UIColor colorWithPatternImage:[self widthSliderBackground]];
//    [_drawMenuView addSubview:_widthSlider];
//    
    
    _strokePreview = [[UIView alloc] initWithFrame:CGRectMake(0, 40, 30,30)];
    _strokePreview.layer.cornerRadius = 15;
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
    _strokePreview.backgroundColor = [self colorForValue:0.5];
//    [self widthSliderDidChange:_widthSlider];
    
    _drawMenuView.clipsToBounds = NO;

}

#pragma mark  ------ SliderAction -------
- (void)widthSliderDidChange:(UISlider *)sender{
    CGFloat scale = MAX(0.05, LINEWIDTH);
    _strokePreview.transform = CGAffineTransformMakeScale(scale, scale);
    _strokePreview.layer.borderWidth = 2/scale;
}
- (void)colorSliderDidChange:(UISlider *)sender{
    if(_eraserIcon.hidden){
     _strokePreview.backgroundColor = [self colorForValue:_colorSlider.value];
        _strokePreviewBackground.backgroundColor = _strokePreview.backgroundColor;
        _colorSlider.thumbTintColor = _strokePreview.backgroundColor;
    }
}
- (void)strokePreviewDidTap:(UITapGestureRecognizer *)tap{
    _eraserIcon.hidden = !_eraserIcon.hidden;
    
    if(_eraserIcon.hidden){
        [self colorSliderDidChange:_colorSlider];
    }else{
        _strokePreview.backgroundColor = [UIColor blackColor];
        _strokePreviewBackground.backgroundColor = _strokePreview.backgroundColor;
    }
}
- (void)drawingViewDidPan:(UIPanGestureRecognizer *)sender{
    CGPoint currentDraggingPosition = [sender locationInView:_drawImageView];
    
    if(sender.state == UIGestureRecognizerStateBegan){
        _prevDraggingPosition = currentDraggingPosition;
        DrawPointLine *line = [[DrawPointLine alloc] init];
        line.drawColor = _strokePreview.backgroundColor;
        line.drawWidth = LINEWIDTH;
        [self.lineArray addObject:line];
    }
    if(sender.state != UIGestureRecognizerStateEnded){
        if (_lineArray.count) {
            DrawPointLine *line = [_lineArray lastObject];
            DrawChildLine *childLine = [[DrawChildLine alloc] init];
            childLine.begPoint = _prevDraggingPosition;
            childLine.endPoint = currentDraggingPosition;
            [line.childLines addObject:childLine];
        }
        [self drawLine:_prevDraggingPosition to:currentDraggingPosition];
    }
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self setReBackButtonStatusWith:self.lineArray?YES:NO];
    }
    _prevDraggingPosition = currentDraggingPosition;
}
- (void)backButtonAction:(UIButton *)sender{
    if (self.lineArray.count <= 0) {
        return;
    }
    [_drawImageView removeFromSuperview];
    [self setDrawImageView];
    [self.lineArray removeLastObject];
    for (DrawPointLine *line in self.lineArray) {
        [self reBackDrawLineWithLine:line];
    }
    if (self.lineArray.count  <= 0) {
        [self setReBackButtonStatusWith:NO];
    }
}
- (UIColor*)colorForValue:(CGFloat)value{
    if(value<1/3.0){
        return [UIColor colorWithWhite:value/0.3 alpha:1];
    }
    return [UIColor colorWithHue:((value-1/3.0)/0.7)*2/3.0 saturation:1 brightness:1 alpha:1];
}
//画线
-(void)drawLine:(CGPoint)from to:(CGPoint)to{
    CGSize size = _drawImageView.frame.size;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [_drawImageView.image drawAtPoint:CGPointZero];
    
    
    CGFloat strokeWidth = MAX(1, LINEWIDTH);
    UIColor *strokeColor = _strokePreview.backgroundColor;
    
    CGContextSetLineWidth(context, strokeWidth);
    CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    if(!_eraserIcon.hidden){
        CGContextSetBlendMode(context, kCGBlendModeClear);
    }
    
    CGContextMoveToPoint(context, from.x, from.y);
    CGContextAddLineToPoint(context, to.x, to.y);
    CGContextStrokePath(context);
    
    _drawImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
}

////撤销时 划线
- (void)reBackDrawLineWithLine:(DrawPointLine *)line{
    CGSize size = _drawImageView.frame.size;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [_drawImageView.image drawAtPoint:CGPointZero];
    
    
    CGFloat strokeWidth = MAX(1, line.drawWidth);
    UIColor *strokeColor = line.drawColor;
    
    CGContextSetLineWidth(context, strokeWidth);
    CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    for (DrawChildLine *childLine in line.childLines) {
        CGContextMoveToPoint(context, childLine.begPoint.x, childLine.begPoint.y);
        CGContextAddLineToPoint(context, childLine.endPoint.x, childLine.endPoint.y);
        CGContextStrokePath(context);
    }
    _drawImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
}
#pragma mark- other
- (UISlider*)defaultSliderWithWidth:(CGFloat)width{
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, width, 30)];
    
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
    
//    UIColor *color = [UIColor blackColor];
    UIColor *color = CANCELBUTTONCOLOR;
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
- (UIImage*)buildImage{
    UIGraphicsBeginImageContextWithOptions(_originalImageSize, NO, self.imageEdiateController.ediateImageView.image.scale);
    
    [self.imageEdiateController.ediateImageView.image drawAtPoint:CGPointZero];
    [_drawImageView.image drawInRect:CGRectMake(0, 0, _originalImageSize.width, _originalImageSize.height)];
    UIImage *tmp = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return tmp;
}

- (void)setReBackButtonStatusWith:(BOOL)active{
    
    [UIView animateKeyframesWithDuration: 0.35 delay: 0 options: 0 animations: ^{
        [UIView addKeyframeWithRelativeStartTime: 0
                                relativeDuration: 1 / 3.0
                                      animations: ^{
                                          if (active) {
                                            _backButton.transform = CGAffineTransformMakeScale(1.5, 1.5);
                                          }else{
                                              _backButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                          }
                                      }];
//        [UIView addKeyframeWithRelativeStartTime: 1 / 3.0
//                                relativeDuration: 1 / 3.0
//                                      animations: ^{
//                                          _backButton.transform = CGAffineTransformMakeScale(0.8, 0.8);
//                                      }];
//        [UIView addKeyframeWithRelativeStartTime: 2 / 3.0
//                                relativeDuration: 1 / 3.0
//                                      animations: ^{
//                                          _backButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
//                                      }];
    } completion: ^(BOOL finished) {
        
    }];
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

- (NSMutableArray *)lineArray{
    if (_lineArray == nil) {
        _lineArray  = [NSMutableArray new];
    }
    return _lineArray;
}

@end









@implementation DrawPointLine

- (instancetype)init{
    self = [super init ];
    if (self) {
        _childLines = [NSMutableArray new];
    }
    return self;
}
@end






@implementation DrawChildLine


@end
