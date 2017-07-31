//
//  HQChatOtherVoiceCell.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/8.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQChatOtherVoiceCell.h"
#import "HQPlayVoiceOtherButton.h"


@interface HQChatOtherVoiceCell () <HQPlayVoiceOtherButtonDelegate>

@property (nonatomic,strong) HQPlayVoiceOtherButton *playButton;


@end

@implementation HQChatOtherVoiceCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.playButton];
    }
    return self;
}
- (void)setMessageModel:(ChatMessageModel *)messageModel{
    [super setMessageModel:messageModel];
    self.playButton.messageModel = messageModel;
    self.playButton.width = self.messageModel.chatImageRect.width;
    self.playButton.left = self.headImageView.right+10;
    [self.messageModel setChatMessageSendStatusCallBack:^(HQMessageDeliveryState status){
        NSLog(@"status = %u",status);
    }];
//    NSLog(@"filePath = %@",self.messageModel.filePath);
}
- (void)buttonAction:(UIButton *)sender{
    NSLog(@"buttonAction");
}
#pragma mark -------- 编辑 ------
- (void)setIsEdiating:(BOOL)isEdiating{
    [super setIsEdiating:isEdiating];
    if (isEdiating) {
        self.headImageView.left = 60;
        self.selectControl.centerY = self.playButton.centerY;
        self.selectControl.left = 0;
    }else{
        self.selectControl.right = 0;
        self.headImageView.left = 10;
    }
    self.playButton.left = self.headImageView.right+10;
}
- (void)reSetMessageCellEdiatedStatusIsEdiate:(BOOL)isEdiate{
    if (isEdiate) {
        self.selectControl.hidden = NO;
        self.selectControl.centerY = self.playButton.centerY;
        [UIView animateWithDuration:.35 animations:^{
            self.selectControl.left = 0;
            self.headImageView.left = 60;
            self.playButton.left = self.headImageView.right+10;
        }];
    }else{
        self.selectControl.hidden = YES;
        [UIView animateWithDuration:.35 animations:^{
            self.selectControl.right = 0;
            self.headImageView.left = 10;
            self.playButton.left = self.headImageView.right+10;
        }];
    }
    [super setIsEdiating:isEdiate];
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
        return NO;
    }
    return [super gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
}

- (void)contentLongPressedBeganInView:(UIView *)view {
    if (view == self.playButton) {
        self.playButton.begImageView.highlighted = YES;
        [self showMenuControllerInRect:self.playButton.bounds inView:self.playButton];
    }
}
- (void)menuControllerDidHidden{
    self.playButton.begImageView.highlighted = NO;
}
- (void)contentLongPressedEndedInView:(UIView *)view {
}
/////点到哪个视图上 事件就相应在哪个视图上
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.isEdiating) {
        return self.contentView;
    }
    if ([UIMenuController sharedMenuController].menuVisible) {
//        [self dispatchAfterDelay:1.0];
        return nil;
    }
    if (self.hidden || !self.userInteractionEnabled || self.alpha <= 0.01)
        return nil;
    
    if ([self.playButton pointInside:[self convertPoint:point toView:self.playButton] withEvent:event]) {
        return self.playButton.contentButton;
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
///长按手势
- (UIView *)hitTestForlongPressedGestureRecognizer:(CGPoint)aPoint{
    return [self hitTestForTapGestureRecognizer:aPoint];
}
- (UIView *)hitTestForTapGestureRecognizer:(CGPoint)aPoint{
    CGPoint bubblePoint = [self.contentView convertPoint:aPoint toView:self.playButton];
    if (CGRectContainsPoint(self.playButton.bounds, bubblePoint)/* && ![self.chatLabel shouldReceiveTouchAtPoint:[self.contentView convertPoint:point toView:self.chatLabel]]*/) {
        return self.playButton;
    }
    return self.contentView;
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
/////扬声器模式
- (void)changeSpeakerStatus{
    if (self.delegate && [self.delegate respondsToSelector:@selector(changeSpeakerStatus)]) {
        [self.delegate changeSpeakerStatus];
    }
}
- (void)dispatchAfterDelay:(CFTimeInterval )duration{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    });
}
#pragma mark - Getter
- (HQPlayVoiceOtherButton *)playButton{
    if (_playButton == nil) {
        _playButton = [[HQPlayVoiceOtherButton alloc] initWithFrame:CGRectMake(60, 10, 100, 50)];
        _playButton.delegate = self;
    }
    return _playButton;
}
@end
