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
    
    CGPoint _initialPoint;
    
}

@property (nonatomic,copy) NSAttributedString *attrubuteString;
@property (nonatomic) UIImageView *contentImageView;

@end

@implementation HQEdiateImageTextView


- (instancetype)initWithTextTool:(HQTextEdiateImageTools *)textTool withSuperView:(UIView *)superView andAttrubuteString:(NSAttributedString *)attrubute{
    CGRect frame = [HQEdiateImageTextView caculateContentStringWithAttrubuteString:attrubute andTool:textTool];
    self = [super initWithFrame:frame];
    if (self) {
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
    [self addGestureRecognizer:tap];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(textViewPanAction:)];
    pan.delegate = self;
    [self addGestureRecognizer:pan];
    
    UIPinchGestureRecognizer *pin = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(textActionPinAction:)];
    pin.delegate = self;
    [self addGestureRecognizer:pin];

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchbegin");
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return YES;
}
- (void)textvViewTapAction:(UITapGestureRecognizer *)tap{
    if (_tapCallBack) {
        _tapCallBack(self.attrubuteString);
    }
}
- (void)textViewPanAction:(UIPanGestureRecognizer *)pan{
    CGPoint p = [pan translationInView:self.superview];
    if (pan.state == UIGestureRecognizerStateBegan) {
        _initialPoint = self.center;
    }
    self.center = CGPointMake(_initialPoint.x + p.x, _initialPoint.y + p.y);
}
- (void)textActionPinAction:(UIPinchGestureRecognizer *)pin{

    NSLog(@"textActionPinAction");
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




