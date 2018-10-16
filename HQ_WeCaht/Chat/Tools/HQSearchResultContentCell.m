//
//  HQSearchResultContentCell.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/21.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQSearchResultContentCell.h"
#import "ChatListModel+Action.h"
#import "ContractModel+Action.h"
#import "ChatMessageModel+Action.h"


@interface HQSearchResultContentCell ()

@property (nonatomic,strong) UIView *begView;

@end

@implementation HQSearchResultContentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//        self.contentView.backgroundColor = BACKGROUNDCOLOR;
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.begView];
        [self creatSubViews];
    }
    return self;
}
- (void)creatSubViews{
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 30, (App_Frame_Width-80), 20)];
    contentLabel.textColor = [UIColor lightGrayColor];
    contentLabel.text = @"指定搜索的内容";
    contentLabel.font = [UIFont systemFontOfSize:15*SCREENSCALE];
    contentLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:contentLabel];
    CGFloat Width = App_Frame_Width * 2/9;
    for (int i = 0; i<3; i++) {
        UIButton *button  = [[UIButton alloc] initWithFrame:CGRectMake(i*Width, 0, Width, 50)];
        if (i == 0) {
            [button setTitle:@"朋友圈" forState:UIControlStateNormal];
        }else if (i == 1){
            [button setTitle:@"文章" forState:UIControlStateNormal];
        }else{
            [button setTitle:@"公众号" forState:UIControlStateNormal];
        }
        button.titleLabel.font = [UIFont systemFontOfSize:17*SCREENSCALE];
        [button setTitleColor:CANCELBUTTONCOLOR forState:UIControlStateNormal];
        [button addTarget:self action:@selector(searchTitleClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.begView addSubview:button];
    }
}
- (void)searchTitleClickAction:(UIButton *)sender{
    if (_ButtonItemDidClick) {
        _ButtonItemDidClick(sender.titleLabel.text);
    }
}
- (UIView *)begView{
    if (_begView == nil) {
        _begView = [[UIView alloc] initWithFrame:CGRectMake(App_Frame_Width/6.0, 80, App_Frame_Width * 2/3, 100)];
        _begView.backgroundColor = [UIColor clearColor];
    }
    return _begView;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end



@interface HQSearchResultRecentlyContactCell ()

@property (nonatomic,strong) UIImageView *headImageView;
@property (nonatomic,strong) UILabel *nameLabel;
@property (nonatomic,strong) UILabel *contentLabel;

@end

@implementation HQSearchResultRecentlyContactCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.headImageView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.contentLabel];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

- (void)setListModel:(ChatListModel *)listModel{
    _listModel = listModel;
//    [_headImageView sd_setImageWithURL:[NSURL URLWithString:_listModel.messageUser.userHeadImaeUrl] placeholderImage:[UIImage imageNamed:@"mayun.jpg"]];
    _nameLabel.text = _listModel.userName;
    _contentLabel.text = _listModel.chatContent;
}

- (UIImageView *)headImageView{
    if (_headImageView == nil) {
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 40, 40)];
        _headImageView.layer.masksToBounds = YES;
        _headImageView.layer.cornerRadius = 5.0;
    }
    return _headImageView;
}
- (UILabel *)nameLabel{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_headImageView.right +10, 10, App_Frame_Width -90, 20)];
        _nameLabel.font = [UIFont systemFontOfSize:16*SCREENSCALE];
    }
    return _nameLabel;
}
- (UILabel *)contentLabel{
    if (_contentLabel == nil) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(_headImageView.right+10, _nameLabel.bottom, _nameLabel.width, 20)];
        _contentLabel.textColor = [UIColor lightGrayColor];
        _contentLabel.font = [UIFont systemFontOfSize:14*SCREENSCALE];
    }
    return _contentLabel;
    
}
@end




@interface HQSearchResultChatMessageCell ()

@property (nonatomic,strong) UIImageView *headImageView;
@property (nonatomic,strong) UILabel *nameLabel;
@property (nonatomic,strong) UILabel *contentLabel;

@end

@implementation HQSearchResultChatMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.headImageView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.contentLabel];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}
- (void)setMessageModel:(ChatMessageModel *)messageModel{
    _messageModel = messageModel;
//    [_headImageView sd_setImageWithURL:[NSURL URLWithString:_messageModel.userHeadImageString] placeholderImage:[UIImage imageNamed:@"mayun.jpg"]];
    _nameLabel.text = _messageModel.userName;
    _contentLabel.text = _messageModel.contentString;
}

- (UIImageView *)headImageView{
    if (_headImageView == nil) {
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 40, 40)];
        _headImageView.layer.masksToBounds = YES;
        _headImageView.layer.cornerRadius = 5.0;
    }
    return _headImageView;
}
- (UILabel *)nameLabel{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_headImageView.right +10, 10, App_Frame_Width -90, 20)];
        _nameLabel.font = [UIFont systemFontOfSize:16*SCREENSCALE];
    }
    return _nameLabel;
}
- (UILabel *)contentLabel{
    if (_contentLabel == nil) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(_headImageView.right+10, _nameLabel.bottom, _nameLabel.width, 20)];
        _contentLabel.textColor = [UIColor lightGrayColor];
        _contentLabel.font = [UIFont systemFontOfSize:14*SCREENSCALE];
    }
    return _contentLabel;
    
}


@end
