//
//  SetViewController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/11/16.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "SetViewController.h"
#import "LocalNotoficationHelper.h"
#import "LocalStatusModel+Action.h"


@interface SetViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) LocalStatusModel *localModel;

@end

@implementation SetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"设置";
    [LocalStatusModel searchChatListModelOnAsyThreadComplite:^(NSArray<LocalStatusModel *> *resultList) {
        if (resultList.count) {
            _localModel = resultList.firstObject;
        }else{
            _localModel = [LocalStatusModel customerInit];
            _localModel.isOpenLoaclNotification = NO;
        }
         [self.tableView reloadData];
    }];
    [self.view addSubview:self.tableView];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
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
    LoacalNotificationCell *notifiCell = [tableView dequeueReusableCellWithIdentifier:@"LoacalNotificationCell"];
    WEAKSELF;
    [notifiCell setSwitchButAction:^(BOOL isOn) {
        [weakSelf setLocalNotification:isOn];
    }];
    notifiCell.isOn = _localModel.isOpenLoaclNotification;
    return notifiCell;
}
- (void)setLocalNotification:(BOOL)isOn{
    if (isOn) {
        [LocalNotoficationHelper addLoaclNotification];
    }else{
        [LocalNotoficationHelper removeLoaclnotification];
    }
    _localModel.isOpenLoaclNotification = isOn;
    [_localModel saveToDBChatLisModelAsyThread:^(BOOL result) {
        NSLog(@"_localModel  保存成功");
    }];
}
- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, APP_Frame_Height-64) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[LoacalNotificationCell class] forCellReuseIdentifier:@"LoacalNotificationCell"];
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _tableView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end

@interface   LoacalNotificationCell ()

@property (nonatomic,strong)UISwitch *sw;

@end


@implementation   LoacalNotificationCell

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
    if (_switchButAction) {
        _switchButAction(sender.on);
    }
}
@end
