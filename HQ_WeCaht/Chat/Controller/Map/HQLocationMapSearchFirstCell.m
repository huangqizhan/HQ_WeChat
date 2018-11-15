//
//  HQLocationMapSearchFirstCell.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/10.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HQLocationMapSearchFirstCell.h"

@interface HQLocationMapSearchFirstCell ()

@property (nonatomic) UIActivityIndicatorView *indicatirView;
@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) UIButton *reloadButton;

@end


@implementation HQLocationMapSearchFirstCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.indicatirView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.reloadButton];
    }
    return self;
}
- (void)setCurrentSearchKye:(NSString *)currentSearchKye{
    _currentSearchKye = currentSearchKye;
    self.nameLabel.text = _currentSearchKye;
}
- (void)setType:(HQLocationMapSearchFirstCellType)type{
    _type = type;
    if (_type == HQLocationMapSearchFirstCellLoadingType) {
        self.nameLabel.hidden = YES;
        [self.indicatirView startAnimating];
        self.reloadButton.hidden = YES;
    }else if (_type == HQLocationMapSearchFirstCellFaildType){
        [self.indicatirView stopAnimating];
        self.nameLabel.hidden = YES;
        self.reloadButton.hidden = NO;
    }else{
        self.nameLabel.hidden = NO;
        [self.indicatirView stopAnimating];
        self.reloadButton.hidden = YES;
    }
}
- (UIActivityIndicatorView *)indicatirView{
    if (_indicatirView == nil) {
        _indicatirView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((App_Frame_Width-50)/2.0, 1, 50, 50)];
        _indicatirView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    }
    return _indicatirView;
}

- (UILabel *)nameLabel{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, App_Frame_Width-45, 20)];
        _nameLabel.font  = [UIFont systemFontOfSize:16];
    }
    return _nameLabel;
}
- (UIButton *)reloadButton{
    if (_reloadButton == nil) {
        _reloadButton = [[UIButton alloc] initWithFrame:CGRectMake((App_Frame_Width-80)/2.0, 1, 50, 40)];
        [_reloadButton addTarget:self action:@selector(reloadButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_reloadButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_reloadButton setTitle:@"reload" forState:UIControlStateNormal];
        [_reloadButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    }
    return _reloadButton;
}
- (void)reloadButtonAction:(UIButton *)sender{
    if (_reloadButtonClick) {
        _reloadButtonClick();
    }
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




@interface HQLocationMapSearchContentCell ()

@property (nonatomic,strong) UILabel *nameLabel;
@property (nonatomic,strong) UILabel *addressLabel;

@end

@implementation HQLocationMapSearchContentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.addressLabel];
    }
    return self;
}
- (void)setPoi:(AMapPOI *)poi{
    _poi = poi;
    self.nameLabel.text = _poi.name;
    self.addressLabel.text = [self getAddressFromAMapPOI:_poi];
}
- (UILabel *)nameLabel{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, App_Frame_Width-45, 20)];
        _nameLabel.font  = [UIFont systemFontOfSize:16];
    }
    return _nameLabel;
}
- (UILabel *)addressLabel{
    if (_addressLabel == nil) {
        _addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 25, App_Frame_Width-45, 20)];
        _addressLabel.textColor = [UIColor lightGrayColor];
        _addressLabel.font = [UIFont systemFontOfSize:13];
    }
    return _addressLabel;
}
- (NSString *)getAddressFromAMapPOI:(AMapPOI *)poi {
    NSString *address;
    if ([poi.city isEqualToString:poi.province]) {
        address = [NSString stringWithFormat:@"%@%@", poi.city, poi.address];
    }else {
        address = [NSString stringWithFormat:@"%@%@%@", poi.province, poi.city, poi.address];
    }
    
    return address;
}
@end



@interface HQLocationMapSearchLoadingFotterView ()

@property (nonatomic) UIActivityIndicatorView *indicatirView;

@end

@implementation HQLocationMapSearchLoadingFotterView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.indicatirView];
    }
    return self;
}


- (UIActivityIndicatorView *)indicatirView{
    if (_indicatirView == nil) {
        _indicatirView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((App_Frame_Width-50)/2.0, 1, 50, 50)];
        _indicatirView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [_indicatirView startAnimating];
    }
    return _indicatirView;
}

@end
