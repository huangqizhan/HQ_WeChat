//
//  HQChatDateCell.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/13.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HQChatDateCell.h"
#import "NSString+Extension.h"



@interface HQChatDateCell ()

@property (nonatomic,strong) UILabel *dateLabel;

@end

@implementation HQChatDateCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.dateLabel];
        self.headImageView.hidden = YES;
    }
    return self;
}
- (void)setMessageModel:(ChatMessageModel *)messageModel{
    [super setMessageModel:messageModel];
    self.dateLabel.text = self.messageModel.contentString;
    self.dateLabel.width = [self.messageModel.contentString widthForFont:[UIFont systemFontOfSize:13]]+10;
    self.dateLabel.centerX = App_Frame_Width/2.0;
}
- (void)didSeleteCellWhenIsEdiating:(BOOL)isSeleted{
    
}
#pragma mark - 弹出菜单
- (NSArray<NSString *> *)menuItemNames {
    return nil;
}
- (NSArray<NSString *> *)menuItemActionNames {
    return nil;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return NO;
}

- (void)contentLongPressedBeganInView:(UIView *)view {
}
- (void)menuControllerDidHidden{
}
- (void)contentLongPressedEndedInView:(UIView *)view {
}
/////点到哪个视图上 事件就相应在哪个视图上
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return nil;
}
///长按手势
- (UIView *)hitTestForlongPressedGestureRecognizer:(CGPoint)aPoint{
    return nil;
}
///删除
- (void)deleteAction:(id)sender {
}
//更多
- (void)moreAction:(id)sender {
}
//转发
- (void)transforAction:(id)sender {
}
//收藏
- (void)favoriteAction:(id)sender {
}
- (void)addToEmojiAction:(id)sender {
}
- (void)forwardAction:(id)sender {
}
- (void)showAlbumAction:(id)sender {
}
- (void)playAction:(id)sender {
}
- (void)willDisplayCell{
    
}
///cell将要结束呈现
- (void)didEndDisplayingCell{
    
}
- (UILabel *)dateLabel{
    if (_dateLabel == nil) {
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, App_Frame_Width, 20)];
        _dateLabel.backgroundColor = [UIColor colorWithRed:194/255.0 green:194/255.0 blue:194/255.0 alpha:.7];
        _dateLabel.textColor = [UIColor whiteColor];
        _dateLabel.layer.masksToBounds = YES;
        _dateLabel.layer.cornerRadius = 3.0;
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        _dateLabel.font = [UIFont systemFontOfSize:13];
    }
    return _dateLabel;
}
@end
