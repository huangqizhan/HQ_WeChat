//
//  HQEdiateImageTextView.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/8/18.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQEdiateImageTextView.h"
#import "HQTextEdiateImageTools.h"
#import "HQEdiateImageController.h"
#import "UIImage+Gallop.h"





@interface HQEdiateImageTextView ()<UIGestureRecognizerDelegate>{
    
    CGPoint _initialPoint;    //当前的中心点
    CGFloat _scale;               //当前缩放比例
    CGFloat _arg;                  //当前旋转比例
    CGFloat _initialScale;   //修改前的缩放比例
    CGFloat _initialArg;     //修改前旋转比例
    
}

@property (nonatomic,copy) NSAttributedString *attrubuteString;
@property (nonatomic) UIImageView *contentImageView;
@property CGFloat lastRotation;


@end

@implementation HQEdiateImageTextView


- (instancetype)initWithTextTool:(HQTextEdiateImageTools *)textTool withSuperView:(UIView *)superView andAttrubuteString:(NSAttributedString *)attrubute{
    CGRect frame = [HQEdiateImageTextView caculateContentStringWithAttrubuteString:attrubute andTool:textTool];
    self = [super initWithFrame:frame];
    if (self) {
        _scale = _initialScale = 1;
        _textTool = textTool;
        _attrubuteString = attrubute;
        [superView addSubview:self];
        [self createContentImageView];
        [self setUpGesture];
        
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 1.0;
        
    }
     return self;
}
- (void)createContentImageView{
    
    UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height )];
    tempLabel.numberOfLines = 0;
    tempLabel.attributedText = _attrubuteString;
    UIImage *image = [UIImage lw_imageFromView:tempLabel];
    _contentImageView = [[UIImageView alloc] initWithImage:image];
    _contentImageView.center = CGPointMake(self.width/2.0, self.height/2.0);
    _contentImageView.userInteractionEnabled = YES;
    [self addSubview:_contentImageView];
    
}

- (void)setUpGesture{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textvViewTapAction:)];
    tap.numberOfTapsRequired = 2;
    tap.delegate = self;
    UIPinchGestureRecognizer *pin = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(textActionPinAction:)];
    pin.delegate = self;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(textViewPanAction:)];
    pan.delegate = self;
    UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateViewAction:)];
    
    [self addGestureRecognizer:tap];
    [self addGestureRecognizer:pan];
    [self addGestureRecognizer:pin];
    [self addGestureRecognizer:rotationGestureRecognizer];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return YES;
}
////双击
- (void)textvViewTapAction:(UITapGestureRecognizer *)tap{
    if (_tapCallBack) {
        _tapCallBack(self.attrubuteString);
    }
}
////拖动
- (void)textViewPanAction:(UIPanGestureRecognizer *)pan{
    CGPoint p = [pan translationInView:self.superview];
    if (pan.state == UIGestureRecognizerStateBegan) {
        _initialPoint = self.center;
    }
    self.center = CGPointMake(_initialPoint.x + p.x, _initialPoint.y + p.y);
}
////放缩
- (void)textActionPinAction:(UIPinchGestureRecognizer *)pinchGestureRecognizer{

    UIView *view = pinchGestureRecognizer.view;
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        pinchGestureRecognizer.scale = 1;
        return;
    }
    
    /*
     if(sender.state == UIGestureRecognizerStateBegan){
     //缩放按钮中点与表情view中点的直线距离
     tmpR = sqrt(p.x*p.x + p.y*p.y); //开根号
     //缩放按钮中点与表情view中点连线的斜率角度
     tmpA = atan2(p.y, p.x);//反正切函数
     
     _initialArg = _arg;
     _initialScale = _scale;
     }
     
  
     
     */
//    static CGFloat tmpR = 1; //临时缩放值
//    static CGFloat tmpA = 0; //临时旋转值
    CGPoint location = [pinchGestureRecognizer locationInView:view.superview];
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [view.superview bringSubviewToFront:view];
//        _initialPoint = [self convertPoint:_contentImageView.center toView:self.superview];
//        
//        _initialArg = _arg;
//        _initialScale = _scale;

    }
//    CGPoint P  = CGPointMake(_initialPoint.x - location.x , _initialPoint.y - location.y );
//    //拖动后的距离
//    _scale = sqrt(location.x*location.x + location.y*location.y) / _initialScale;
//    // 拖动后的旋转角度
//    CGFloat arg = atan2(P.y, P.x);
//    //旋转角度 //原始角度+拖动后的角度 - 拖动前的角度
//    _arg   = _initialArg + arg - tmpA;
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        if (pinchGestureRecognizer.numberOfTouches > 1) {
            view.transform = CGAffineTransformScale(pinchGestureRecognizer.view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
            view.center = CGPointMake(location.x, location.y);
//            NSLog(@"scale = %f", _scale );
//            self.transform = CGAffineTransformIdentity;
//            view.transform = CGAffineTransformMakeScale(_scale, _scale); //缩放
//            view.transform = CGAffineTransformMakeRotation(_arg); //旋转
            pinchGestureRecognizer.scale = 1;
        }
    }
}
///旋转
- (void)rotateViewAction:(UIRotationGestureRecognizer *)roteGesture{
    UIView *view = roteGesture.view;
    if (roteGesture.state == UIGestureRecognizerStateBegan) {
        [self.superview bringSubviewToFront:view];
    }
    if (roteGesture.state == UIGestureRecognizerStateEnded) {
        self.lastRotation = 0;
        return;
    }
    CGPoint location = [roteGesture locationInView:self.superview];
    if (roteGesture.state == UIGestureRecognizerStateChanged && roteGesture.numberOfTouches > 1) {
        view.center = CGPointMake(location.x, location.y);
        CGAffineTransform currentTransform = view.transform;
        CGFloat rotation = 0.0 - (self.lastRotation - roteGesture.rotation);
        CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform, rotation);
        view.transform = newTransform;
        roteGesture.rotation = 0;
        self.lastRotation = roteGesture.rotation;
    }
}
+  (CGRect)caculateContentStringWithAttrubuteString:(NSAttributedString *)attrubuteStr andTool:(HQTextEdiateImageTools *)textTool{
    if (attrubuteStr == nil) {
        attrubuteStr = [[NSAttributedString alloc] initWithString:@""];
    }
    CGRect frame = [attrubuteStr boundingRectWithSize:CGSizeMake(textTool.imageEdiateController.ediateImageView.width-10, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
//    frame.size.width -= 10;
//    frame.size.height = 10;
    frame.origin.x = (textTool.imageEdiateController.ediateImageView.width-frame.size.width)/2.0;
    frame.origin.y = (textTool.imageEdiateController.ediateImageView.height -frame.size.height)/2.0;
    
    return frame;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    if ([self pointInside:point withEvent:event]) {
        return self;
    }
    return nil;
}

@end




