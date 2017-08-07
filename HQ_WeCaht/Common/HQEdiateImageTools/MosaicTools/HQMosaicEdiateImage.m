//
//  HQMosaicEdiateImage.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/25.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQMosaicEdiateImage.h"
#import "HQEdiateImageController.h"
#import "UIColor+Extern.h"




@interface HQMosaicEdiateImage (){
    
    CGSize _originalImageSize;        //初始大小
    
}

@property (nonatomic) MosaicView *mosaicView;
@property (nonatomic) UISlider *widthSlider;
@property (nonatomic) UIView *drawMenuView;
@property (nonatomic) UIView *strokePreview;
@property (nonatomic) NSMutableArray *lineArray;

@end


@implementation HQMosaicEdiateImage
- (instancetype)initWithEdiateController:(HQEdiateImageController *)ediateController andEdiateToolInfo:(HQEdiateToolInfo *)toolInfo{
    return [super initWithEdiateController:ediateController andEdiateToolInfo:toolInfo];
}


- (void)setUpCurrentEdiateStatus{
    [super setUpCurrentEdiateStatus];
    
    [self setUpMosicView];
    
    [self.imageEdiateController.ediateImageView addSubview:_mosaicView];
    
    self.imageEdiateController.ediateImageView.userInteractionEnabled = YES;
    self.imageEdiateController.scrollView.panGestureRecognizer.minimumNumberOfTouches = 2;
    self.imageEdiateController.scrollView.panGestureRecognizer.delaysTouchesBegan = NO;
    self.imageEdiateController.scrollView.pinchGestureRecognizer.delaysTouchesBegan = NO;
    
    
    _drawMenuView =  [[UIView alloc] initWithFrame:CGRectMake(0, APP_Frame_Height, App_Frame_Width, 100)];
    _drawMenuView.backgroundColor = [UIColor redColor];
    UIButton *cancelBut = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [cancelBut setImage:[UIImage imageNamed:@"EmoticonCloseButton_16x16_"] forState:UIControlStateNormal];
    [cancelBut addTarget:self action:@selector(clearDrawViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_drawMenuView addSubview:cancelBut];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(App_Frame_Width-40, 0, 40, 30)];
    [backButton setImage:[UIImage imageNamed:@"EditImageRevokeDisable_21x21_"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_drawMenuView addSubview:backButton];
    
    
    [self.imageEdiateController.view addSubview:_drawMenuView];
    
    [self setMenuView];
    
    [UIView animateWithDuration:0.15 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionCurlDown animations:^{
        _drawMenuView.top = APP_Frame_Height- 100;
    } completion:nil];
}
- (void)setUpMosicView{
    CIImage *ciImage = [[CIImage alloc] initWithImage:self.imageEdiateController.ediateImageView.image];
    //生成马赛克
    CIFilter *filter = [CIFilter filterWithName:@"CIPixellate"];
    [filter setValue:ciImage  forKey:kCIInputImageKey];
    //马赛克像素大小
    [filter setValue:@(100) forKey:kCIInputScaleKey];
    CIImage *outImage = [filter valueForKey:kCIOutputImageKey];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:outImage fromRect:[outImage extent]];
    UIImage *showImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    
    _originalImageSize = self.imageEdiateController.ediateImageView.image.size;
    
    _mosaicView = [[MosaicView alloc] initWithFrame:self.imageEdiateController.ediateImageView.bounds];
    _mosaicView.surfaceImage = self.imageEdiateController.ediateImageView.image;
    _mosaicView.image = showImage;
    _mosaicView.linesArray = self.lineArray;
}

- (void)clearCurrentEdiateStatus{
    [super clearCurrentEdiateStatus];
    
    [UIView animateWithDuration:0.15 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionCurlDown animations:^{
        _drawMenuView.top = APP_Frame_Height;
    } completion:^(BOOL finished){
        [_drawMenuView removeFromSuperview];
        [_mosaicView removeFromSuperview];
    }];
}

- (void)clearDrawViewButtonAction:(UIButton *)sender{
    [self clearCurrentEdiateStatus];
    [UIView animateWithDuration:0.15 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionCurlDown animations:^{
        _drawMenuView.top = APP_Frame_Height;
    } completion:^(BOOL finished){
        [_drawMenuView removeFromSuperview];
        [_mosaicView removeFromSuperview];
        [self.imageEdiateController resetBottomViewEdiateStatus];
    }];
}
- (void)backButtonAction:(UIButton *)sender{
    [_mosaicView  removeFromSuperview];
    [self setUpMosicView];
    [self.imageEdiateController.ediateImageView addSubview:_mosaicView];
    [_mosaicView  drawOndo];
}
- (void)setMenuView{
    CGFloat W = 80;
    _widthSlider = [self defaultSliderWithWidth:_drawMenuView.width - W - 20];
    _widthSlider.left = 10;
    _widthSlider.top = 40;
    [_widthSlider addTarget:self action:@selector(widthSliderDidChange:) forControlEvents:UIControlEventValueChanged];
    _widthSlider.value = 0;
    _widthSlider.backgroundColor =    [UIColor colorWithPatternImage:[self widthSliderBackground]];
    [_drawMenuView addSubview:_widthSlider];
    [self widthSliderDidChange:_widthSlider];
    _drawMenuView.clipsToBounds = NO;
}
- (void)widthSliderDidChange:(UISlider *)slider{
//    CGFloat scale = MAX(0.05, _widthSlider.value);
//    _strokePreview.transform = CGAffineTransformMakeScale(scale, scale);
//    _strokePreview.layer.borderWidth = 2/scale;
}

