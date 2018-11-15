//
//  HQFaceMorePageView.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/3.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HQFaceMorePageView.h"


@interface HQFaceMorePageView ()


@end


@implementation HQFaceMorePageView


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = IColor(237, 237, 246);
        for (int i = 0; i < 8; i ++) {
            HQMoreViewItem *button = [[HQMoreViewItem alloc] init];
            [self addSubview:button];
            button.tag = 100+i;
            [button addTarget:self action:@selector(morePageViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        }

    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat btnW   = (self.width - 2*15)/4;
    CGFloat btnH  = (self.height - 2*15)/2;
    for (int i = 0; i < 8; i ++) {
        HQMoreViewItem *btn = [self viewWithTag:i+100];
        btn.width = btnW;
        btn.height = btnH;
        btn.x  = 15 + (i % 4)*btnW;
        btn.y  = 15 + (i / 4)*btnH;
    }
}
- (void)setMoreFaceArray:(NSArray *)moreFaceArray{
    _moreFaceArray = moreFaceArray;
    for (int i = 0; i < 8; i ++) {
        HQMoreViewItem *btn = [self viewWithTag:i+100];
        btn.faceModel = _moreFaceArray[i];
    }
}
- (void)morePageViewButtonAction:(HQMoreViewItem *)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(HQFaceMorePageViewDidSeleteItem:andFaceModel:)]) {
        [_delegate HQFaceMorePageViewDidSeleteItem:self andFaceModel:sender.faceModel];
    }
}

@end












@interface HQMoreViewItem ()

@property (nonatomic,strong)UIButton *button;
@property (nonatomic,strong)UILabel *contentLabel;


@end

@implementation HQMoreViewItem

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.button];
        [self addSubview:self.contentLabel];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.button.frame = CGRectMake(self.width/8.0, 0, self.width*6.0/8.0, self.height*3./5.0);
    self.contentLabel.frame = CGRectMake(0, self.height*3/5.0, self.width, self.height*2/5.0);
}
- (void)setFaceModel:(HQFaceModel *)faceModel{
    _faceModel = faceModel;
    [self.button setImage:[UIImage imageNamed:_faceModel.face_name] forState:UIControlStateNormal];
    [self.contentLabel setText:_faceModel.itemTitle];
    if (_faceModel.face_name.length == 0 || _faceModel.face_name == nil) {
        self.hidden = YES;
    }else{
        self.hidden = NO;
    }
    
}
- (UIButton *)button{
    if (_button == nil) {
        _button = [[UIButton alloc] init];
        _button.layer.masksToBounds = YES;
        _button.layer.cornerRadius = 10.0;
        _button.layer.borderWidth = 0.5;
        _button.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _button.backgroundColor = [UIColor whiteColor];
        _button.userInteractionEnabled = NO;
        [_button setBackgroundImage:[UIImage gxz_imageWithColor:IColor(200, 200, 200)] forState:UIControlStateHighlighted];
    }
    return _button;
}

- (UILabel *)contentLabel{
    if (_contentLabel == nil) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        _contentLabel.font = [UIFont systemFontOfSize:13];
        _contentLabel.textColor = [UIColor grayColor];
    }
    return _contentLabel;
}
@end
