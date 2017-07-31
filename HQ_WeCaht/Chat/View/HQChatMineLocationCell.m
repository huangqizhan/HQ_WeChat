//
//  HQChatMineLocationCell.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/5.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQChatMineLocationCell.h"
#import "HQActionSheet.h"
#import "UIApplication+HQExtern.h"


@interface HQChatMineLocationCell ()

@property (nonatomic,strong) UIView *begView;
@property (nonatomic,strong) UILabel *addressLabel;
@property (nonatomic,strong) UIImageView *contentImageView;


@end


@implementation HQChatMineLocationCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.begView];
        [self.begView addSubview:self.contentImageView];
        [self.begView addSubview:self.addressLabel];
    }
    return self;
}
- (void)setMessageModel:(ChatMessageModel *)messageModel{
    [super setMessageModel:messageModel];
    [self .contentImageView setImage:self.messageModel.tempImage];
    self.addressLabel.text = self.messageModel.contentString;
}
#pragma mark - 弹出菜单

- (NSArray<NSString *> *)menuItemNames {
    return @[@"转发", @"收藏", @"删除", @"更多..."];
}

- (NSArray<NSString *> *)menuItemActionNames {
    return @[ @"transforAction:", @"favoriteAction:",@"deleteAction:", @"moreAction:"];
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (self.isEdiating) {
        return NO;
    }
    if ([UIMenuController sharedMenuController].menuVisible) {
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
        return NO;
    }
    return [super gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
}

- (void)contentLongPressedBeganInView:(UIView *)view {
    if (view == self.begView) {
        UIView *fruzyView = [[UIView alloc] initWithFrame:self.begView.bounds];
        fruzyView.tag = 100;
        fruzyView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.3];
        [self.begView addSubview:fruzyView];
        [self showMenuControllerInRect:self.begView.bounds inView:self.begView];
    }
}

- (UIView *)hitTestForTapGestureRecognizer:(CGPoint)point {
    CGPoint bubblePoint = [self.contentView convertPoint:point toView:self.begView];
    if (CGRectContainsPoint(self.begView.bounds, bubblePoint)/* && ![self.chatLabel shouldReceiveTouchAtPoint:[self.contentView convertPoint:point toView:self.chatLabel]]*/) {
        return self.begView;
    }
    return self.contentView;
}
- (void)menuControllerDidHidden{
    UIView *view = [self.begView viewWithTag:100];
    [view removeFromSuperview];
}
- (void)contentLongPressedEndedInView:(UIView *)view {
    NSLog(@"contentLongPressedEndedInView");
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.isEdiating) {
        return self.contentView;
    }
    if (self.hidden || !self.userInteractionEnabled || self.alpha <= 0.01)
        return nil;
    
    if ([self.begView pointInside:[self convertPoint:point toView:self.begView] withEvent:event]) {
        return self.begView;
    }else if ([self.contentView pointInside:[self convertPoint:point toView:self.contentView] withEvent:event]) {
        return self.contentView;
    }
    
    //    if (LLMessageCell_isEditing) {
    //        if ([self.contentView pointInside:[self convertPoint:point toView:self.contentView] withEvent:event]) {
    //            return self.contentView;
    //        }
    //    }else {
    //        if ([self.contentLabel pointInside:[self convertPoint:point toView:self.contentLabel] withEvent:event]) {
    //            return self.contentLabel;
    //        }else if ([self.contentView pointInside:[self convertPoint:point toView:self.contentView] withEvent:event]) {
    //            return self.contentView;
    //        }
    //    }
    
    return nil;
}
#pragma mark -------- 编辑 ------
- (void)setIsEdiating:(BOOL)isEdiating{
    [super setIsEdiating:isEdiating];
    if (isEdiating) {
        self.selectControl.centerY = self.begView.centerY;
        self.selectControl.left = 0;
    }else{
        self.selectControl.right = 0;
    }
}
- (void)reSetMessageCellEdiatedStatusIsEdiate:(BOOL)isEdiate{
    if (isEdiate) {
        self.selectControl.hidden = NO;
        self.selectControl.centerY = self.begView.centerY;
        [UIView animateWithDuration:.35 animations:^{
            self.selectControl.left = 0;
        }];
    }else{
        self.selectControl.hidden = YES;
        [self didSeleteCellWhenIsEdiating:NO];
        [UIView animateWithDuration:.35 animations:^{
            self.selectControl.right = 0;
        }];
    }
    [super setIsEdiating:isEdiate];
}

///长按手势
- (UIView *)hitTestForlongPressedGestureRecognizer:(CGPoint)aPoint{
    return [self hitTestForTapGestureRecognizer:aPoint];
}
///删除
- (void)deleteAction:(id)sender {
    [super deleteAction:sender];
}
//更多
- (void)moreAction:(id)sender {
    [super moreAction:sender];
}
//转发
- (void)transforAction:(id)sender {
    [super transforAction:sender];
}
//收藏
- (void)favoriteAction:(id)sender {
    [super favoriteAction:sender];
}
- (void)addToEmojiAction:(id)sender {
    [super addToEmojiAction:sender];
}

- (void)forwardAction:(id)sender {
    [super forwardAction:sender];
}

- (void)showAlbumAction:(id)sender {
    [super showAlbumAction:sender];
}

- (void)playAction:(id)sender {
    [super playAction:sender];
}

- (void)translateToWordsAction:(id)sender {
    [super translateToWordsAction:sender];
}
- (void)willDisplayCell{
    
}
///cell将要结束呈现
- (void)didEndDisplayingCell{
    
}
#pragma mark - Getter
- (UIView *)begView{
    if (_begView == nil) {
        _begView = [[UIView alloc]initWithFrame:CGRectMake(App_Frame_Width-App_Frame_Width*3.0/5.0-65, 10, App_Frame_Width*0.6, (APP_Frame_Height)/4.0)];
        _begView.layer.masksToBounds = YES;
        _begView.backgroundColor = [UIColor whiteColor];
        _begView.layer.cornerRadius = 5.0;
    }
    return _begView;
}
- (UIImageView *)contentImageView{
    if (_contentImageView == nil) {
        _contentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, _begView.height/3.0, _begView.width, _begView.height*2/3.0)];
        _contentImageView.contentMode = UIViewContentModeScaleAspectFill;
        _contentImageView.clipsToBounds = YES;
    }
    return _contentImageView;
}

- (UILabel *)addressLabel{
    if (_addressLabel == nil) {
        _addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, _begView.width-20, 20)];
        _addressLabel.font = [UIFont systemFontOfSize:16*SCREENSCALE];
    }
    return _addressLabel;
}
@end
