//
//  HQDownLoadTbaleViewCell.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/5/23.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQDownLoadTbaleViewCell.h"
#import "HQDownLoadFile.h"

@interface HQDownLoadTbaleViewCell ()



@property (strong,nonatomic) UILabel *titleLabel;
@property (nonatomic,strong) UIProgressView *proGressView;
@property (nonatomic,strong) UILabel *speedLabel;
@property (nonatomic,strong) UIButton *downLoadButton;


@end



@implementation HQDownLoadTbaleViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.proGressView];
        [self.contentView addSubview:self.speedLabel];
        [self.contentView addSubview:self.downLoadButton];
    }
    return self;
}
- (void)setTempMpdel:(HQDownLoadTempModel *)tempMpdel{
    _tempMpdel  =tempMpdel;
    self.titleLabel.text = [_tempMpdel.urlStr lastPathComponent];
    if (_tempMpdel.status == HQDownLoadFileStatusLoading) {
        [self.downLoadButton setTitle:@"暂停" forState:UIControlStateNormal];
    }else if (_tempMpdel.status == HQDownLoadFileStatusFaild ){
        [self.downLoadButton setTitle:@"重新下载" forState:UIControlStateNormal];
    }else if (_tempMpdel.status == HQDownLoadFileStatusSuspend){
        [self.downLoadButton setTitle:@"继续下载" forState:UIControlStateNormal];
    }else if (_tempMpdel.status == HQDownLoadFileStatusWaiting) {
        [self.downLoadButton setTitle:@"等待下载" forState:UIControlStateNormal];
    }else if (_tempMpdel.status == HQDownLoadFileStatusComplite) {
        [self.downLoadButton setTitle:@"播放" forState:UIControlStateNormal];
    }else if (_tempMpdel.status == HQDownLoadFileStatusNone){
        [self.downLoadButton setTitle:@"下载" forState:UIControlStateNormal];
    }
    self.proGressView.progress = _tempMpdel.progress.fractionCompleted;
    self.speedLabel.text = _tempMpdel.speed;
}
- (UILabel *)titleLabel{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 20)];
    }
    return _titleLabel;
}
- (UIProgressView *)proGressView{
    if (_proGressView == nil) {
        _proGressView = [[UIProgressView alloc] initWithFrame:CGRectMake(10, 40, App_Frame_Width-20, 20)];
        _proGressView.transform = CGAffineTransformMakeScale(1.0f,3.0f);
        _proGressView.tintColor = [UIColor blueColor];
        _proGressView.backgroundColor = [UIColor grayColor];
    }
    return _proGressView;
}
- (UILabel *)speedLabel{
    if (_speedLabel == nil) {
        _speedLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, 100, 20)];
    }
    return _speedLabel;
}
- (UIButton *)downLoadButton{
    if (_downLoadButton == nil) {
        _downLoadButton = [[UIButton alloc] initWithFrame:CGRectMake(App_Frame_Width-100, 60, 50, 80)];
        [_downLoadButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_downLoadButton setTitle:@"下载" forState:UIControlStateNormal];
        [_downLoadButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_downLoadButton addTarget:self action:@selector(downLoadButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _downLoadButton;
}
- (void)downLoadButtonAction:(UIButton *)sender{
    if (_tempMpdel.status == HQDownLoadFileStatusLoading) {
        [self suspendDownLoad];
    }else if (_tempMpdel.status == HQDownLoadFileStatusFaild ){
        [self startDownLoad];
    }else if (_tempMpdel.status == HQDownLoadFileStatusSuspend){
        [self startDownLoad];
    }else if (_tempMpdel.status == HQDownLoadFileStatusWaiting) {
        
    }else if (_tempMpdel.status == HQDownLoadFileStatusComplite) {
        [self playFile];
    }else if (_tempMpdel.status == HQDownLoadFileStatusNone){
        [self startDownLoad];
    }
}
#pragma mark ------- 下载 -----
- (void)startDownLoad{
    [[HQDownLoadFile DefaultManager] downLoadWithUrl:_tempMpdel process:^(NSProgress * _Nullable process, HQDownLoadTempModel * _Nullable receipt) {
        self.proGressView.progress = process.fractionCompleted;
        self.speedLabel.text = receipt.speed;
        [self.downLoadButton setTitle:@"暂停" forState:UIControlStateNormal];
    } success:^(NSURLRequest * _Nullable request, NSHTTPURLResponse * _Nullable response, NSURL * _Nullable url) {
        [self.downLoadButton setTitle:@"播放" forState:UIControlStateNormal];
    } failure:^(NSURLRequest * _Nullable request, NSHTTPURLResponse * _Nullable response, NSError * _Nullable error) {
        [self.downLoadButton setTitle:@"重新下载" forState:UIControlStateNormal];
    }];
}
#pragma mark ------- 暂停 -----
- (void)suspendDownLoad{
    [[HQDownLoadFile DefaultManager] suspendWithDownloadReceipt:_tempMpdel];
}
#pragma mark ------- 播放 ----
- (void)playFile{
    if (_delegate && [_delegate respondsToSelector:@selector(HQDownLoadTbaleViewCell:PlayClickWith:)]) {
        [_delegate HQDownLoadTbaleViewCell:self PlayClickWith:_tempMpdel];
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
