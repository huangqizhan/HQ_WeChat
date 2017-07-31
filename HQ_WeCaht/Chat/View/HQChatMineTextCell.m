//
//  HQChatMineTextCell.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/8.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQChatMineTextCell.h"
#import "UIImage+YYWebImage.h"
#import "HQTextView.h"




@interface HQChatMineTextCell ()<UIGestureRecognizerDelegate>

@property (nonatomic,strong)UIImageView *paopaoView;

@property (nonatomic,strong) UITapGestureRecognizer *doubleTap;

@property (nonatomic,strong) UITapGestureRecognizer *singalTap;

@end


@implementation HQChatMineTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.paopaoView];
        [self.paopaoView addSubview:self.chatLabel];
        _doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentDoubleTapped:)];
        _doubleTap.delegate = self;
        _doubleTap.numberOfTapsRequired = 2;
        _doubleTap.numberOfTouchesRequired = 1;
        [self.paopaoView addGestureRecognizer:_doubleTap];
        
        _singalTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singalTapAction:)];
        [self.paopaoView addGestureRecognizer:_singalTap];

    }
    return self;
}
- (void)setMessageModel:(ChatMessageModel *)messageModel{
    [super setMessageModel:messageModel];
    self.chatLabel.attributedText = self.messageModel.muAttributeString;
    self.paopaoView.width = [self.messageModel.chatLabelRect cacuLateCgrect].size.width+30;
    self.paopaoView.height = [self.messageModel.chatLabelRect cacuLateCgrect].size.height+30;
    self.paopaoView.right = self.headImageView.left-10;
    self.chatLabel.width = [self.messageModel.chatLabelRect cacuLateCgrect].size.width;
    self.chatLabel.height = [self.messageModel.chatLabelRect cacuLateCgrect].size.height;
}
#pragma mark -------- 编辑 ------
- (void)setIsEdiating:(BOOL)isEdiating{
    
    if (isEdiating) {
        self.selectControl.centerY = self.paopaoView.centerY;
        self.selectControl.left = 0;
    }else{
        self.selectControl.right = 0;
    }
    [super setIsEdiating:isEdiating];
}
- (void)reSetMessageCellEdiatedStatusIsEdiate:(BOOL)isEdiate{
    if (isEdiate) {
        self.selectControl.hidden = NO;
        self.selectControl.centerY = self.paopaoView.centerY;
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
#pragma mark   ------ 双击 ------
- (void)contentDoubleTapped:(UITapGestureRecognizer *)tap {
    if (self.isEdiating) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(HQChatDoubleClick:WithChatMessage:)]) {
        [self.delegate HQChatDoubleClick:self WithChatMessage:self.messageModel];
    }
}
- (void)singalTapAction:(UITapGestureRecognizer *)singalTap{
    if ([UIMenuController sharedMenuController].menuVisible) {
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    }
}
- (void)attemptOpenURL:(NSURL *)url{
    BOOL safariCompatible = [url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"];
    if (safariCompatible && [[UIApplication sharedApplication] canOpenURL:url]) {
//        [[UIApplication sharedApplication] openURL:url];
        if (self.delegate && [self.delegate respondsToSelector:@selector(HQChatClickLink:withChatMessage:andLinkUrl:)]) {
            [self.delegate HQChatClickLink:self withChatMessage:self.messageModel andLinkUrl:url];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警示" message:@"您的链接无效" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}
#pragma mark - 弹出菜单

- (NSArray<NSString *> *)menuItemNames {
    return @[@"复制", @"转发", @"收藏", @"翻译", @"删除", @"更多..."];
}

- (NSArray<NSString *> *)menuItemActionNames {
    return @[@"copyAction:", @"transforAction:", @"favoriteAction:", @"translateAction:",@"deleteAction:", @"moreAction:"];
}
- (void)contentLongPressedBeganInView:(UIView *)view {
    if (view == self.paopaoView) {
        self.paopaoView.highlighted = YES;
        [self showMenuControllerInRect:self.paopaoView.bounds inView:self.paopaoView];
    }
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (self.isEdiating) {
        return NO;
    }
    if ([UIMenuController sharedMenuController].menuVisible) {
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
        return NO;
    }
    if (gestureRecognizer == _doubleTap) {
         return YES;
//        CGPoint bubblePoint = [touch locationInView:self.paopaoView];
//        if (CGRectContainsPoint(self.paopaoView.bounds, bubblePoint) && ![self.chatLabel shouldReceiveTouchAtPoint:[touch locationInView:self.chatLabel]]) {
//           
//        }
    }
    return [super gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
}
- (UIView *)hitTestForTapGestureRecognizer:(CGPoint)point {
    CGPoint bubblePoint = [self.contentView convertPoint:point toView:self.paopaoView];
    
    if (CGRectContainsPoint(self.paopaoView.bounds, bubblePoint)/* && ![self.chatLabel shouldReceiveTouchAtPoint:[self.contentView convertPoint:point toView:self.chatLabel]]*/) {
        return self.paopaoView;
    }
    return self.contentView;
}
- (void)menuControllerDidHidden{
    self.paopaoView.highlighted = NO;
}
- (void)contentLongPressedEndedInView:(UIView *)view {
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    [super hitTest:point withEvent:event];
    if (self.isEdiating) {
        return self.contentView;
    }
    if (self.hidden || !self.userInteractionEnabled || self.alpha <= 0.01)
        return nil;
    
    if ([self.chatLabel pointInside:[self convertPoint:point toView:self.chatLabel] withEvent:event]) {
        return self.chatLabel;
    }else if ([self.headImageView pointInside:[self convertPoint:point toView:self.headImageView] withEvent:event]){
        return self.headImageView;
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
///删除
- (void)deleteAction:(id)sender {
    [super deleteAction:sender];
}
 //更多
- (void)moreAction:(id)sender {
    [super moreAction:sender];
}
//复制
- (void)copyAction:(id)sender {
    [super copyAction:sender];
}
//转发
- (void)transforAction:(id)sender {
    [super transforAction:sender];
}
//收藏
- (void)favoriteAction:(id)sender {
    [super favoriteAction:sender];
}
//翻译
- (void)translateAction:(id)sender {
    [super translateAction:sender];
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
- (UIImageView *)paopaoView{
    if (_paopaoView == nil) {
        _paopaoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, 0, 0)];
        UIImage *image = [UIImage imageNamed:@"SenderTextNodeBkg"];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height*0.5, image.size.width*0.5, image.size.width*0.5, image.size.width*0.5) resizingMode:UIImageResizingModeStretch];
        UIImage *hightedImage = [UIImage imageNamed:@"SenderTextNodeBkgHL"];
        hightedImage = [hightedImage  resizableImageWithCapInsets:UIEdgeInsetsMake(hightedImage.size.height*0.5, hightedImage.size.width*0.5, hightedImage.size.width*0.5, hightedImage.size.width*0.5) resizingMode:UIImageResizingModeStretch];
        _paopaoView.highlightedImage = hightedImage;
        [_paopaoView setImage:image];
        _paopaoView.userInteractionEnabled = NO;
    }
    return _paopaoView;
}
- (KILabel *)chatLabel{
    if (nil == _chatLabel) {
        _chatLabel = [[KILabel alloc] initWithFrame:CGRectMake(15, 10,CONTENTLABELWIDTH , 10)];
        _chatLabel.numberOfLines = 0;
        _chatLabel.font = MessageFont;
        _chatLabel.textColor = ICRGB(0x282724);
//        _chatLabel.backgroundColor = [UIColor clearColor];
        __weak typeof (self) weekSelf = self;
        _chatLabel.urlLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range){
            [weekSelf attemptOpenURL:[NSURL URLWithString:string]];
        };
    }
    return _chatLabel;
}
@end
