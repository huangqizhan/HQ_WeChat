//
//  HQTextEdiateImageTools.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/25.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HQTextEdiateImageTools.h"
#import "HQEdiateImageController.h"
#import "HQEdiateImageTextView.h"
#import "NSDate+Extension.h"



@interface HQTextEdiateImageTools ()<UITextViewDelegate>{
    
       UIImage *_originalImage;
    
}


@property (nonatomic) HQEdiateImageTextView *currntTextView;
@property (nonatomic) NSMutableArray *textViewArray;
@property (nonatomic) UIView *normalView;
@property (nonatomic) UIView *deleteView;
@property (nonatomic) UILabel *deleteStatusLabel;
@property (nonatomic) UIButton *deleteBut;
@property (nonatomic) UIView *drawMenuView;
@property (nonatomic) UISlider *colorSlider;
@property (nonatomic) UITextView *textView;
@property (nonatomic) UIView *topView;
@property (nonatomic) UIView *begView;
@property (nonatomic,assign) NSTimeInterval lastSoundTime;
@property (nonatomic,assign) CGRect keyboardFrame;






@end



@implementation HQTextEdiateImageTools

- (instancetype)initWithEdiateController:(HQEdiateImageController *)ediateController andEdiateToolInfo:(HQEdiateToolInfo *)toolInfo{
    return [super initWithEdiateController:ediateController  andEdiateToolInfo:toolInfo];
}
- (void)setUpCurrentEdiateStatus{
    [super setUpCurrentEdiateStatus];
    _drawMenuView =  [[UIView alloc] initWithFrame:CGRectMake(0, APP_Frame_Height, App_Frame_Width, 80)];
    _drawMenuView.backgroundColor = [UIColor clearColor];//BOTTOMBARCOLOR
    
    _normalView = [[UIView alloc] initWithFrame:_drawMenuView.bounds];
    [_drawMenuView addSubview:_normalView];
    
    UIButton *cancelBut = [[UIButton alloc] initWithFrame:CGRectMake(10, 5, 40, 40)];
    [cancelBut setImage:[UIImage imageNamed:@"EdiateImageDismissBut"] forState:UIControlStateNormal];
    [cancelBut addTarget:self action:@selector(clearDrawViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_normalView addSubview:cancelBut];
    
    UIButton *addButton  = [[UIButton alloc] initWithFrame:CGRectMake(App_Frame_Width-50, 5, 40, 40)];
    [addButton setImage:[UIImage imageNamed:@"addActionIcon"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_normalView addSubview:addButton];
    
    _originalImage = self.imageEdiateController.originalImage;
    
    [self.imageEdiateController.view addSubview:_drawMenuView];
    
     self.imageEdiateController.scrollView.panGestureRecognizer.minimumNumberOfTouches = 2;
    
    [self setMenuView];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [UIView animateWithDuration:0.15 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionCurlDown animations:^{
        _drawMenuView.top = APP_Frame_Height- 80;
    } completion:nil];
    
}
- (void)keyboardWillHide:(NSNotification *)notification{
    self.keyboardFrame = CGRectZero;
}
- (void)keyboardFrameWillChange:(NSNotification *)notification{
    self.keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keybordSize = [value CGRectValue].size;
    NSValue *keyAnimationTime  =[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval keyBordTimerval;
    [keyAnimationTime getValue:&keyBordTimerval];
    [UIView animateWithDuration:keyBordTimerval animations:^{
        _textView.height = (APP_Frame_Height-40) - keybordSize.height;
    }];
}
- (void)setMenuView{
    _colorSlider = [self defaultSliderWithWidth:_drawMenuView.width - 40];
    _colorSlider.left = 20;
    _colorSlider.top  = 40;
    [_colorSlider addTarget:self action:@selector(colorSliderDidChange:) forControlEvents:UIControlEventValueChanged];
    _colorSlider.backgroundColor = [UIColor colorWithPatternImage:[self colorSliderBackground]];
    _colorSlider.value = 0.30;
    [self colorSliderDidChange:_colorSlider];
    [_normalView addSubview:_colorSlider];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake((App_Frame_Width-100)/2.0, 5, 100, 20)];
    title.text = @"滑动调整色值";
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont systemFontOfSize:14];
    title.textColor = CANCELBUTTONCOLOR;
    [_normalView addSubview:title];
    
}
- (UISlider*)defaultSliderWithWidth:(CGFloat)width{
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, width, 30)];
    
    [slider setMaximumTrackImage:[UIImage new] forState:UIControlStateNormal];
    [slider setMinimumTrackImage:[UIImage new] forState:UIControlStateNormal];
    [slider setThumbImage:[UIImage new] forState:UIControlStateNormal];
    slider.thumbTintColor = [UIColor whiteColor];
    
    return slider;
}
- (void)clearDrawViewButtonAction:(UIButton *)sender{
    [self clearCurrentEdiateStatus];
    self.imageEdiateController.scrollView.panGestureRecognizer.minimumNumberOfTouches = 1;
    [UIView animateWithDuration:0.15 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionCurlDown animations:^{
        _drawMenuView.top = APP_Frame_Height;
    } completion:^(BOOL finished){
        [_drawMenuView removeFromSuperview];
        [self clearAltextView];
        [self removeKeyBoardNotication];
        [self.imageEdiateController resetBottomViewEdiateStatus];
    }];
}
- (void)clearAltextView{
    for (HQEdiateImageTextView *textView in self.textViewArray) {
        [textView removeFromSuperview];
    }
    [self.textViewArray removeAllObjects];
}
- (void)removeKeyBoardNotication{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}
- (void)addButtonAction:(UIButton *)sender{
    [self showTextViewWithText:nil];

}
- (void)colorSliderDidChange:(UISlider *)slider{
    if(slider.value<1/3.0){
         _colorSlider.thumbTintColor =  [UIColor colorWithWhite:slider.value/0.3 alpha:1];
    }else {
     _colorSlider.thumbTintColor = [UIColor colorWithHue:((slider.value-1/3.0)/0.7)*2/3.0 saturation:1 brightness:1 alpha:1];
  }
}

