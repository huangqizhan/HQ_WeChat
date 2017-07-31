//
//  HQRecordingCell.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/5.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQRecordingCell.h"
#import "UIImage+Resize.h"
#import "HQActionSheet.h"
#import "UIApplication+HQExtern.h"


@interface HQRecordingCell (){
}

@property (nonatomic) UILabel *durationLabel;

@property (nonatomic) CAKeyframeAnimation *keyFrameAnimation;

@property (nonatomic,strong)UIImageView *paopaoView;

@end

@implementation HQRecordingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    static HQRecordingCell *cell;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cell = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
        cell.userInteractionEnabled = NO;
        [self addSubview:self.paopaoView];
        _durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(App_Frame_Width - 170,10, 30,40)];
        _durationLabel.textColor = [UIColor colorWithRed:125/255.0 green:125/255.0 blue:125/255.0 alpha:1];
        _durationLabel.font = [UIFont systemFontOfSize:13];
        _durationLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_durationLabel];
    });
    return cell;
}
- (void)setMessageModel:(ChatMessageModel *)messageModel{
    [super setMessageModel:messageModel];
    [self.paopaoView.layer addAnimation:self.keyFrameAnimation forKey:@"RecordAnimate"];
}

- (CAKeyframeAnimation *)keyFrameAnimation {
    if (!_keyFrameAnimation) {
        _keyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        _keyFrameAnimation.duration = 2;
        _keyFrameAnimation.repeatCount = HUGE_VALF;
        _keyFrameAnimation.removedOnCompletion = NO;
        _keyFrameAnimation.calculationMode = kCAAnimationLinear;
        _keyFrameAnimation.keyTimes = @[@(0), @(0.7), @(1)];
        _keyFrameAnimation.values = @[@(1), @(0), @(1)];
        _keyFrameAnimation.timingFunctions = @[
                                               [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut],
                                               [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]
                                               ];
    }
    
    return _keyFrameAnimation;
}
- (UIView *)hitTestForTapGestureRecognizer:(CGPoint)point {
    CGPoint bubblePoint = [self.contentView convertPoint:point toView:self.paopaoView];
    
    if (CGRectContainsPoint(self.paopaoView.bounds, bubblePoint)/* && ![self.chatLabel shouldReceiveTouchAtPoint:[self.contentView convertPoint:point toView:self.chatLabel]]*/) {
        return self.paopaoView;
    }
    return nil;
}

- (void)buttonAction:(UIButton *)sender{
    [self deleteAction:nil];
}
- (void)deleteAction:(id)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(HQChatMineBaseCell:MenuActionTitle:andIndexPath:andChatModel:)]) {
        [self.delegate HQChatMineBaseCell:self MenuActionTitle:@"删除" andIndexPath:self.indexPath andChatModel:self.messageModel];
    }
}
- (UIImageView *)paopaoView{
    if (_paopaoView == nil) {
        _paopaoView = [[UIImageView alloc] initWithFrame:CGRectMake(App_Frame_Width-140, 10, 80, 50)];
        UIImage *image = [UIImage imageNamed:@"SenderTextNodeBkg"];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height*0.5, image.size.width*0.5, image.size.width*0.5, image.size.width*0.5) resizingMode:UIImageResizingModeStretch];
        [_paopaoView setImage:image];
        _paopaoView.userInteractionEnabled = NO;
    }
    return _paopaoView;
}

- (void)updateDurationLabel:(int)duration {
    _durationLabel.text = [NSString stringWithFormat:@"%d\"", duration];
    _durationLabel.right = self.paopaoView.left + 2;
}
- (void)removeAnimationAndUpdateVoiceCell:(void (^)())complite{
    [self.paopaoView.layer removeAnimationForKey:@"RecordAnimate"];
    CGFloat width = [self.messageModel caculateVoiceViewWidth:self.messageModel.fileSize];
    [UIView animateWithDuration:.35 animations:^{
        self.paopaoView.frame = CGRectMake(App_Frame_Width-width-60, 10, width, 50);
        _durationLabel.right = self.paopaoView.left + 2;
    }completion:^(BOOL finished) {
        if (complite) complite();
    }];
}
- (void)resetRecordingOrigeStatus{
    self.paopaoView.frame = CGRectMake(App_Frame_Width-140, 10, 80, 50);
    _durationLabel.text = @"";
    _durationLabel.right = self.paopaoView.left + 2;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
