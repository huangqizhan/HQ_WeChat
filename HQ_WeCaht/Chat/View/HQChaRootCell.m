//
//  HQChaRootCell.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/8.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQChaRootCell.h"

BOOL _ChatCellIsEdiating = NO;

@implementation HQChaRootCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)setIsEdiating:(BOOL)isEdiating{
    _ChatCellIsEdiating = isEdiating;
}
- (BOOL)isEdiating{
    return _ChatCellIsEdiating;
}
- (void)reSetMessageCellEdiatedStatusIsEdiate:(BOOL)isEdiate{
    
}
- (void)didSeleteCellWhenIsEdiating:(BOOL)isSeleted{
    
}
////cell将要开始呈现
- (void)willDisplayCell{
    
}
///cell将要结束呈现
- (void)didEndDisplayingCell{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
