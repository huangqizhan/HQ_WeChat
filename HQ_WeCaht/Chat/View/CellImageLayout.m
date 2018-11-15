//
//  CellImageLayout.m
//  HQ_WeChat
//
//  Created by 黄麒展  QQ 757618403 on 2018/10/26.
//  Copyright © 2018年 黄麒展  QQ 757618403. All rights reserved.
//

#import "CellImageLayout.h"


@implementation CellImageLayout
- (instancetype)initWith:(ChatMessageModel *)model{
    self = [super init];
    if (self) {
        self.modle = model;
        [self _layoutImage];
    }
    return self;
}

- (void)_layoutImage{
    //cacheImageAndImageCode
    _image = self.modle.tempImage;
    if (!_image) {
        _image = [HQLocalImageManager getImageWithImageName:self.modle.fileName];
    }else{
        _image = [HQLocalImageManager saveAndCodeImage:_image fileName:self.modle.fileName];
    }
    CGSize size = [HQImageManager handleImage:_image.size];
    _imageFrame.size = size;
    _imageFrame.origin.x = App_Frame_Width-size.width-65;
    _imageFrame.origin.y = 10;
    self.cellHeight = size.height + 25;
}

@end
