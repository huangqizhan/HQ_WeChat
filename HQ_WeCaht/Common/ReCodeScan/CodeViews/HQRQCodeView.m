//
//  HQRQCodeView.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/8/30.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQRQCodeView.h"

static CGFloat ScanRentangleWidth  = 200.0;
static CGFloat ScabRentangleHeight = 200.0;
////距离导航栏的距离
static CGFloat NavigationBarDistance = 100;

@interface HQRQCodeView ()<CAAnimationDelegate>

@property (nonatomic,strong) ReCodeIndicatorView *indicatorView;
@property (nonatomic,strong) UIImageView *recodeLineView;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) AnimationShapeLayer *animationLayer;
@property (nonatomic,copy) void (^endComplition)();

@end


@implementation HQRQCodeView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addPinGesture];
    }
    return self;
}
- (void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetRGBFillColor(context, 0, 0, 0, 0.6);
    
    //扫码区域上面填充
    CGRect scanrect = CGRectMake(0, 0, App_Frame_Width, NavigationBarDistance);
    CGContextFillRect(context, scanrect);
    
    //扫码区域左边填充
    scanrect = CGRectMake(0, scanrect.size.height, (App_Frame_Width- ScanRentangleWidth)/2.0,ScabRentangleHeight);
    CGContextFillRect(context, scanrect);
    
    //扫码区域右边填充
    scanrect = CGRectMake(scanrect.size.width+ScanRentangleWidth, scanrect.origin.y, App_Frame_Width -scanrect.origin.x+ScanRentangleWidth ,ScabRentangleHeight);
    CGContextFillRect(context, scanrect);
    
    //扫码区域下面填充
    scanrect = CGRectMake(0, scanrect.origin.y+scanrect.size.height, App_Frame_Width,APP_Frame_Height-scanrect.origin.y+scanrect.size.height-64);
    CGContextFillRect(context, scanrect);
    //执行绘画
    CGContextStrokePath(context);
    
    
    //中间画矩形(正方形)
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 1);
    
    CGContextAddRect(context, CGRectMake((App_Frame_Width - ScanRentangleWidth)/2.0, NavigationBarDistance, ScanRentangleWidth, ScabRentangleHeight));
    
    CGContextStrokePath(context);

    self.ScanRect = CGRectMake((App_Frame_Width - ScanRentangleWidth)/2.0, NavigationBarDistance, ScanRentangleWidth, ScabRentangleHeight);
    
    ////四个拐角
    CGContextSetStrokeColorWithColor(context, CANCELBUTTONCOLOR.CGColor);
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    
    CGContextSetLineWidth(context, 5);
    
    //左上角线
    CGContextMoveToPoint(context, self.ScanRect.origin.x+ScanRentangleWidth/10.0, NavigationBarDistance-2);
    CGContextAddLineToPoint(context, self.ScanRect.origin.x-2, NavigationBarDistance-2);
     CGContextAddLineToPoint(context, self.ScanRect.origin.x-2, NavigationBarDistance+ScanRentangleWidth/10.0);
  
    
    
     //左下角线
    
    CGContextMoveToPoint(context, self.ScanRect.origin.x-2, NavigationBarDistance + ScabRentangleHeight - ScanRentangleWidth/10.0);
    CGContextAddLineToPoint(context, self.ScanRect.origin.x-2, NavigationBarDistance + ScabRentangleHeight+2);
    CGContextAddLineToPoint(context, self.ScanRect.origin.x+ScanRentangleWidth/10.0, NavigationBarDistance+ScabRentangleHeight + 2);
    
    
    ////右下角线
    CGContextMoveToPoint(context, self.ScanRect.origin.x+2 +self.ScanRect.size.width - ScanRentangleWidth/10.0, NavigationBarDistance + ScabRentangleHeight +2);
    CGContextAddLineToPoint(context, self.ScanRect.origin.x+2 +self.ScanRect.size.width, NavigationBarDistance + ScabRentangleHeight +2);
    CGContextAddLineToPoint(context, self.ScanRect.origin.x+2 +self.ScanRect.size.width, NavigationBarDistance + ScabRentangleHeight - ScanRentangleWidth/10.0);
    
    ///有上角线
    CGContextMoveToPoint(context, self.ScanRect.origin.x+2 +self.ScanRect.size.width, NavigationBarDistance + ScanRentangleWidth/10.0);
    CGContextAddLineToPoint(context, self.ScanRect.origin.x+2 +self.ScanRect.size.width, NavigationBarDistance-2);
    CGContextAddLineToPoint(context, self.ScanRect.origin.x+2 +self.ScanRect.size.width-ScanRentangleWidth/10.0, NavigationBarDistance-2);
    
      CGContextStrokePath(context);
}

