//
//  MySetiewCell.m
//  HQ_WeChat
//
//  Created by 黄麒展  QQ 757618403 on 2018/1/14.
//  Copyright © 2018年 黄麒展  QQ 757618403. All rights reserved.
//

#import "MySetiewCell.h"


@implementation  MySetModel

- (instancetype)init{
    self = [super init];
    if (self) {
        _cellType = MysetCellSwitchType;
    }
    return self;
}

@end

@implementation MySetiewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end





@implementation  MySetSwitchCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createSubViews];
    }
    return self;
}

- (void)createSubViews{
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 12, 80, 20)];
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.text = @"本地推送";
    [self.contentView addSubview:titleLabel];
    
    
    _sw = [[UISwitch alloc] initWithFrame:CGRectMake(App_Frame_Width-70, 5, 50, 40)];
    [_sw addTarget:self action:@selector(switchControllAction:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:_sw];
}
- (void)setIsOn:(BOOL)isOn{
    _sw.on = isOn;
}
- (void)switchControllAction:(UISwitch *)sender{
//    if (_switchButAction) {
//        _switchButAction(sender.on);
//    }
}


@end
