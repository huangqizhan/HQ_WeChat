//
//  HQFacePageView.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/1.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HQFacePageView.h"

#define ICEmotionMaxRows 3
#define ICEmotionMaxCols 7
#define ICEmotionPageSize ((ICEmotionMaxRows * ICEmotionMaxCols) - 1)


@interface HQFacePageView ()

@property (nonatomic, weak) UIButton *deleteBtn;
@property (nonatomic,strong) NSMutableArray *emojButtons;
@property (nonatomic,strong) HQDrowView *drowView;

@end


@implementation HQFacePageView


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteBtn setImage:[UIImage imageNamed:@"emotion_delete"] forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(deleteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:deleteBtn];
        self.deleteBtn       =  deleteBtn;
        self.backgroundColor = IColor(237, 237, 246);
        
        _emojButtons = [NSMutableArray new];
        NSUInteger count = 20;
        for (int i = 0; i < count; i ++) {
            HQEmojButton *button = [[HQEmojButton alloc] init];
            [self addSubview:button];
            button.tag = 100+i;
            [button addTarget:self action:@selector(emotionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [_emojButtons addObject:button];
        }
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecongnizerAction:)];
        [self addGestureRecognizer:longPress];
    }
    return self;
}

- (void)longPressRecongnizerAction:(UILongPressGestureRecognizer *)longPress{
    CGPoint point = [longPress locationInView:longPress.view];
    HQEmojButton *button = [self emojButtonViewWithPoint:point];
    if (button) {
        if (longPress.state == UIGestureRecognizerStateEnded) {
            [self.drowView removeFromSuperview];
            [self emotionBtnClicked:button];
        }else{
            [self.drowView refershDrowViewWith:button];
        }
    }
}
- (HQEmojButton *)emojButtonViewWithPoint:(CGPoint )point{
    __block HQEmojButton *emojButton;
    [self.emojButtons enumerateObjectsUsingBlock:^(HQEmojButton *button, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectContainsPoint(button.frame, point)) {
            emojButton = button;
        }
    }];
    return emojButton;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat inset   = 15;
    NSUInteger count   = self.emojArray.count;
    CGFloat btnW   = (self.width - 2*inset)/ICEmotionMaxCols;
    CGFloat btnH  = (self.height - 2*inset)/ICEmotionMaxRows;
    for (int i = 0; i < count; i ++) {
        HQEmojButton *btn = [self viewWithTag:i+100];
        btn.width = btnW;
        btn.height = btnH;
        btn.x  = inset + (i % ICEmotionMaxCols)*btnW;
        btn.y  = inset + (i / ICEmotionMaxCols)*btnH;
    }
    self.deleteBtn.width  = btnW;
    self.deleteBtn.height = btnH;
    self.deleteBtn.x  = inset + (count%ICEmotionMaxCols)*btnW;
    self.deleteBtn.y = inset + (count/ICEmotionMaxCols)*btnH;

}

- (void)setEmojArray:(NSArray *)emojArray{
    _emojArray = emojArray;
    NSUInteger count = 20;
    if (_emojArray.count < 20) {
        count = _emojArray.count;
    }
    for (int i = 0; i < count; i ++) {
        HQEmojButton *button = [self viewWithTag:i+100];
        [self addSubview:button];
        button.faceModel  = _emojArray[i];
    }
}
- (void)emotionBtnClicked:(HQEmojButton *)button{
    if (_delegate && [_delegate respondsToSelector:@selector(HQFacePageViewDidSeletedItem:andFaceModel:)]) {
        [_delegate HQFacePageViewDidSeletedItem:self andFaceModel:button.faceModel];
    }
}
- (void)deleteBtnClicked:(UIButton *)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(HQFacePageViewDidDelete:)]) {
        [_delegate HQFacePageViewDidDelete:self];
    }
}

#pragma mark ------ setter   getter -------
- (HQDrowView *)drowView{
    if (_drowView == nil) {
        _drowView = [[HQDrowView alloc] initWithFrame:CGRectMake(0, 0, 60, 80)];
    }
    return _drowView;
}

@end











#pragma mark ------ 表情按钮    -------

@implementation HQEmojButton

- (instancetype)initWithFrame:(CGRect)frame{
    self= [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp{
    self.titleLabel.font = [UIFont systemFontOfSize:32.0];
    self.adjustsImageWhenHighlighted = NO;
    [self setBackgroundImage:[UIImage gxz_imageWithColor:IColor(200, 200, 200)] forState:UIControlStateHighlighted];
}

- (void)setFaceModel:(HQFaceModel *)faceModel{
    _faceModel = faceModel;
    if ([_faceModel.type isEqualToString:@"1"]) {
        [self setTitle:self.faceModel.code.emoji forState:UIControlStateNormal];
        [self setImage:nil forState:UIControlStateNormal];
    }else if ([_faceModel.type isEqualToString:@"4"]){
        
    }else {
        [self setTitle:nil forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:self.faceModel.face_name] forState:UIControlStateNormal];
    }
}

- (void)setZoomModel:(HQFaceModel *)ZoomModel{
    _ZoomModel = ZoomModel;
    if ([_ZoomModel.type isEqualToString:@"1"]) {
        [self setTitle:self.ZoomModel.code.emoji forState:UIControlStateNormal];
        [self setBackgroundImage:nil forState:UIControlStateNormal];
    } else {
        [self setTitle:nil forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:self.ZoomModel.face_name] forState:UIControlStateNormal];
    }
}

@end


@interface HQDrowView ()

@property (nonatomic,strong)HQEmojButton *seleteImage;


@end



@implementation HQDrowView





- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *begView = [[UIImageView alloc] initWithFrame:self.bounds];
        begView.image = [UIImage imageNamed:@"emoticon_keyboard_magnifier"];
        [self addSubview:begView];
        [self addSubview:self.seleteImage];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)dismissFromSuperView{
    [self removeFromSuperview];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _seleteImage.frame = CGRectMake(5, 5, self.width-10, self.height/2.0);
    
}
- (HQEmojButton *)seleteImage{
    if (_seleteImage == nil) {
        _seleteImage = [[HQEmojButton alloc] init];
    }
    return _seleteImage;
}

- (void)refershDrowViewWith:(HQEmojButton *)emojButton{
    self.seleteImage.ZoomModel = emojButton.faceModel;
    // 2、添加到windows窗口上的最后一个控件的上面
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    [window addSubview:self];
    
    // 3、设置控件的位置
    CGFloat centerX = emojButton.centerX;
    CGFloat centerY = emojButton.centerY - self.height * 0.5;
    CGPoint center = CGPointMake(centerX, centerY);
    self.center = [window convertPoint:center fromView:emojButton.superview];
    
}



@end




