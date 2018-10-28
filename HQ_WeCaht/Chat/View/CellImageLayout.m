//
//  CellImageLayout.m
//  HQ_WeChat
//
//  Created by 黄麒展 on 2018/10/26.
//  Copyright © 2018年 黄麒展. All rights reserved.
//

#import "CellImageLayout.h"

@implementation CellImageLayout
- (instancetype)initWith:(ChatMessageModel *)model{
    self = [super init];
    if (self) {
        _image = model.tempImage;
        [self _layoutImage];
    }
    return self;
}

- (void)_layoutImage{
    CGSize size = [self handleImage:_image.size];
    _imageFrame.size = size;
    _imageFrame.origin.x = App_Frame_Width-size.width-65;
    _imageFrame.origin.y = 10;
    self.cellHeight = size.height + 25;
}

// 缩放，临时的方法
- (CGSize)handleImage:(CGSize)retSize{
    CGFloat scaleH = 0.22;
    CGFloat scaleW = 0.38;
    CGFloat height = 0;
    CGFloat width = 0;
    if (retSize.height / APP_Frame_Height + 0.16 > retSize.width / App_Frame_Width) {
        height = APP_Frame_Height * scaleH;
        width = retSize.width / retSize.height * height;
    } else {
        width = App_Frame_Width * scaleW;
        height = retSize.height / retSize.width * width;
    }
    return CGSizeMake(width, height);
}
@end
