//
//  ChatListTableViewCell.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/1.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "ChatListTableViewCell.h"
#import "ContractModel+Action.h"
#import "NSDate+Extension.h"
#import "NSString+Extension.h"
#import "UIImage+Extension.h"


static const CGFloat topPadding = 8;
static const CGFloat leftPadding = 9;

@interface ChatListTableViewCell ()

@property (nonatomic, weak) UIImageView *avatarImageView;
@property (nonatomic, weak) UILabel *usernameLabel;
@property (nonatomic, weak) UILabel *dateLabel;
@property (nonatomic, weak) UILabel *messageLabel;
@property (nonatomic, weak) UIButton *tapTopButton;

@end

@implementation ChatListTableViewCell



- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self avatarImageView];
        [self usernameLabel];
        [self dateLabel];
        [self messageLabel];
        [self unreadLabel];
        [self tapTopButton];
    }
    return self;
}

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *ID = @"ChatListcellId";
    ChatListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[ChatListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}
- (void)layoutSubviews{
    CGFloat imageWidth = self.height - topPadding*2;
    [super layoutSubviews];
    
    [_avatarImageView setFrame:CGRectMake(leftPadding, topPadding, imageWidth, imageWidth)];
    [_dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-9);
        make.top.equalTo(self.mas_top).offset(13);
        make.width.mas_equalTo(70);
    }];
    
    [_usernameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(13);
        make.left.equalTo(_avatarImageView.mas_right).offset(8);
        make.right.equalTo(_dateLabel.mas_left).offset(-5);
    }];
    [_messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_usernameLabel.mas_bottom).offset(4);
        make.left.equalTo(_avatarImageView.mas_right).offset(8);
        make.right.equalTo(_dateLabel.mas_left).offset(-5);
    }];
    
    [_unreadLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_messageLabel.mas_centerY);
        make.right.mas_equalTo(-9);
    }];
}

- (void)setModel:(ChatListModel *)model{
    _model = model;
    if (_model.unReadCount > 0) {
        [self.unreadLabel setTitle:[NSString stringWithFormat:@"%d",_model.unReadCount] forState:UIControlStateNormal];
        [self.unreadLabel setBackgroundImage:[UIImage gxz_imageWithColor:[UIColor redColor]] forState:UIControlStateNormal];
    } else {
        [self.unreadLabel setTitle:@" " forState:UIControlStateNormal];
        [self.unreadLabel setBackgroundImage:[UIImage gxz_imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
    }
    
    
    
    if (_model.chatListType == 100 || _model.chatListType  == 101) {
        _avatarImageView.image = [UIImage imageNamed:@"mayun.jpg"];
    }else{
        [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:_model.messageUser.userHeadImaeUrl] placeholderImage:[UIImage imageNamed:@"icon_avatar"]];
    }
    
    
    [_messageLabel setText:_model.chatContent];
    [_usernameLabel setText:_model.userName];
    _dateLabel.text = [NSDate currentTimevalDescriptionWith:_model.messageTime];
    
    
    
    
    if (_model.topMessageNum > 0) {
        _tapTopButton.hidden = NO;
    }else{
        _tapTopButton.hidden = YES;
    }
}
#pragma mark - Getter and Setter
- (UIImageView *) avatarImageView{
    if (_avatarImageView == nil) {
        UIImageView *imageV = [[UIImageView alloc] init];
        [self.contentView addSubview:imageV];
        _avatarImageView = imageV;
        _avatarImageView.layer.masksToBounds = YES;
        _avatarImageView.layer.cornerRadius = 3.0;
    }
    return _avatarImageView;
}
- (UILabel *) usernameLabel{
    if (_usernameLabel == nil) {
        UILabel *label = [[UILabel alloc] init];
        [self.contentView addSubview:label];
        _usernameLabel.font = [UIFont systemFontOfSize:16.0];
        _usernameLabel = label;
    }
    return _usernameLabel;
}
- (UILabel *) dateLabel{
    if (_dateLabel == nil) {
        UILabel *label = [[UILabel alloc] init];
        [label setTextAlignment:NSTextAlignmentRight];
        [label setTextColor:XZRGB(0xadadad)];
        label.font = [UIFont systemFontOfSize:12.0];
        [self.contentView addSubview:label];
        _dateLabel = label;
    }
    return _dateLabel;
}
- (UIButton *) tapTopButton{
    if (_tapTopButton == nil) {
        UIButton *but = [[UIButton alloc] initWithFrame:CGRectMake(App_Frame_Width-20, 0, 20, 20)];
        [but setBackgroundImage:[UIImage imageNamed:@"置顶.png"] forState:UIControlStateNormal];
        [self.contentView addSubview:but];
        _tapTopButton = but;
    }
    return _tapTopButton;
}
- (UILabel *) messageLabel{
    if (_messageLabel == nil) {
        UILabel *label = [[UILabel alloc] init];
        [label setTextColor:XZRGB(0x9a9a9a)];
        label.font = [UIFont systemFontOfSize:14.0];
        [self.contentView addSubview:label];
        _messageLabel = label;
    }
    return _messageLabel;
}

- (UIButton *)unreadLabel{
    if (_unreadLabel == nil) {
        UIButton *button = [[UIButton alloc] init];
        [self.contentView addSubview:button];
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius  = 8;
        button.contentEdgeInsets   = UIEdgeInsetsMake(1, 5, 1, 5);
        button.titleLabel.font     = [UIFont systemFontOfSize:12.0];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _unreadLabel   = button;
    }
    return _unreadLabel;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
