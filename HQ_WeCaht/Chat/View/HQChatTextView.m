//
//  HQTextView.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/13.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HQChatTextView.h"

@implementation HQChatTextView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        NSMutableParagraphStyle *par = [[NSMutableParagraphStyle alloc] init];
        par.lineSpacing = 2.0;
        par.paragraphSpacing = 4.0;
        NSDictionary *dic = @{
                              NSFontAttributeName:[UIFont systemFontOfSize:16],
                              NSParagraphStyleAttributeName:par
                              };
        self.typingAttributes = dic;
    }
    return self;
}

- (void)setContentSize:(CGSize)contentSize{
    CGSize oriSize = self.contentSize;
    [super setContentSize:contentSize];
    if (oriSize.height == 0) {
        CGRect newFrame = self.frame;
        newFrame.size.height = HEIGHT_TEXTVIEW;
        self.frame = newFrame;
        return;
    }
    if(oriSize.height != self.contentSize.height){
        CGRect newFrame = self.frame;
        newFrame.size.height = self.contentSize.height;
        if (newFrame.size.height>100) {
             newFrame.size.height = 100;
        }
        [UIView animateWithDuration:.15 animations:^{
            if (self.cusDelegate && [self.cusDelegate respondsToSelector:@selector(HQTextView:textViewHeightDidChange:)]) {
                self.frame = newFrame;
                [self.cusDelegate HQTextView:self textViewHeightDidChange:newFrame.size.height];
            }
        }];
    }
}
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (self.textCell && [self.textCell isKindOfClass:[HQChatMineTextCell class]]) {
        HQChatMineTextCell *mineCell = (HQChatMineTextCell *)self.textCell;
        NSArray<NSString *> *menuActionNames = mineCell.menuItemActionNames;
        for (NSInteger i = 0; i < menuActionNames.count; i++) {
            if (action == NSSelectorFromString(menuActionNames[i])) {
                return YES;
            }
        }
        return NO;//隐藏系统默认的菜单项
    }else if (self.textCell && [self.textCell isKindOfClass:[HQChatOtherBaseCell class]]){
        HQChatOtherBaseCell *mineCell = (HQChatOtherBaseCell *)self.textCell;
        NSArray<NSString *> *menuActionNames = mineCell.menuItemActionNames;
        for (NSInteger i = 0; i < menuActionNames.count; i++) {
            if (action == NSSelectorFromString(menuActionNames[i])) {
                return YES;
            }
        }
        return NO;//隐藏系统默认的菜单项
    }else{
        return [super canPerformAction:action withSender:sender];
    }
}
- (void)deleteAction:(id)sender {
    if (self.textCell && [self.textCell isKindOfClass:[HQChatMineTextCell class]]){
        HQChatMineTextCell *mineCell = (HQChatMineTextCell *)self.textCell;
        [mineCell deleteAction:sender];
    }else if (self.textCell && [self.textCell isKindOfClass:[HQChatOtherBaseCell class]]){
        HQChatOtherBaseCell *mineCell = (HQChatOtherBaseCell *)self.textCell;
        [mineCell deleteAction:sender];
    }
}

- (void)moreAction:(id)sender {
    if (self.textCell && [self.textCell isKindOfClass:[HQChatMineTextCell class]]){
        HQChatMineTextCell *mineCell = (HQChatMineTextCell *)self.textCell;
        [mineCell moreAction:sender];
    }else if (self.textCell && [self.textCell isKindOfClass:[HQChatOtherBaseCell class]]){
        HQChatOtherBaseCell *mineCell = (HQChatOtherBaseCell *)self.textCell;
        [mineCell moreAction:sender];
    }
}

- (void)copyAction:(id)sender {
    if (self.textCell && [self.textCell isKindOfClass:[HQChatMineTextCell class]]){
        HQChatMineTextCell *mineCell = (HQChatMineTextCell *)self.textCell;
        [mineCell copyAction:sender];
    }else if (self.textCell && [self.textCell isKindOfClass:[HQChatOtherBaseCell class]]){
        HQChatOtherBaseCell *mineCell = (HQChatOtherBaseCell *)self.textCell;
        [mineCell copyAction:sender];
    }
}

