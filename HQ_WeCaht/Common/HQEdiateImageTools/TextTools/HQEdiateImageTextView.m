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





@interface HQEdiateImageTextView ()<UIGestureRecognizerDelegate>

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
        self.backgroundColor = [UIColor blackColor];
//        [superView addSubview:self];
//        [self createContentImageView];
        [self setUpGesture];
    }
     return self;
}
- (void)createContentImageView{
    UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, self.width-10, self.height - 10)];
    tempLabel.numberOfLines = 0;
    tempLabel.attributedText = self.attrubuteString;
    UIImage *image = [UIImage lw_imageFromView:tempLabel];
    _contentImageView = [[UIImageView alloc] initWithImage:image];
    _contentImageView.userInteractionEnabled = YES;
    _contentImageView.backgroundColor = [UIColor redColor];
    [self addSubview:_contentImageView];
}
- (void)refreshContentImageView{
    
}
- (void)setUpGesture{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textvViewTapAction:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(textViewPanAction:)];
    pan.delegate = self;
    [self addGestureRecognizer:pan];
    
    UIPinchGestureRecognizer *pin = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(textActionPinAction:)];
    pin.delegate = self;
    [self addGestureRecognizer:pin];
    
    UIButton *but = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
    but.backgroundColor = [UIColor redColor];
    [but addTarget:self action:@selector(testButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:but];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchbegin");
}
- (void)testButtonAction:(UIButton *)sender{
    NSLog(@"testButtonAction");
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return YES;
}
- (void)textvViewTapAction:(UITapGestureRecognizer *)tap{
    NSLog(@"textvViewTapAction");
}
- (void)textViewPanAction:(UIPanGestureRecognizer *)pan{
    NSLog(@"textViewPanAction");
}
- (void)textActionPinAction:(UIPinchGestureRecognizer *)pin{
    NSLog(@"textActionPinAction");
}
+  (CGRect)caculateContentStringWithAttrubuteString:(NSAttributedString *)attrubuteStr andTool:(HQTextEdiateImageTools *)textTool{
    if (attrubuteStr == nil) {
        attrubuteStr = [[NSAttributedString alloc] initWithString:@""];
    }
    CGRect frame = [attrubuteStr boundingRectWithSize:CGSizeMake(textTool.imageEdiateController.ediateImageView.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    frame.size.width += 10;
    frame.size.height += 10;
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




