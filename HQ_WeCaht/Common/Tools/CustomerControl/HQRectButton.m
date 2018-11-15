//
//  HQRectButton.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/27.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HQRectButton.h"

@implementation HQRectButton

- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    return _imageRect;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    return _titleRect;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
