//
//  HQDiscoverViewController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/2/20.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQDiscoverViewController.h"
#import "WBTimelineViewController.h"
#import "HQTipView.h"

@interface HQDiscoverViewController (){
    
}

@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) UITableView *tableView;
@end

@implementation HQDiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *butt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [butt addTarget:self action:@selector(rightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [butt setTitle:@"test" forState:UIControlStateNormal];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:butt];
    [self fillData];
    [self.view addSubview:self.tableView];
    
}
- (void)rightButtonAction:(UIButton *)sender{

}
- (void)fillData{
    DiscoverTempModel *model1 = [DiscoverTempModel  new];
    model1.titleStr = @"朋友圈";
    model1.imageName = @"ff_IconShowAlbum";

    [self.dataArray addObject:@[model1]];
    
    DiscoverTempModel *model2 = [DiscoverTempModel  new];
    model2.titleStr = @"扫一扫";
    model2.imageName = @"ff_IconQRCode";
    
    DiscoverTempModel *model3 = [DiscoverTempModel  new];
    model3.titleStr = @"摇一摇";
    model3.imageName = @"ff_IconShake";
    
    [self.dataArray addObject:@[model2,model3]];
    
    DiscoverTempModel *model4 = [DiscoverTempModel  new];
    model4.titleStr = @"附近的人";
    model4.imageName = @"ff_IconLocationService";
    DiscoverTempModel *model5 = [DiscoverTempModel  new];
    model5.titleStr = @"漂流瓶";
    model5.imageName = @"ff_IconBottle";
    [self.dataArray addObject:@[model4,model5]];

    
    DiscoverTempModel *model6 = [DiscoverTempModel  new];
    model6.titleStr = @"购物";
    model6.imageName = @"MoreMyBankCard";
    DiscoverTempModel *model7 = [DiscoverTempModel  new];
    model7.titleStr = @"游戏";
    model7.imageName = @"MoreGame";
    [self.dataArray addObject:@[model6,model7]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataArray[section] count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 20;
    }else{
        return 30;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DisCoverCell *disCell = [tableView dequeueReusableCellWithIdentifier:@"DisCoverCell"];
    disCell.model = self.dataArray[indexPath.section][indexPath.row];
    return disCell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        WBTimelineViewController *weiboVC = [WBTimelineViewController new];
        [self.navigationController pushViewController:weiboVC animated:YES];
    }
}
- (void)messageHandleWith:(ChatMessageModel *)messageModel{
    NSLog(@" faxian contentString = %@",messageModel.contentString);
}
- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, APP_Frame_Height-64) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [_tableView registerClass:[DisCoverCell class] forCellReuseIdentifier:@"DisCoverCell"];
    }
    return _tableView;
}
- (NSMutableArray *)dataArray{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end



@implementation DiscoverTempModel



@end


@interface DisCoverCell ()

@property (nonatomic,strong) UIImageView *titleImage;
@property (nonatomic,strong) UILabel *contentLabel;

@end

@implementation DisCoverCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.titleImage];
        [self.contentView addSubview:self.contentLabel];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}
- (void)setModel:(DiscoverTempModel *)model{
    _model = model;
    _titleImage.image = [UIImage imageNamed:_model.imageName];
    _contentLabel.text = _model.titleStr;
}
- (UIImageView *)titleImage{
    if (_titleImage == nil) {
        _titleImage = [[UIImageView alloc] initWithFrame:CGRectMake(15,9.5, 25, 25)];
    }
    return _titleImage;
}
- (UILabel *)contentLabel{
    if (_contentLabel == nil) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(_titleImage.right+20, 12, 100, 20)];
        _contentLabel.font = [UIFont systemFontOfSize:SCREENSCALE*17];
//        _contentLabel.textColor = [UIColor lightGrayColor];
    }
    return _contentLabel;
}
@end
