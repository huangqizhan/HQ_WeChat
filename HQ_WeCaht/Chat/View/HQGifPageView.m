//
//  HQGifPageView.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/5/4.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQGifPageView.h"
#import "HQFaceModel.h"

#define  margin  10
#define itemWith  (App_Frame_Width-60)/4.0

@interface HQGifPageView ()
@property (nonatomic,strong) NSMutableArray *buttonArray;
@end

@implementation HQGifPageView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self creatSubViews];
    }
    return self;
}
- (void)creatSubViews{
    for (int i = 0; i<8; i++) {
        CGFloat itemHeght = (self.height-20)/2.0;
        HQGifButton *but = [[HQGifButton alloc] initWithFrame:CGRectMake(5+i%4*(itemWith + margin), 5+i/4*(itemHeght + margin),itemWith, itemHeght)];
        [but addTarget:self action:@selector(gifButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        but.tag = 100+i;
        [self addSubview:but];
    }
}
- (void)gifButtonAction:(HQGifButton *)sender{
    if (_clickGifClickCallBack) _clickGifClickCallBack(sender.faceModel);
}
- (void)setEmojArray:(NSArray *)emojArray{
    _emojArray = emojArray;
    if (emojArray.count == self.subviews.count) {
        for (int i = 0; i< _emojArray.count;i++ ) {
            HQFaceModel *model = _emojArray[i];
            HQGifButton *but = self.subviews[i];
            but.faceModel = model;
        }
    }
}
@end


@implementation HQGifButton

- (instancetype)initWithFrame:(CGRect)frame{
    self= [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp{
    self.adjustsImageWhenHighlighted = NO;
    [self setBackgroundImage:[UIImage gxz_imageWithColor:IColor(200, 200, 200)] forState:UIControlStateHighlighted];
    [self setImageRect:CGRectMake(10, 5, self.width-20, self.height-10)];
}
- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    return _imageRect;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    return _titleRect;
}
- (void)setFaceModel:(HQFaceModel *)faceModel{
    _faceModel = faceModel;
    NSString *path = [[NSBundle mainBundle]pathForResource:_faceModel.face_name ofType:@"gif"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    [self setImage:[UIImage imageWithData:data scale:2] forState:UIControlStateNormal];
}
@end