- (void)addPinGesture{
    UIPinchGestureRecognizer *gesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(pinGestureAction:)];
    [self addGestureRecognizer:gesture];
}

- (void)pinGestureAction:(UIPinchGestureRecognizer *)pingesture{
    if (pingesture.state == UIGestureRecognizerStateBegan) {
        if (_delegate && [_delegate respondsToSelector:@selector(HQRQCodeView:gestureDidBegin:)]) {
            [_delegate HQRQCodeView:self gestureDidBegin:pingesture];
        }
    }
    if (pingesture.state == UIGestureRecognizerStateChanged) {
        if (_delegate && [_delegate respondsToSelector:@selector(HQRQCodeView:gestureDidChange:)]) {
            [_delegate HQRQCodeView:self gestureDidChange:pingesture];
        }
    }
    if (pingesture.state == UIGestureRecognizerStateEnded) {
        if (_delegate && [_delegate respondsToSelector:@selector(HQRQCodeView:gestureDidEnd:)]) {
            [_delegate HQRQCodeView:self gestureDidEnd:pingesture];
        }
    }
}
- (void)startRecodeWithContent:(NSString *)content{
    [self.indicatorView startRecodeWithContent:content];
}
- (void)beginRecodeWhenDidEndAnimation{
    [self.indicatorView removeFromSuperview];
    [self showRecodeAniamtionView];
}
#pragma mark ------- 显示扫码条 -----
- (void)showRecodeAniamtionView{
    [self addSubview:self.recodeLineView];
    
    _timer = [NSTimer  scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(showRecodeViewTimerAction) userInfo:nil repeats:YES];
    [_timer fire];
}
- (void)dismissReCodeView{
    [self.recodeLineView removeFromSuperview];
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}
- (void)showRecodeViewTimerAction{
    if (self.recodeLineView.origin.y > self.ScanRect.origin.y + self.ScanRect.size.height-10) {
        self.recodeLineView.top = self.ScanRect.origin.y;
    }
    [UIView animateWithDuration:0.01 animations:^{
        self.recodeLineView.top += 0.5;
    }];
}
- (ReCodeIndicatorView *)indicatorView{
    if (_indicatorView == nil) {
        _indicatorView  = [[ReCodeIndicatorView alloc] initWithFrame:CGRectMake(self.ScanRect.origin.x + (self.ScanRect.size.width - 100)/2.0, self.ScanRect.origin.y + (self.ScanRect.size.height  - 70)/2.0, 100, 70)];
        [self addSubview:_indicatorView];
    }
    return _indicatorView;
}
- (UIImageView *)recodeLineView{
    if (_recodeLineView == nil) {
        _recodeLineView = [[UIImageView alloc] initWithFrame:CGRectMake(self.ScanRect.origin.x, self.ScanRect.origin.y, self.ScanRect.size.width, 10)];
        _recodeLineView.image = [UIImage imageNamed:@"scanAnimationImage"];
    }
    return _recodeLineView;
}
- (AnimationShapeLayer *)animationLayer{
    if (_animationLayer == nil) {
        _animationLayer = [[AnimationShapeLayer alloc] initWithFrame:CGRectMake(self.ScanRect.origin.x-5, self.ScanRect.origin.y-5, self.ScanRect.size.width+10, self.ScanRect.size.height+10)];
    }
    return _animationLayer;
}

- (Barcode *)processMetadataObject:(AVMetadataMachineReadableCodeObject *)code{
    Barcode *barcode =  [Barcode new];
    barcode.metadataObject = code;
    barcode.codeString = code.stringValue;
    CGMutablePathRef cornersPath = CGPathCreateMutable();
    CGPoint point;
    CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)code.corners[0], &point);
//     NSLog(@"point = %@",NSStringFromCGPoint(point));
    CGPathMoveToPoint(cornersPath, nil, point.x, point.y);
    for (int i = 1; i < code.corners.count; i++) {
        CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)code.corners[i], &point);
        CGPathAddLineToPoint(cornersPath, nil, point.x, point.y);
