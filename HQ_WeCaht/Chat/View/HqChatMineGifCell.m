//
//  HqChatMineGifCell.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/5/5.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HqChatMineGifCell.h"
#import "ImageCore.h"
#import "CellGifLayout.h"


@interface HqChatMineGifCell ()

@property (nonatomic,strong) AnimatedImageView *animationView;


@end

@implementation HqChatMineGifCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.animationView];
    }
    return self;
}
- (void)setLayout:(HQBaseCellLayout *)layout{
    CellGifLayout *gifLayout = (CellGifLayout *)layout;
    self.animationView.image = gifLayout.image;
    self.animationView.frame = gifLayout.imageFrame;

}
//- (void)setMessageModel:(ChatMessageModel *)messageModel{
//    [super setMessageModel:messageModel];
//    self.animationView.messageModel = self.messageModel;
//    self.animationView.frame = CGRectMake(self.messageModel.chatImageRect.xx, self.messageModel.chatImageRect.yy, self.messageModel.chatImageRect.width, self.messageModel.chatImageRect.height);
//    [self.animationView startGifAnimationWithChatMessage:self.messageModel];
//    self.contentLabel.text = self.messageModel.fileName;
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
//    if (view == self.animationView) {
//        self.animationView.highlighted = YES;
//        [self showMenuControllerInRect:self.animationView.bounds inView:self.animationView];
//    }
//}
//
//- (UIView *)hitTestForTapGestureRecognizer:(CGPoint)point {
//    CGPoint bubblePoint = [self.contentView convertPoint:point toView:self.animationView];
//    if (CGRectContainsPoint(self.animationView.bounds, bubblePoint)/* && ![self.chatLabel shouldReceiveTouchAtPoint:[self.contentView convertPoint:point toView:self.chatLabel]]*/) {
//        return self.animationView;
//    }
//    return self.contentView;
//}
//- (void)menuControllerDidHidden{
//    self.animationView.highlighted = NO;
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
//    if ([self.animationView pointInside:[self convertPoint:point toView:self.animationView] withEvent:event]) {
//        return self.animationView;
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
//        self.selectControl.centerY = self.animationView.centerY;
//        self.selectControl.left = 0;
//    }else{
//        self.selectControl.right = 0;
//    }
//}
//- (void)reSetMessageCellEdiatedStatusIsEdiate:(BOOL)isEdiate{
//    if (isEdiate) {
//        self.selectControl.hidden = NO;
//        self.selectControl.centerY = self.animationView.centerY;
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
/////cell将要结束呈现
//- (void)didEndDisplayingCell{
//
//}
- (AnimatedImageView *)animationView{
    if (_animationView == nil) {
        _animationView = [[AnimatedImageView alloc] initWithFrame:CGRectZero];
    }
    return _animationView;
}
@end
