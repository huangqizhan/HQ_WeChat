//
//  HQMineViewController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/2/20.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQMineViewController.h"
#import "SetViewController.h"
#import "StudyViewController.h"


@interface HQMineViewController ()<UITableViewDelegate,UITableViewDataSource>{
    
}
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataArray;

@end

@implementation HQMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, APP_Frame_Height-64-49) style:UITableViewStyleGrouped];
    [_tableView registerClass:[MineHeadCell class] forCellReuseIdentifier:@"MineHeadCell"];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    if (@available(iOS 11.0, *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.view addSubview:_tableView];
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }else{
        return 2;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 80;
    }else{
        return 44;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        MineHeadCell *headCell = [tableView dequeueReusableCellWithIdentifier:@"MineHeadCell"];
        return headCell;
    }
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Set";
    }else{
        cell.textLabel.text = @"Study";
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section) {
        if (indexPath.row == 0) {
            SetViewController *setvc = [SetViewController new];
            [self.navigationController pushViewController:setvc animated:YES];
        }else{
            StudyViewController *studyVC = [StudyViewController new];
            [self.navigationController pushViewController:studyVC animated:YES];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


@implementation  MineHeadCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle  = UITableViewCellSelectionStyleNone;
        [self createSubViews];
    }
    return self;
}
- (void)createSubViews{
    UIImageView *headImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 60, 60)];
    headImage.layer.masksToBounds = YES;
    headImage.layer.cornerRadius = 5.0;
    headImage.backgroundColor = [UIColor blackColor];
    [self.contentView addSubview:headImage];
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(headImage.right +20, 25, App_Frame_Width/2.0, 30)];
    contentLabel.textAlignment = NSTextAlignmentCenter;
    NSString *content = @"HQ_WeChat  for Study";
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           [UIFont fontWithName:@"Helvetica-Bold" size:16], NSFontAttributeName, nil];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:content attributes:attrs ];
    contentLabel.attributedText = attStr;
    [self.contentView addSubview:contentLabel];
    
}


@end
