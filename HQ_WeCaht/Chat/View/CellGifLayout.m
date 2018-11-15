//
//  CellGifLayout.m
//  HQ_WeChat
//
//  Created by 黄麒展  QQ 757618403 on 2018/10/26.
//  Copyright © 2018年 黄麒展  QQ 757618403. All rights reserved.
//

#import "CellGifLayout.h"

@implementation CellGifLayout

- (instancetype)initWith:(ChatMessageModel *)model{
    self = [super init];
    if (self) {
        self.modle = model;
        [self _layoutGif];
    }
    return self;
}
- (void)_layoutGif{
    NSString *path = [[NSBundle mainBundle] pathForResource:self.modle.fileName ofType:@".gif"];
    _image = (MyImage *)[HQLocalImageManager getImageWithImageName:self.modle.fileName];
    if (!_image) {
        _image = [MyImage imageWithContentsOfFile:path];
        if (!_image) {
            ///from web
        }else{
            _image.preloadAllAnimatedImageFrames = YES;
            [HQLocalImageManager saveLocalGifImage:_image fileName:self.modle.fileName];
        }
    }
    CGSize size = [HQImageManager handleGifImage:_image.size];
    _imageFrame.size = size;
    _imageFrame.origin.x = App_Frame_Width-size.width-65;
    _imageFrame.origin.y = 10;
    self.cellHeight = size.height + 25;

}

@end
