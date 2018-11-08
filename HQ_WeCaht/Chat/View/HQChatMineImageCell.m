//
//  HQChatMineImageCell.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/8.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQChatMineImageCell.h"
//#import "HQActionSheet.h"
#import "CellImageLayout.h"

@interface HQChatMineImageCell ()



@end

@implementation HQChatMineImageCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.imageControll];
    }
    return self;
}

//- (void)setMessageModel:(ChatMessageModel *)messageModel{
//    [super setMessageModel:messageModel];
//    [self.imageBtn setBackgroundImage:self.messageModel.tempImage forState:UIControlStateNormal];
//    self.imageBtn.frame = CGRectMake(self.messageModel.chatImageRect.xx, self.messageModel.chatImageRect.yy, self.messageModel.chatImageRect.width, self.messageModel.chatImageRect.height);
//}
- (void)setLayout:(HQBaseCellLayout *)layout{
    CellImageLayout *imageLayout = (CellImageLayout *)layout;
    self.imageControll.image = imageLayout.image;
    self.imageControll.frame = imageLayout.imageFrame;
}
//- (void)imageBtnClick:(UIButton *)btn{
//    if ([UIMenuController sharedMenuController].menuVisible) {
//        return;
//    }
//    if (self.delegate && [self.delegate respondsToSelector:@selector(HQChatMineBaseCell:didScanOriginePictureWith: andPicBtn:)]) {
//        [self.delegate HQChatMineBaseCell:self didScanOriginePictureWith:self.messageModel andPicBtn:btn];
//    }
//}

#pragma mark - 弹出菜单

//- (NSArray<NSString *> *)menuItemNames {
//    return @[@"转发", @"收藏", @"删除", @"更多..."];
//}
//
//- (NSArray<NSString *> *)menuItemActionNames {
//    return @[ @"transforAction:", @"favoriteAction:",@"deleteAction:", @"moreAction:"];
//}
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//    if (self.isEdiating) {
//        return NO;
//    }
//    if ([UIMenuController sharedMenuController].menuVisible) {
//        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
//        return NO;
//    }
//    return [super gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
//}
//
//- (void)contentLongPressedBeganInView:(UIView *)view {
//    if (view == self.imageBtn) {
//        UIView *fruzyView = [[UIView alloc] initWithFrame:self.imageBtn.bounds];
//        fruzyView.tag = 100;
//        fruzyView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.3];
//        [self.imageBtn addSubview:fruzyView];
//        _imageBtn.userInteractionEnabled = NO;
//        [self showMenuControllerInRect:self.imageBtn.bounds inView:self.imageBtn];
//    }
//}
//
//- (UIView *)hitTestForTapGestureRecognizer:(CGPoint)point {
//    CGPoint bubblePoint = [self.contentView convertPoint:point toView:self.imageBtn];
//    if (CGRectContainsPoint(self.imageBtn.bounds, bubblePoint)/* && ![self.chatLabel shouldReceiveTouchAtPoint:[self.contentView convertPoint:point toView:self.chatLabel]]*/) {
//        return self.imageBtn;
//    }
//    return self.contentView;
//}
//- (void)menuControllerDidHidden{
//    UIView *view = [self.imageBtn viewWithTag:100];
//    _imageBtn.userInteractionEnabled = YES;
//    [view removeFromSuperview];
//}
//- (void)contentLongPressedEndedInView:(UIView *)view {
//}
//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    if (self.isEdiating) {
//        return self.contentView;
//    }
//    if (self.hidden || !self.userInteractionEnabled || self.alpha <= 0.01)
//        return nil;
//
//    if ([self.imageBtn pointInside:[self convertPoint:point toView:self.imageBtn] withEvent:event]) {
//        return self.imageBtn;
//    }else if ([self.contentView pointInside:[self convertPoint:point toView:self.contentView] withEvent:event]) {
//        return self.contentView;
//    }
//
//    //    if (LLMessageCell_isEditing) {
//    //        if ([self.contentView pointInside:[self convertPoint:point toView:self.contentView] withEvent:event]) {
//    //            return self.contentView;
//    //        }
//    //    }else {
//    //        if ([self.contentLabel pointInside:[self convertPoint:point toView:self.contentLabel] withEvent:event]) {
//    //            return self.contentLabel;
//    //        }else if ([self.contentView pointInside:[self convertPoint:point toView:self.contentView] withEvent:event]) {
//    //            return self.contentView;
//    //        }
//    //    }
//
//    return nil;
//}
#pragma mark -------- 编辑 ------
//- (void)setIsEdiating:(BOOL)isEdiating{
//    [super setIsEdiating:isEdiating];
//    if (isEdiating) {
//        self.selectControl.centerY = self.imageBtn.centerY;
//        self.selectControl.left = 0;
//    }else{
//        self.selectControl.right = 0;
//    }
//}
//- (void)reSetMessageCellEdiatedStatusIsEdiate:(BOOL)isEdiate{
//    if (isEdiate) {
//        self.selectControl.hidden = NO;
//        self.selectControl.centerY = self.imageBtn.centerY;
//        [UIView animateWithDuration:.35 animations:^{
//            self.selectControl.left = 0;
//        }];
//    }else{
//        self.selectControl.hidden = YES;
//        [self didSeleteCellWhenIsEdiating:NO];
//        [UIView animateWithDuration:.35 animations:^{
//            self.selectControl.right = 0;
//        }];
//    }
//    [super setIsEdiating:isEdiate];
//}
//
/////长按手势
//- (UIView *)hitTestForlongPressedGestureRecognizer:(CGPoint)aPoint{
//    return [self hitTestForTapGestureRecognizer:aPoint];
//}
/////删除
//- (void)deleteAction:(id)sender {
//    [super deleteAction:sender];
//}
////更多
//- (void)moreAction:(id)sender {
//    [super moreAction:sender];
//}
////转发
//- (void)transforAction:(id)sender {
//    [super transforAction:sender];
//}
////收藏
//- (void)favoriteAction:(id)sender {
//    [super favoriteAction:sender];
//}
//- (void)addToEmojiAction:(id)sender {
//    [super addToEmojiAction:sender];
//}
//
//- (void)forwardAction:(id)sender {
//    [super forwardAction:sender];
//}
//
//- (void)showAlbumAction:(id)sender {
//    [super showAlbumAction:sender];
//}
//
//- (void)playAction:(id)sender {
//    [super playAction:sender];
//}
//
//- (void)translateToWordsAction:(id)sender {
//    [super translateToWordsAction:sender];
//}
//- (void)willDisplayCell{
//
//}
///cell将要结束呈现
//- (void)didEndDisplayingCell{
//
//}
#pragma mark - Getter

- (ImageControll *)imageControll{
    if (nil == _imageControll) {
        _imageControll = [[ImageControll alloc] init];
//        [_imageBtn addTarget:self action:@selector(imageBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//        _imageBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
//        _imageBtn.layer.masksToBounds = YES;
//        _imageBtn.layer.cornerRadius = 5;
//        _imageBtn.clipsToBounds = YES;
//        [_imageBtn setAdjustsImageWhenHighlighted:NO];
    }
    return _imageControll;
}

@end