- (void)transforAction:(id)sender {
    if (self.textCell && [self.textCell isKindOfClass:[HQChatMineTextCell class]]){
        HQChatMineTextCell *mineCell = (HQChatMineTextCell *)self.textCell;
        [mineCell transforAction:sender];
    }else if (self.textCell && [self.textCell isKindOfClass:[HQChatOtherBaseCell class]]){
        HQChatOtherBaseCell *mineCell = (HQChatOtherBaseCell *)self.textCell;
        [mineCell transforAction:sender];
    }
}

- (void)favoriteAction:(id)sender {
    if (self.textCell && [self.textCell isKindOfClass:[HQChatMineTextCell class]]){
        HQChatMineTextCell *mineCell = (HQChatMineTextCell *)self.textCell;
        [mineCell favoriteAction:sender];
    }else if (self.textCell && [self.textCell isKindOfClass:[HQChatOtherBaseCell class]]){
        HQChatOtherBaseCell *mineCell = (HQChatOtherBaseCell *)self.textCell;
        [mineCell favoriteAction:sender];
    }
}

- (void)translateAction:(id)sender {
    if (self.textCell && [self.textCell isKindOfClass:[HQChatMineTextCell class]]){
        HQChatMineTextCell *mineCell = (HQChatMineTextCell *)self.textCell;
        [mineCell transforAction:sender];
    }else if (self.textCell && [self.textCell isKindOfClass:[HQChatOtherBaseCell class]]){
        HQChatOtherBaseCell *mineCell = (HQChatOtherBaseCell *)self.textCell;
        [mineCell transforAction:sender];
    }
}

- (void)addToEmojiAction:(id)sender {
    if (self.textCell && [self.textCell isKindOfClass:[HQChatMineTextCell class]]){
        HQChatMineTextCell *mineCell = (HQChatMineTextCell *)self.textCell;
        [mineCell addToEmojiAction:sender];
    }else if (self.textCell && [self.textCell isKindOfClass:[HQChatOtherBaseCell class]]){
        HQChatOtherBaseCell *mineCell = (HQChatOtherBaseCell *)self.textCell;
        [mineCell addToEmojiAction:sender];
    }
}

- (void)forwardAction:(id)sender {
    if (self.textCell && [self.textCell isKindOfClass:[HQChatMineTextCell class]]){
        HQChatMineTextCell *mineCell = (HQChatMineTextCell *)self.textCell;
        [mineCell forwardAction:sender];
    }else if (self.textCell && [self.textCell isKindOfClass:[HQChatOtherBaseCell class]]){
        HQChatOtherBaseCell *mineCell = (HQChatOtherBaseCell *)self.textCell;
        [mineCell forwardAction:sender];
    }
}

- (void)showAlbumAction:(id)sender {
    if (self.textCell && [self.textCell isKindOfClass:[HQChatMineTextCell class]]){
        HQChatMineTextCell *mineCell = (HQChatMineTextCell *)self.textCell;
        [mineCell showAlbumAction:sender];
    }else if (self.textCell && [self.textCell isKindOfClass:[HQChatOtherBaseCell class]]){
        HQChatOtherBaseCell *mineCell = (HQChatOtherBaseCell *)self.textCell;
        [mineCell showAlbumAction:sender];
    }
}

- (void)playAction:(id)sender {
    if (self.textCell && [self.textCell isKindOfClass:[HQChatMineTextCell class]]){
        HQChatMineTextCell *mineCell = (HQChatMineTextCell *)self.textCell;
        [mineCell playAction:sender];
    }else if (self.textCell && [self.textCell isKindOfClass:[HQChatOtherBaseCell class]]){
        HQChatOtherBaseCell *mineCell = (HQChatOtherBaseCell *)self.textCell;
        [mineCell playAction:sender];
    }
}

- (void)translateToWordsAction:(id)sender {
    if (self.textCell && [self.textCell isKindOfClass:[HQChatMineTextCell class]]){
        HQChatMineTextCell *mineCell = (HQChatMineTextCell *)self.textCell;
        [mineCell translateToWordsAction:sender];
    }else if (self.textCell && [self.textCell isKindOfClass:[HQChatOtherBaseCell class]]){
        HQChatOtherBaseCell *mineCell = (HQChatOtherBaseCell *)self.textCell;
        [mineCell translateToWordsAction:sender];
    }
}

@end
