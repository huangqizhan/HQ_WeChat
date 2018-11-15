//
//  DownLoadPercentView.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/4/10.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "DownLoadPercentView.h"

#define CircleLineWidth 5
#define StartAngle -M_PI_2


@interface DownLoadPercentView ()

@property (nonatomic, strong) UILabel *percentLabel;
@property (nonatomic, strong) CAShapeLayer *backgroundLayer;
@property (nonatomic, strong) CAShapeLayer *circleLayer;
@property (nonatomic) CGPoint centerPoint;
@property (nonatomic) CGFloat percent;
@property (nonatomic) CGFloat radius;

@end


@implementation DownLoadPercentView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}
- (void)commonInit {
    CGFloat min = MIN(self.frame.size.width, self.frame.size.height);
    self.radius = (min - CircleLineWidth)  / 2;
    self.centerPoint = CGPointMake(self.frame.size.width / 2 - self.radius, self.frame.size.height / 2 - self.radius);
    self.backgroundLayer = [CAShapeLayer layer];
    [self.layer addSublayer:self.backgroundLayer];
    
    self.circleLayer = [CAShapeLayer layer];
    [self.layer addSublayer:self.circleLayer];
    
    self.percentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width / 2, self.frame.size.height / 2)];
    [self addSubview:self.percentLabel];
    [self setBackGroudCircleLayerWithFillColor:[UIColor clearColor]];
    [self setupPercentLabel];
    
}
- (void)drawCircleWithPercent:(CGFloat)percent{
    self.percent = percent;

    [self setCircleLayerWithStrokeColor:[UIColor redColor]];
    
    self.percentLabel.text = [NSString stringWithFormat:@"%%%.2f",percent];
}

- (void)setBackGroudCircleLayerWithFillColor:(UIColor *)fillColor{
    self.backgroundLayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.radius, self.radius) radius:self.radius startAngle:StartAngle endAngle:2*M_PI clockwise:YES].CGPath;
    // Center the shape in self.view
    self.backgroundLayer.position = self.centerPoint;
    
    // Configure the apperence of the circle
    self.backgroundLayer.fillColor = fillColor.CGColor;
    self.backgroundLayer.strokeColor = [UIColor lightGrayColor].CGColor;
    self.backgroundLayer.lineWidth = CircleLineWidth;
    self.backgroundLayer.rasterizationScale = 2 * [UIScreen mainScreen].scale;
    self.backgroundLayer.shouldRasterize = YES;
    self.backgroundLayer.lineCap = @"round";
}

- (void)setCircleLayerWithStrokeColor:(UIColor *)strokerColor{
    // Set up the shape of the circle
    
    CGFloat endAngle = [self calculateToValueWithPercent:self.percent];
    
    // Make a circular shape
    self.circleLayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.radius, self.radius) radius:self.radius startAngle:StartAngle endAngle:endAngle clockwise:YES].CGPath;
    
    // Center the shape in self.view
    
    self.circleLayer.position = self.centerPoint;
    
    // Configure the apperence of the circle
    self.circleLayer.fillColor = [UIColor clearColor].CGColor;
    self.circleLayer.strokeColor = strokerColor.CGColor;
    self.circleLayer.lineWidth = CircleLineWidth;
    self.circleLayer.lineCap = @"round";
    self.circleLayer.shouldRasterize = YES;
    self.circleLayer.rasterizationScale = 2 * [UIScreen mainScreen].scale;

}
- (void)setupPercentLabel {
    if (self.percentLabel) {
        NSLayoutConstraint *centerHor = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.percentLabel attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        NSLayoutConstraint *centerVer = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.percentLabel attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        
        self.percentLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:@[centerHor, centerVer]];
        [self layoutIfNeeded];
        self.percentLabel.text = [NSString stringWithFormat:@"%d%%", (int)self.percent];   
    }
}
- (CGFloat)calculateToValueWithPercent:(CGFloat)percent {
    return (StartAngle + (percent * 2 * M_PI) / 100);
}

@end



@interface CustomerProcessView ()

@property (nonatomic,strong) CAShapeLayer *shapLayer;

@end

@implementation CustomerProcessView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _shapLayer = [[CAShapeLayer alloc] init];
        _shapLayer.strokeColor = [UIColor greenColor].CGColor;
        _shapLayer.lineWidth = 30;
        [self.layer addSublayer:_shapLayer];
    }
    return self;
}

- (void)setProcess:(CGFloat)process{
    _process = process;
    [[UIColor greenColor] setFill];
    
    UIBezierPath *path  = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 15)];
    [path addLineToPoint:CGPointMake(150*_process, 15)];
    _shapLayer.path = path.CGPath;

    
}
@end
