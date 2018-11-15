//
//  ChatListTableViewCell.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/1.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
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
//        [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:_model.messageUser.userHeadImaeUrl] placeholderImage:[UIImage imageNamed:@"icon_avatar"]];
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
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        [self.contentView addSubview:imageV];
        _avatarImageView = imageV;
        _avatarImageView.layer.masksToBounds = YES;
        _avatarImageView.layer.cornerRadius = 3.0;
        _avatarImageView.image = [UIImage imageNamed:@"icon_avatar"];
    }
    return _avatarImageView;
}
- (UILabel *) usernameLabel{
    if (_usernameLabel == nil) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, App_Frame_Width*0.6, 20)];
        [self.contentView addSubview:label];
        _usernameLabel.font = [UIFont systemFontOfSize:15.0];
        _usernameLabel = label;
    }
    return _usernameLabel;
}
- (UILabel *) dateLabel{
    if (_dateLabel == nil) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(App_Frame_Width - 120, 10, 100, 20)];
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
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(60, 30, App_Frame_Width*0.6, 20)];
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