- (void)showTextViewWithText:(NSAttributedString *)attStr{
    if (_begView == nil) {
        _begView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, APP_Frame_Height-80)];
        _textView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.85];
        [self.imageEdiateController.view addSubview:_begView];
        
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, 40)];
        _topView.backgroundColor = [UIColor clearColor];
        [_begView addSubview:_topView];
        
        UIButton *cancelButton  = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 40, 40)];
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_topView addSubview:cancelButton];
        
        UIButton *finishButton = [[UIButton alloc] initWithFrame:CGRectMake(App_Frame_Width-50, 0, 40, 40)];
        [finishButton setTitle:@"完成" forState:UIControlStateNormal];
        [finishButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [finishButton setTitleColor:CANCELBUTTONCOLOR forState:UIControlStateNormal];
        [finishButton addTarget:self action:@selector(finishButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_topView addSubview:finishButton];
        
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 40, [UIScreen mainScreen].bounds.size.width,APP_Frame_Height-40)];
        _textView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.85];
        [_textView setTextColor:[UIColor whiteColor]];
        [_textView setFont:[UIFont systemFontOfSize:30]];
        [_textView setReturnKeyType:UIReturnKeyDone];
        _textView.delegate = self;
        [_begView addSubview:_textView];
    }
    [_textView setAttributedText:attStr];
    _begView.transform = CGAffineTransformMakeTranslation(0, 600);
    _topView.hidden = YES;
    [UIView animateWithDuration:0.35  animations:^{
        _begView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        _topView.hidden = NO;
    }];
    _textView.textColor  =_colorSlider.thumbTintColor;
    [_textView becomeFirstResponder];
}

- (void)clearCurrentEdiateStatus{
    [super clearCurrentEdiateStatus];
}
- (void)cancelButtonAction:(UIButton *)sender{
    [self dismissBegView];
}
- (void)finishButtonAction:(UIButton *)sender{
    [self dismissBegView];
    if (_textView.text.length <= 0) {
        return;
    }
    if (self.currntTextView) {
        if ([self.textViewArray containsObject:self.currntTextView]) {
            [self.currntTextView refreshContentViewWith:[self creatAttributeString]];
            return;
        }
    }
    [self addNewTextView];
}

