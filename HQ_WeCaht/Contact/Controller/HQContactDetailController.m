//
//  HQContactDetailController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/16.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQContactDetailController.h"
#import "HQContactHeadDetailCell.h"
#import "ChatListModel+Action.h"
#import "ContractModel+Action.h"
#import "HQChatViewController.h"






@interface HQContactDetailController ()

@property (nonatomic,strong) UITableView *tableView;

@end

@implementation HQContactDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"详细资料";
    [self.view addSubview:self.tableView];
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"barbuttonicon_more"] landscapeImagePhone:[UIImage imageNamed:@"CellBlueSelected"] style:UIBarButtonItemStylePlain target:self action:@selector(moreButtonAction)];
    self.navigationItem.rightBarButtonItem = rightBar;
}
- (void)moreButtonAction{
    
}
#pragma mark ------- UITableViewDelegate  && DataSourse 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
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
        return 15;
    }else{
        return 20;
    }
}
- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 2) {
        return 80;
    }else{
        return CGFLOAT_MIN;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return App_Frame_Width/6.0 + 20;
    }
    return 44;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 2) {
        HQContactFooterView *fotterView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"HQContactFooterView"];
        WEAK_SELF;
        [fotterView setSendButtonDidClickCallBack:^{
            [weakSelf pushToChatViewController];
        }];
        return fotterView;
    }else{
        return nil;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        HQContactHeadDetailCell *headViewCell = [tableView dequeueReusableCellWithIdentifier:@"HQContactHeadDetailCell"];
        headViewCell.contactModel = _contactModel;
        return headViewCell;
    }else if (indexPath.section == 1){
        if (indexPath.row == 0) {
            HQContactAccessDetailCell *accessCell = [tableView dequeueReusableCellWithIdentifier:@"HQContactAccessDetailCell"];
            return accessCell;
        }else{
            HQContactPhoneNumCell *phoneCell = [tableView dequeueReusableCellWithIdentifier:@"HQContactPhoneNumCell"];
            phoneCell.phoneString = @"13969768213";
            return phoneCell;
        }
    }else{
        HQContactAddressCell *addressCell = [tableView dequeueReusableCellWithIdentifier:@"HQContactAddressCell"];
        addressCell.address = @"甘肃 白银";
        return addressCell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)pushToChatViewController{
    [ChatListModel searchAnUserChatListOnMainThreadWith:self.contactModel.userId complite:^(ChatListModel *listModel) {
        if (listModel == nil) {
            listModel = [ChatListModel customerInit];
            listModel.messageUser = self.contactModel;
            listModel.chatListType = 1;
            listModel.chatListId = (int64_t)self.contactModel.userId;
            listModel.isShow = NO;
            listModel.userName = self.contactModel.userName;
        }
        HQChatViewController *chatVc = [[HQChatViewController alloc] init];
        HQChatViewController *chatVc1 = [[HQChatViewController alloc] init];
        HQNavigationController *navi1 = self.tabBarController.viewControllers[0];
        HQNavigationController *navi2 = self.tabBarController.viewControllers[1];
        HQMessageBaseController *messagevc = navi1.viewControllers.firstObject;
        [messagevc contactPushToChatViewControllerWith:chatVc andChatMessage:listModel];
        chatVc1.listModel = listModel;
//        [navi1 pushViewController:chatVc animated:NO];
        [navi2 pushViewController:chatVc1 animated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            HQMessageBaseController *baseVC = navi2.viewControllers.firstObject;
            [navi2 popToViewController:baseVC animated:NO];
            self.tabBarController.selectedIndex = 0;
        });
    }];
}
- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, APP_Frame_Height-64) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [_tableView registerClass:[HQContactHeadDetailCell class] forCellReuseIdentifier:@"HQContactHeadDetailCell"];
        [_tableView registerClass:[HQContactAccessDetailCell class] forCellReuseIdentifier:@"HQContactAccessDetailCell"];
        [_tableView registerClass:[HQContactPhoneNumCell class] forCellReuseIdentifier:@"HQContactPhoneNumCell"];
        [_tableView registerClass:[HQContactAddressCell class] forCellReuseIdentifier:@"HQContactAddressCell"];
        [_tableView registerClass:[HQContactFooterView class] forHeaderFooterViewReuseIdentifier:@"HQContactFooterView"];
    }
    return _tableView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