- (UISlider*)defaultSliderWithWidth:(CGFloat)width{
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, width, 34)];
    
    [slider setMaximumTrackImage:[UIImage new] forState:UIControlStateNormal];
    [slider setMinimumTrackImage:[UIImage new] forState:UIControlStateNormal];
    [slider setThumbImage:[UIImage new] forState:UIControlStateNormal];
    slider.thumbTintColor = [UIColor whiteColor];
    
    return slider;
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



- (void)executeWithCompletionBlock:(void (^)(UIImage *, NSError *, NSDictionary *))completionBlock{
    
}
//图片
+ (UIImage*)defaultIconImage{
    return [UIImage imageNamed:@"ToolMasaic"];
}

//工具名称
+ (NSString*)defaultTitle{
    return nil;
    
}
//显示顺序
+ (NSUInteger)orderNum{
    return 2;
}
- (NSMutableArray *)lineArray{
    if (_lineArray == nil) {
        _lineArray  = [NSMutableArray new];
    }
    return _lineArray;
}
@end





@interface MosaicView ()

@property (nonatomic, strong) UIImageView *surfaceImageView;

@property (nonatomic, strong) CALayer *imageLayer;

@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@property (nonatomic, assign) CGMutablePathRef path;



@end


@implementation MosaicView

- (void)dealloc{
    if (self.path) {
        CGPathRelease(_path);
    }
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        //添加imageview（surfaceImageView）到self上
        self.surfaceImageView = [[UIImageView alloc]initWithFrame:self.bounds];
        [self addSubview:self.surfaceImageView];
        //添加layer（imageLayer）到self上
        self.imageLayer = [CALayer layer];
        self.imageLayer.frame = self.bounds;
        [self.layer addSublayer:self.imageLayer];
        
        self.shapeLayer = [CAShapeLayer layer];
        self.shapeLayer.frame = self.bounds;
        self.shapeLayer.lineCap = kCALineCapRound;
        self.shapeLayer.lineJoin = kCALineJoinRound;
        //手指移动时 画笔的宽度
        self.shapeLayer.lineWidth = 20.f;
        self.shapeLayer.strokeColor = [UIColor blueColor].CGColor;
        self.shapeLayer.fillColor = nil;
        
        [self.layer addSublayer:self.shapeLayer];
        self.imageLayer.mask = self.shapeLayer;
        
        self.path = CGPathCreateMutable();
    }
    return self;
}
- (void)drawOndo{
//    if ([self.undoManager canUndo]) {
//        [self.undoManager undo];
//    }
    if (self.linesArray.count) {
        [self.linesArray removeLastObject];
        for (MosaicLine *line in self.linesArray) {
            [self beginRebackDrawLine:line];
            for (NSValue *value in line.endDrawPoints) {
                [self rebackDrawWithPoint:[value CGPointValue]];
            }
        }
    }
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
//    [self.undoManager beginUndoGrouping];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    [self begDrawLineWithPoint:point];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    MosaicLine *line  = [[MosaicLine alloc] init];
    line.begPoint = point;
    [self addLineWithMosaicPoint:point];
}

- (void)begDrawLineWithPoint:(CGPoint)point{
    MosaicLine *line = [[MosaicLine alloc] init];
    line.begPoint = point;
    [self.linesArray addObject:line];
    CGPathMoveToPoint(self.path, NULL, point.x, point.y);
    CGMutablePathRef path = CGPathCreateMutableCopy(self.path);
    self.shapeLayer.path = path;
    CGPathRelease(path);
}
- (void)addLineWithMosaicPoint:(CGPoint )point{
    if (self.linesArray.count) {
        MosaicLine *lastLine = [self.linesArray lastObject];
        [lastLine.endDrawPoints addObject:[NSValue valueWithCGPoint:point]];
        CGPathAddLineToPoint(self.path, NULL, point.x, point.y);
        CGMutablePathRef path = CGPathCreateMutableCopy(self.path);
        CGContextRef currentContext = UIGraphicsGetCurrentContext();
        CGContextAddPath(currentContext, path);
        [[UIColor blueColor] setStroke];
        CGContextDrawPath(currentContext, kCGPathStroke);
        self.shapeLayer.path = path;
        CGPathRelease(path);
    }
}
- (void)beginRebackDrawLine:(MosaicLine *)line{
    CGPathMoveToPoint(self.path, NULL, line.begPoint.x, line.begPoint.y);
    CGMutablePathRef path = CGPathCreateMutableCopy(self.path);
    self.shapeLayer.path = path;
    CGPathRelease(path);
}
- (void)rebackDrawWithPoint:(CGPoint )point{
    CGPathAddLineToPoint(self.path, NULL, point.x, point.y);
    CGMutablePathRef path = CGPathCreateMutableCopy(self.path);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextAddPath(currentContext, path);
    [[UIColor blueColor] setStroke];
    CGContextDrawPath(currentContext, kCGPathStroke);
    self.shapeLayer.path = path;
    CGPathRelease(path);
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
//      [self.undoManager endUndoGrouping];
}
- (void)setImage:(UIImage *)image{
    //底图
    _image = image;
    self.imageLayer.contents = (id)image.CGImage;
}

- (void)setSurfaceImage:(UIImage *)surfaceImage{
    //顶图
    _surfaceImage = surfaceImage;
    self.surfaceImageView.image = surfaceImage;
}

@end



@implementation MosaicLine

- (instancetype)init{
    self = [super init];
    if (self) {
        _endDrawPoints = [ NSMutableArray new];
    }
    return self;
}

@end