- (void)addNewTextView{
    self.imageEdiateController.ediateImageView.userInteractionEnabled = YES;
    HQEdiateImageTextView *textView = [[HQEdiateImageTextView alloc] initWithTextTool:self  withSuperView:self.imageEdiateController.ediateImageView  andAttrubuteString:[self creatAttributeString] andWithColor:_colorSlider.thumbTintColor];
    WEAKSELF;
    [textView setTapCallBack:^(HQEdiateImageTextView *View){
        weakSelf.currntTextView = View;
        NSAttributedString *att = [[NSAttributedString alloc] initWithString:View.attrubuteString.string attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20],NSForegroundColorAttributeName:_colorSlider.thumbTintColor}];
        [weakSelf showTextViewWithText:att];
    }];
    [textView setDeleteTextViewCallBack:^(HQEdiateImageTextView *textView){
        if ([weakSelf.textViewArray containsObject:textView]) {
            [weakSelf.textViewArray removeObject:textView];
        }
    }];
    [self.textViewArray addObject:textView];
}
- (NSAttributedString *)creatAttributeString{
    NSAttributedString *att = [[NSAttributedString alloc] initWithString:_textView.text attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20],NSForegroundColorAttributeName:_colorSlider.thumbTintColor}];
    return att;
}
- (void)dismissBegView{
    _topView.hidden =  YES;
    [_textView resignFirstResponder];
    [UIView animateWithDuration:0.35  animations:^{
        _begView.transform = CGAffineTransformMakeTranslation(0, 600);
    }   completion:^(BOOL finished) {
        [_begView removeFromSuperview];
        _begView = nil;
    }];
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

- (void)executeWithCompletionBlock:(void (^)(UIImage *, NSError *, NSDictionary *))completionBlock{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self clearaAllEdiateImageViewStatus];
        UIImage *image = [self buildImage:_originalImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(image, nil, nil);
            self.imageEdiateController.scrollView.panGestureRecognizer.minimumNumberOfTouches = 1;
            [self clearDrawViewButtonAction:nil];
        });
    });    
}

- (void)setMenuViewDeleteStatusIsActive:(BOOL)active{
    if (_deleteView == nil) {
        [self createDeleteView];
    }
    [UIView animateWithDuration:0.35 animations:^{
        if (!active) {
            [_deleteBut setImage:[UIImage imageNamed:@"deleteTextIcon"] forState:UIControlStateNormal];
            _deleteStatusLabel.text = @"拖动到此处删除";
        }else{
            [_deleteBut setImage:[UIImage imageNamed:@"deleteEdiateTextViewActiveStatus"] forState:UIControlStateNormal];
            _deleteStatusLabel.text = @"松开即可删除";
        }
        _normalView.alpha = 0.0;
        _deleteView.alpha = 1.0;
    } completion:^(BOOL finished) {
        _normalView.hidden = YES;
        _deleteView.hidden = NO;
    }];
}
- (void)clearaAllEdiateImageViewStatus{
    for (HQEdiateImageTextView *textView in self.textViewArray) {
        [textView hiddenCurrentViewLayerIsBegin:NO];
    }
}
- (void)setMenuViewDefaultStatus{
    [UIView animateWithDuration:0.35 animations:^{
        _normalView.alpha = 1.0;
        _deleteView.alpha = 0.0;
    } completion:^(BOOL finished) {
        _normalView.hidden = NO;
        _deleteView.hidden = YES;
    }];
}
- (void)createDeleteView{
    _deleteView = [[UIView alloc] initWithFrame:_drawMenuView.bounds];
    _deleteBut = [[UIButton alloc] initWithFrame:CGRectMake((App_Frame_Width - 30)/2.0, 10, 30, 40)];
    _deleteStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake((App_Frame_Width-100)/2.0, _deleteBut.bottom, 100, 20)];
    _deleteStatusLabel.font = [UIFont systemFontOfSize:13];
    _deleteStatusLabel.textAlignment = NSTextAlignmentCenter;
    _deleteStatusLabel.textColor = CANCELBUTTONCOLOR;
    [_deleteView addSubview:_deleteBut];
    [_deleteView addSubview:_deleteStatusLabel];
    [_drawMenuView addSubview:_deleteView];
}

- (UIImage*)buildImage:(UIImage*)image{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    
    [image drawAtPoint:CGPointZero];
    
    CGFloat scale = image.size.width / self.imageEdiateController.ediateImageView.width;
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), scale, scale);
    [self.imageEdiateController.ediateImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *tmp = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return tmp;
}

- (void) textViewDidBeginEditing:(UITextView *)textView{
}
- (void) textViewDidChange:(UITextView *)textView{
    if (textView.text.length > 1000) { // 限制5000字内
        textView.text = [textView.text substringToIndex:1000];
    }
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){
        [self finishButtonAction:nil];
    }
    return YES;
}
//图片
+ (UIImage*)defaultIconImage{
    return [UIImage imageNamed:@"ToolText"];
}

//工具名称
+ (NSString*)defaultTitle{
    return nil;
    
}
//显示顺序
+ (NSUInteger)orderNum{
    return 5;
}

- (NSMutableArray *)textViewArray{
    if (_textViewArray  == nil) {
        _textViewArray = [NSMutableArray new];
    }
    return _textViewArray;
}
@end
