//
//  HQChatDetailController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/27.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQChatDetailController.h"
#import "HQChatDetailCell.h"
#import "HQActionSheet.h"
#import "UIApplication+HQExtern.h"
#import "ChatListModel+Action.h"
#import "HQSetChatBegImageController.h"




@interface HQChatDetailController ()

@property (nonatomic,strong) UITableView *tableView;

@end

@implementation HQChatDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"聊天详情";
    [self.view addSubview:self.tableView];
}

#pragma mark --------- UITableViewDelelgate   &&dataSourse -----
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }else if (section == 1){
        return 2;
    }else{
        return 1;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return CGFLOAT_MIN;
    }else{
        return 30;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return APP_Frame_Height *1/6.0;
    }else{
        return 44;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        HQChatDetailCell *headCell = [tableView dequeueReusableCellWithIdentifier:@"HQChatDetailCell"];
        headCell.listModel = self.listMOdel;
        WEAK_SELF;
        [headCell setHeadImageViewDidClick:^{
            [weakSelf headImageViewDidClick];
        }];
        return headCell;
    }else if (indexPath.section == 1){
        HQChatDetailSwitchCell *swchCell = [tableView dequeueReusableCellWithIdentifier:@"HQChatDetailSwitchCell"];
        if (indexPath.row == 0) {
            swchCell.titleString = @"置顶聊天";
            swchCell.ison = self.listMOdel.isPlaceTop;
        }else{
            swchCell.titleString = @"消息免打扰";
            swchCell.ison = self.listMOdel.isMessageRemind;
        }
        WEAKSELF;
        [swchCell setSwitchDidClick:^(NSString *titleStr , BOOL isOn){
            [weakSelf switchButton:titleStr StatusDidChanaged:isOn];
        }];
        return swchCell;
    }else if (indexPath.section == 2){
        HQChatDetailAccessCell *accessCell = [tableView dequeueReusableCellWithIdentifier:@"HQChatDetailAccessCell"];
        return accessCell;
    }else{
        HQChatDetailNoAccessCell *noAccessCell = [tableView dequeueReusableCellWithIdentifier:@"HQChatDetailNoAccessCell"];
        return noAccessCell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 2) {
        [self setChatBackGroundImage];
    }else if (indexPath.section == 3) {
        [self clearCurrnetChatMessages];
    }
}
#pragma mark-------- 设置聊天背景 ------
- (void)setChatBackGroundImage{
    HQSetChatBegImageController *setBegVC = [[HQSetChatBegImageController alloc] init];
    setBegVC.listModel = self.listMOdel;
    [setBegVC setChatDetailCallBack:^(NSString *titleType){
        if (_chatDetailCallBack) {
            _chatDetailCallBack(@"设置背景图片");
        }
    }];
    [self.navigationController pushViewController:setBegVC animated:YES];
}
#pragma mark ------- 清除聊天数据 ------
- (void)clearCurrnetChatMessages{
    [self showCustomerActionSheetViewWithTitle:@"是否删除聊天数据?"];
}
#pragma mark -------- 点击头像 ------
- (void)headImageViewDidClick{
    NSLog(@"headImageViewDidClick");
}
#pragma mark -------  置顶聊天  消息免打扰 ---------
- (void)switchButton:(NSString *)titleStr StatusDidChanaged:(BOOL) isOn{
    if ([titleStr isEqualToString:@"置顶聊天"]) {
        [self.listMOdel chatListPlaceToTopWithIsOn:isOn Complite:^{
            NSLog(@"conplite");
        }];
    }else{
        self.listMOdel.isMessageRemind = isOn;
        [self.listMOdel UpDateFromDBONMainThread:^{
            NSLog(@"update success");
        } andError:^{
            NSLog(@"update faild");
        }];
    }
}
- (void)showCustomerActionSheetViewWithTitle:(NSString *)title{
    HQActionSheet *actionSheet = [[HQActionSheet alloc] initWithTitle:title];
    HQActionSheetAction *action = [HQActionSheetAction actionWithTitle:@"删除" handler:^(HQActionSheetAction *action) {
        [ChatMessageModel deleteChatGroupMessageWith:self.listMOdel andComplite:^(BOOL isSuccess) {
            if (_chatDetailCallBack) {
                _chatDetailCallBack(@"清除聊天数据");
            }
        }];
    } style:HQActionStyleDestructive];
    [actionSheet addAction:action];
    [actionSheet showInWindow:[UIApplication popOverWindow]];
}





#pragma mark-------- Gettte  Setter --------
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, APP_Frame_Height-64) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[HQChatDetailCell class] forCellReuseIdentifier:@"HQChatDetailCell"];
        [_tableView registerClass:[HQChatDetailSwitchCell class] forCellReuseIdentifier:@"HQChatDetailSwitchCell"];
        [_tableView registerClass:[HQChatDetailAccessCell class] forCellReuseIdentifier:@"HQChatDetailAccessCell"];
        [_tableView registerClass:[HQChatDetailNoAccessCell class] forCellReuseIdentifier:@"HQChatDetailNoAccessCell"];
    }
    return _tableView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
