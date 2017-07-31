//
//  HQChatDetailCell.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/27.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQChatDetailCell.h"
#import "UIButton+WebCache.h"

@interface HQChatDetailCell ()

@property (nonatomic,strong) HQRectButton *button;
@end


@implementation HQChatDetailCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self creatSubViews];
    }
    return self;
}
- (void)creatSubViews{
    CGFloat buttonwidth = (App_Frame_Width - App_Frame_Width *6/16)/5.0;
    CGFloat buttonheight = APP_Frame_Height/6.0 * 2.0/3.0;
    _button = [[HQRectButton alloc] initWithFrame:CGRectMake(15, (APP_Frame_Height/6.0 * 1.0/6.0), buttonwidth, buttonheight)];
    [_button setImageRect:CGRectMake(0, 0, buttonwidth, buttonwidth)];
    [_button setTitleRect:CGRectMake(0, buttonwidth, buttonwidth, buttonheight-buttonwidth)];
    [_button addTarget:self action:@selector(headButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    _button.backgroundColor = [UIColor clearColor];
    _button.layer.masksToBounds = YES;
    _button.titleLabel.font = [UIFont systemFontOfSize:13*SCREENSCALE];
    _button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    _button.layer.cornerRadius = 5.0;
    [self.contentView addSubview:_button];
}
- (void)setListModel:(ChatListModel *)listModel{
    _listModel = listModel;
    [_button sd_setImageWithURL:[NSURL URLWithString:self.listModel.messageUser.userHeadImaeUrl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"icon_album_picture_fail_big"]];
    [_button setTitle:self.listModel.userName forState:UIControlStateNormal];
}
- (void)headButtonDidClick{
    if (_headImageViewDidClick) {
        _headImageViewDidClick();
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

@interface HQChatDetailSwitchCell ()

@property (nonatomic,strong) UILabel *contentLabel;
@property (nonatomic,strong) UISwitch *swch;
@end

@implementation HQChatDetailSwitchCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.contentLabel];
        [self.contentView addSubview:self.swch];
    }
    return self;
}
- (void)setTitleString:(NSString *)titleString{
    _titleString = titleString;
    _contentLabel.text = _titleString;
}
- (void)setIson:(BOOL)ison{
    [_swch setOn:ison animated:NO];
}
- (UILabel *)contentLabel{
    if (_contentLabel == nil) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, App_Frame_Width/3.0, 20)];
//        _contentLabel.textColor = [UIColor grayColor];
        _contentLabel.font  = [UIFont systemFontOfSize:SCREENSCALE*17];
    }
    return _contentLabel;
}

- (UISwitch *)swch{
    if (_swch == nil) {
        _swch = [[UISwitch alloc] initWithFrame:CGRectMake(App_Frame_Width-80, 5, 50, 34)];
        [_swch addTarget:self action:@selector(swchDidClickAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _swch;
}
- (void)swchDidClickAction:(UISwitch *)swch{
    if (_switchDidClick) {
        _switchDidClick(_contentLabel.text,swch.isOn);
    }
}
@end



@interface HQChatDetailAccessCell ()

@property (nonatomic,strong) UILabel *contentLabel;

@end

@implementation HQChatDetailAccessCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.contentLabel];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}
- (UILabel *)contentLabel{
    if (_contentLabel == nil) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, App_Frame_Width/3.0, 20)];
//        _contentLabel.textColor = [UIColor grayColor];
        _contentLabel.font  = [UIFont systemFontOfSize:SCREENSCALE*17];
        _contentLabel.text = @"设置背景聊天";
    }
    return _contentLabel;
}

@end

@interface HQChatDetailNoAccessCell ()

@property (nonatomic,strong) UILabel *contentLabel;

@end


@implementation HQChatDetailNoAccessCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.contentLabel];
    }
    return self;
}
- (UILabel *)contentLabel{
    if (_contentLabel == nil) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, App_Frame_Width/3.0, 20)];
//        _contentLabel.textColor = [UIColor grayColor];
        _contentLabel.font  = [UIFont systemFontOfSize:SCREENSCALE*17];
        _contentLabel.text = @"清除聊天记录";
    }
    return _contentLabel;
}

@end
