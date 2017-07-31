//
//  HQContactHeadDetailCell.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/16.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQContactHeadDetailCell.h"
#import "ContractModel+Action.h"
#import "ContractModel+Action.h"


@interface HQContactHeadDetailCell ()

@property (nonatomic,strong) UIImageView *headImageView;
@property (nonatomic,strong) UILabel *nameLabel;
@property (nonatomic,strong) UILabel *contentLabel;



@end

@implementation HQContactHeadDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.headImageView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.contentLabel];
    }
    return self;
}


- (void)setContactModel:(ContractModel *)contactModel{
    _contactModel = contactModel;
    [_headImageView sd_setImageWithURL:[NSURL URLWithString:_contactModel.userHeadImaeUrl] placeholderImage:[UIImage imageNamed:@"icon_avatar"]];
    _nameLabel.text = _contactModel.userName;
    _contentLabel.text = @"I donnot know";
}

- (UIImageView *)headImageView{
    if (_headImageView == nil) {
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, App_Frame_Width/6.0, App_Frame_Width/6.0)];
        _headImageView.layer.masksToBounds = YES;
        _headImageView.layer.cornerRadius = 5.0;
    }
    return _headImageView;
}
- (UILabel *)nameLabel{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_headImageView.right+10, 20, (App_Frame_Width - _headImageView.width - 50), 20)];
        _nameLabel.font = [UIFont systemFontOfSize:SCREENSCALE*17];
    }
    return _nameLabel;
}
- (UILabel *)contentLabel{
    if (_contentLabel == nil) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(_headImageView.right + 10, _nameLabel.bottom +5, _nameLabel.width, 20)];
        _contentLabel.font = [UIFont systemFontOfSize:SCREENSCALE*13];
//        _contentLabel.textColor = [UIColor lightGrayColor];
    }
    return _contentLabel;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end


@interface HQContactAccessDetailCell ()

@property (nonatomic,strong) UILabel *titleLabel;

@end

@implementation HQContactAccessDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.titleLabel];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}
- (void)setTitleString:(NSString *)titleString{
    _titleString = titleString;
    _titleLabel.text = _titleString;
}
- (UILabel *)titleLabel{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, App_Frame_Width/2.0-60, 20)];
        _titleLabel.font = [UIFont systemFontOfSize:SCREENSCALE*17];
//        _titleLabel.textColor = [UIColor lightGrayColor];
        _titleLabel.text = @"设置备注和标签";
    }
    return _titleLabel;
}
@end


@interface HQContactPhoneNumCell ()

@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *contnetLabel;

@end

@implementation HQContactPhoneNumCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.contnetLabel];
    }
    return self;
}
- (void)setPhoneString:(NSString *)phoneString{
    _phoneString = phoneString;
    _contnetLabel.text = _phoneString;
}
- (UILabel *)titleLabel{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 85, 20)];
        _titleLabel.font = [UIFont systemFontOfSize:SCREENSCALE*17];
        _titleLabel.text = @"电话号码";
//        _titleLabel.textColor = [UIColor lightGrayColor];
    }
    return _titleLabel;
}
- (UILabel *)contnetLabel{
    if (_contnetLabel == nil) {
        _contnetLabel = [[UILabel alloc] initWithFrame:CGRectMake(_titleLabel.right+10, 10, App_Frame_Width-_titleLabel.width-50, 20)];
        _contnetLabel.textColor = [UIColor blueColor];
        _contnetLabel.font  = [UIFont systemFontOfSize:SCREENSCALE*17];
    }
    return _contnetLabel;
}
@end


@interface HQContactAddressCell ()
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *contnetLabel;

@end

@implementation HQContactAddressCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.contnetLabel];
    }
    return self;
}

- (void)setAddress:(NSString *)address{
    _address = address;
    _contnetLabel.text = _address;
}
- (UILabel *)titleLabel{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 85, 20)];
        _titleLabel.font = [UIFont systemFontOfSize:SCREENSCALE*17];
        _titleLabel.text = @"地区";
//        _titleLabel.textColor = [UIColor lightGrayColor];
    }
    return _titleLabel;
}
- (UILabel *)contnetLabel{
    if (_contnetLabel == nil) {
        _contnetLabel = [[UILabel alloc] initWithFrame:CGRectMake(_titleLabel.right+10, 10, App_Frame_Width-_titleLabel.width-50, 20)];
        _contnetLabel.font  = [UIFont systemFontOfSize:SCREENSCALE*17];
    }
    return _contnetLabel;
}

@end


@interface HQContactFooterView ()

@property (nonatomic,strong) UIButton *sendButton;

@end

@implementation HQContactFooterView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.sendButton];
    }
    return self;
}

- (void)sendButtonAction:(UIButton *)sender{
    if (_sendButtonDidClickCallBack) {
        _sendButtonDidClickCallBack();
    }
}

- (UIButton *)sendButton{
    if (_sendButton == nil) {
        _sendButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, App_Frame_Width-40, 40)];
        _sendButton.backgroundColor = BUTTONBEGCOLOR;
        _sendButton.layer.masksToBounds = YES;
        _sendButton.layer.cornerRadius = 5.0;
        [_sendButton setTitle:@"发消息" forState:UIControlStateNormal];
        [_sendButton addTarget:self action:@selector(sendButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendButton;
}

@end