//        NSLog(@"point = %@",NSStringFromCGPoint(point));
    }
    CGPathCloseSubpath(cornersPath);
    barcode.cornersPath = [UIBezierPath bezierPathWithCGPath:cornersPath];
    CGPathRelease(cornersPath);
    barcode.boundingBoxPath = [UIBezierPath bezierPathWithRect:code.bounds];
    barcode.codeFrame = code.bounds;
    return barcode;
    
    /*
     1 查询Barcode对象字典，看是否有相同内容的Barcode已经存在。
     2 如果没有，创建一个Barcode对象并将其加入到字典中。
     3 存储二维码的元数据到新创建的Barcode对象中。
     4 创建用于存储绘制二维码四个角路径的cornersPath。
     5 使用CoreGraphics转换第一个角的坐标为CGPoint实例。
     6 从第五步构造的角开始绘制路径。
     7 循环遍历其它三个角，创建相应的路径。
     8 绘制第四个点到第一个点路径后，关闭路径。
     9 通过cornersPath创建UIBezierPath对象并将其存储到Barcode对象中。
     10 通过bezierPathWithRect:方法创建边框块。
     11 返回Barcode对象。
     */
}
- (void)recodeDidFinishAnimationActionWithRect:(CGRect)rect  Complite:(void (^)())complite{
    _endComplition = complite;
    [self addSubview:self.animationLayer];
     AudioServicesPlaySystemSound(1360);
    [self startRecodeWithAnimationWithRect:rect];
}
- (void)startRecodeWithAnimationWithRect:(CGRect )rect{
    
    [UIView animateWithDuration:0.15 animations:^{
        self.animationLayer.frame = rect;
    } completion:^(BOOL finished) {
        self.animationLayer.backgroundColor = [UIColor colorWithRed:(85.0)/255.0 green:(185.0)/255.0 blue:(50.0)/255.0 alpha:0.5];
        if (_endComplition) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 _endComplition();
            });
        }
    }];
//    CAKeyframeAnimation *animationLayer = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
//    animationLayer.duration = 0.35;
//    animationLayer.fillMode = kCAFillModeForwards;
//    animationLayer.removedOnCompletion=NO;
//    animationLayer.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    NSMutableArray *values = [NSMutableArray array];
//    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
//    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(rect.size.width/self.width, rect.size.height/self.height, 1.0)]];
//    animationLayer.values = values;
//    [self.animationLayer.layer addAnimation:animationLayer forKey:nil];
}
- (void)animationDidStart:(CAAnimation *)anim{
    
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (_endComplition) {
        _endComplition();
    }
}


@end


@implementation AnimationShapeLayer

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetRGBFillColor(context, 0, 0, 0, 0.6);
    
    ////四个拐角
    CGContextSetStrokeColorWithColor(context, CANCELBUTTONCOLOR.CGColor);
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    
    CGContextSetLineWidth(context, 2);
    
    //左上角线
    CGContextMoveToPoint(context, ScanRentangleWidth/20.0, 1);
    CGContextAddLineToPoint(context, 1, 1);
    CGContextAddLineToPoint(context, 1, ScanRentangleWidth/20.0);
    
    //左下角线
    
    CGContextMoveToPoint(context, 1,  self.frame.size.height - ScanRentangleWidth/20.0);
    CGContextAddLineToPoint(context, 1, self.frame.size.height - 1);
    CGContextAddLineToPoint(context, ScanRentangleWidth/20.0, self.frame.size.height - 1);
    
    
    ////右下角线
    CGContextMoveToPoint(context, self.frame.size.width - ScanRentangleWidth/20.0, self.frame.size.height  - 2);
    CGContextAddLineToPoint(context,  self.frame.size.width - 1,   self.frame.size.width - 1);
    CGContextAddLineToPoint(context, self.frame.size.width - 1 , self.frame.size.height  - ScanRentangleWidth/20.0);
    
    ///右上角线
    CGContextMoveToPoint(context, self.frame.size.width - 1 , ScanRentangleWidth/20.0);
    CGContextAddLineToPoint(context, self.frame.size.width - 1 , 1);
    CGContextAddLineToPoint(context, self.frame.size.width-ScanRentangleWidth/20.0, 1);
    
    CGContextStrokePath(context);

}
@end





@interface ReCodeIndicatorView ()

@property (nonatomic,strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic,strong) UILabel *contentLabel;


@end

@implementation ReCodeIndicatorView


- (instancetype)initWithFrame:(CGRect)frame{
    self  = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.indicatorView];
        [self addSubview:self.contentLabel];
    }
    return self;
}
- (void)startRecodeWithContent:(NSString *)content{
    self.contentLabel.text = content;
    [self.indicatorView startAnimating];
}
- (void)stopReCode{
    [self removeFromSuperview];
}
- (UIActivityIndicatorView *)indicatorView{
    if (_indicatorView == nil) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicatorView.frame = CGRectMake((self.width - 50)/2.0, 0, 50, 50);
    }
    return _indicatorView;
}
- (UILabel *)contentLabel{
    if (_contentLabel == nil) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, self.width, 20)];
        _contentLabel.textColor = [UIColor whiteColor];
        _contentLabel.font = [UIFont systemFontOfSize:15];
        _contentLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _contentLabel;
}


@end



@implementation Barcode

@end
