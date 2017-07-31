//
//  HQContractTableViewCell.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/4/17.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQContractTableViewCell.h"
#import "ContractModel+Action.h"

@interface HQContractTableViewCell ()

@property (nonatomic,strong) UIButton *headImageBut;
@property (nonatomic,strong) UILabel *nameLabel;

@end

@implementation HQContractTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        [self.contentView addSubview:self.headImageBut];
        [self.contentView addSubview:self.nameLabel];
    }
    return self;
}
- (void)setContractModel:(ContractModel *)contractModel{
    _contractModel = contractModel;
    if (![_contractModel.userType isEqualToString:@"user"]) {
        [_headImageBut setBackgroundImage:[UIImage imageNamed:_contractModel.userHeadImaeUrl] forState:UIControlStateNormal];
    }else{
        if (_contractModel.tempImage) {
            [_headImageBut setBackgroundImage:_contractModel.tempImage forState:UIControlStateNormal];
        }else{
            [_headImageBut setBackgroundImageForState:UIControlStateNormal withURL:[NSURL URLWithString:_contractModel.userHeadImaeUrl] placeholderImage:[UIImage imageNamed:@"icon_avatar"]];
        }
    }
    _nameLabel.text = _contractModel.userName;
}

- (UIButton *)headImageBut{
    if (_headImageBut == nil) {
        _headImageBut = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 40,40)];
        _headImageBut.userInteractionEnabled = NO;
    }
    return _headImageBut;
}

- (UILabel *)nameLabel{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 20, App_Frame_Width-120, 20)];
        _nameLabel.font = [UIFont systemFontOfSize:16];
    }
    return _nameLabel;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
