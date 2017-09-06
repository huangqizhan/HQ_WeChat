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

@interface HQRQCodeView ()

@property (nonatomic,strong) ReCodeIndicatorView *indicatorView;
@property (nonatomic,strong) UIImageView *recodeLineView;
@property (nonatomic,strong) NSTimer *timer;

@end


@implementation HQRQCodeView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        ////scanAnimationImage
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
        self.recodeLineView.top = self.ScanRect.origin.x;
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
