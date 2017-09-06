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


@property (nonatomic) UIImageView *contentImageView;
@property (nonatomic) UIColor *color;
@property CGFloat lastRotation;


@end

@implementation HQEdiateImageTextView


- (instancetype)initWithTextTool:(HQTextEdiateImageTools *)textTool withSuperView:(UIView *)superView andAttrubuteString:(NSAttributedString *)attrubute andWithColor:(UIColor *)color{
    CGRect frame = [HQEdiateImageTextView caculateContentStringWithAttrubuteString:attrubute andTool:textTool];
    self = [super initWithFrame:frame];
    if (self) {
        _scale = _initialScale = 1;
        _textTool = textTool;
        _attrubuteString = attrubute;
        _color = color;
        [superView addSubview:self];
        [self createContentImageView];
        [self setUpGesture];
        
        self.layer.borderColor = _color.CGColor;
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
- (void)refreshContentViewWith:(NSAttributedString *)attStr{
     _attrubuteString = attStr;
    CGRect frame = [HQEdiateImageTextView caculateContentStringWithAttrubuteString:_attrubuteString andTool:_textTool];
    self.width = frame.size.width;
    self.height = frame.size.height;
    UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height )];
    tempLabel.numberOfLines = 0;
    tempLabel.attributedText = _attrubuteString;
    UIImage *image = [UIImage lw_imageFromView:tempLabel];
    _contentImageView.image = image;
    _contentImageView.width = self.width;
    _contentImageView.height = self.height;
    _contentImageView.center = CGPointMake(self.width/2.0, self.height/2.0);
    [self hiddenCurrentViewLayerIsBegin:YES];
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
        _tapCallBack(self);
    }
}
////拖动
- (void)textViewPanAction:(UIPanGestureRecognizer *)pan{
    CGPoint p = [pan translationInView:self.superview];
    if (pan.state == UIGestureRecognizerStateBegan) {
        _initialPoint = self.center;
        [self textViewDidBeginDrag];
         [self hiddenCurrentViewLayerIsBegin:YES];
    }
    if (pan.state == UIGestureRecognizerStateEnded) {
        [self textViewDidEndDrag];
        [self hiddenCurrentViewLayerIsBegin:NO];
    }
    if (pan.state == UIGestureRecognizerStateChanged) {
        [self textViewDidChangeDrag];
        self.center = CGPointMake(_initialPoint.x + p.x, _initialPoint.y + p.y);
    }
}
////放缩
- (void)textActionPinAction:(UIPinchGestureRecognizer *)pinchGestureRecognizer{

    UIView *view = pinchGestureRecognizer.view;
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        pinchGestureRecognizer.scale = 1;
        [self hiddenCurrentViewLayerIsBegin:NO];
        return;
    }
    CGPoint location = [pinchGestureRecognizer locationInView:view.superview];
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self hiddenCurrentViewLayerIsBegin:YES];
        [view.superview bringSubviewToFront:view];
    }
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        if (pinchGestureRecognizer.numberOfTouches > 1) {
            view.transform = CGAffineTransformScale(pinchGestureRecognizer.view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
            view.center = CGPointMake(location.x, location.y);
            pinchGestureRecognizer.scale = 1;
        }
    }
}
///旋转
- (void)rotateViewAction:(UIRotationGestureRecognizer *)roteGesture{
    UIView *view = roteGesture.view;
    if (roteGesture.state == UIGestureRecognizerStateBegan) {
          [self hiddenCurrentViewLayerIsBegin:YES];
        [self.superview bringSubviewToFront:view];
    }
    if (roteGesture.state == UIGestureRecognizerStateEnded) {
        self.lastRotation = 0;
          [self hiddenCurrentViewLayerIsBegin:NO];
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
- (void)textViewDidBeginDrag{
    self.textTool.imageEdiateController.ediateImageView.clipsToBounds = NO;
    [self.textTool setMenuViewDeleteStatusIsActive:NO];
}
- (void)textViewDidEndDrag{
    self.textTool.imageEdiateController.ediateImageView.clipsToBounds = YES;
     [self.textTool setMenuViewDefaultStatus];
    CGPoint p = [self.textTool.imageEdiateController.ediateImageView convertPoint:self.center toView:self.textTool.imageEdiateController.view];
    if (![self.textTool.imageEdiateController.ediateImageView pointInside:self.center withEvent:nil]  ) {
        if (p.y <  (APP_Frame_Height-80)) {
            self.center = _initialPoint;
            return;
        }
    }
    CGPoint p1 = [self.textTool.imageEdiateController.ediateImageView convertPoint:CGPointMake(self.center.x, self.center.y+self.height/2.0) toView:self.textTool.imageEdiateController.view];
    if ((p1.y > APP_Frame_Height-80) && (p1.x > (App_Frame_Width/2.0 - 40)) && (p1.x < (App_Frame_Width/2.0 +40))) {
        if (_deleteTextViewCallBack) {
            _deleteTextViewCallBack(self);
        }
        [self removeFromSuperview];
    }
}
- (void)textViewDidChangeDrag{
    CGPoint p = [self.textTool.imageEdiateController.ediateImageView convertPoint:CGPointMake(self.center.x, self.center.y+self.height/2.0) toView:self.textTool.imageEdiateController.view];
    if ((p.y > APP_Frame_Height-80) && (p.x > (App_Frame_Width/2.0 - 40)) && (p.x < (App_Frame_Width/2.0 +40))) {
         [self.textTool setMenuViewDeleteStatusIsActive:YES];
    }else{
         [self.textTool setMenuViewDeleteStatusIsActive:NO];
    }
}
- (void)hiddenCurrentViewLayerIsBegin:(BOOL)isBegin{
    [UIView animateWithDuration:0.35 animations:^{
        if (isBegin) {
            self.layer.borderWidth = 1.0;
        }else{
            self.layer.borderWidth = 0.0;
        }
    }];

  }
@end




