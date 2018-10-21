//
//  CellTextLayout.m
//  HQ_WeChat
//
//  Created by 黄麒展 on 2018/10/20.
//  Copyright © 2018年 黄麒展. All rights reserved.
//

#import "CellTextLayout.h"

@implementation CellTextModifier
- (instancetype)init {
    self = [super init];
    
//    if (kiOS9Later) {
//        _lineHeightMultiple = 1.34;   // for PingFang SC
//    } else {
//        _lineHeightMultiple = 1.3125; // for Heiti SC
//    }
    
    return self;
}

- (void)modifyLines:(NSArray *)lines fromText:(NSAttributedString *)text inContainer:(TextContainer *)container {
    //CGFloat ascent = _font.ascender;
    CGFloat ascent = _font.pointSize * 0.86;
    
    CGFloat lineHeight = _font.pointSize * _lineHeightMultiple;
    for (TextLine *line in lines) {
        CGPoint position = line.position;
        position.y = _paddingTop + ascent + line.row  * lineHeight;
        line.position = position;
    }
}

@end


@implementation CellTextLayout


- (instancetype)initWith:(ChatMessageModel *)model{
    self = [super init];
    if (self) {
        
    }
    return self;
}
- (void)_layoutText{
    
}
@end

