//
//  HQChatListViewController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/2/20.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQChatListViewController.h"
#import "HQChatListSearchController.h"
#import "HQChatViewController.h"
#import "ContractModel+Action.h"
#import "HQGifPlayManager.h"
#import "UIViewController+HQPresentTranstion.h"









@interface HQChatListViewController ()
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) HQSearchBar *searchbar;

@end

@implementation HQChatListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    [self loadDataSource];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(testButtonAction)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"msg" style:UIBarButtonItemStylePlain target:self action:@selector(testAction:)];

}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self customerReloadTableView];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self removeTranstionDelegate];
}
- (void)saveUIDataWhenApplicationWillDissmiss{
    for (ChatListModel *list in self.dataArray) {
        [list UPDateFromDBOnOtherThread:nil andError:nil];
    }
}
- (void)testButtonAction{
    
//    ChatListModel *sysList = [ChatListModel customerInit];
//    sysList.chatListType = 100;
//    sysList.userName = @"系统消息";
//    sysList.isShow = NO;
//    [sysList saveToDBChatLisModelAsyThread:^{
//        NSLog(@"sys save success");
//    } andError:^{
//        NSLog(@"sys save faild");
//    }];
//    ChatListModel *workList = [ChatListModel customerInit];
//    workList.chatListType = 101;
//    workList.userName = @"工作通知";
//    workList.isShow = NO;
//    [workList saveToDBChatLisModelAsyThread:^{
//        NSLog(@"work save success");
//    } andError:^{
//        NSLog(@"work save faild");
//    }];
    [ContractModel searchUserModelOnAsyThread:^(NSArray *resultList,NSArray *locaArr) {
        for (ContractModel *con in resultList) {
            ChatListModel *list = [ChatListModel customerInit];
            list.messageUser = con;
            list.chatListType = 1;
            list.chatListId = con.userId;
            list.isShow = NO;
            list.userName = con.userName;
            [list saveToDBChatLisModelAsyThread:^{
                NSLog(@" user save success");
            } andError:^{
                NSLog(@" user save error");
            }];
        }
    }];
}
- (void)testAction:(UIBarButtonItem *)item{
    NSDictionary *diction = [self  creatTextNessageWithIndex:1];
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationReceiveNewMessageNotification object:diction];
}
- (NSDictionary *)creatTextNessageWithIndex:(int )index{
    NSTimeInterval timeral = [NSDate returnTheTimeralFrom1970];
    NSDictionary *dic = @{
                          @"contentString":@"看惊世毒妃v看看惊世毒妃v看计算的报价单上发布就不会接口的宝贝计划快递费看见对方v加上空的返回v圣诞节开发v",
                          @"contentUrlString":@"",
                          @"fileExtion":@"",
                          @"fileName":@"",
                          @"filePath":@"",
                          @"fileSize":@"",
                          @"isGroupChat":@0,
                          @"messageId":[NSNumber numberWithInt:index],
                          @"messageStatus":@0,
                          @"messageTime":[NSNumber numberWithDouble:timeral+index],
                          @"messageType":@1,
                          @"modelConfig":@"",
                          @"receiveId":@10001,
                          @"requestProcess":@0,
                          @"requestTimeral":@0,
                          @"speakerId":@24,
                          @"tempPath":@"",
                          @"userHeadImageString":@"http://d.lanrentuku.com/down/png/1610/16young-avatar-collection/boy-2.png",
                          @"userName":@"刘威"
                          };
    
    return dic;
}

- (void)setUpUI{
    self.tableView.backgroundColor = XZRGB(0xf4f1f1);
    _searchbar = [HQSearchBar defaultSearchBar];;
//    [_searchbar setImage:[UIImage imageNamed:@"VoiceSearchStartBtn"] forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateNormal];
//    _searchbar.showsBookmarkButton = YES;
//    _searchbar.tintColor = CANCELBUTTONCOLOR;
//    [_searchbar.layer setBorderWidth:0.5f];
//    [_searchbar.layer setBorderColor:BACKGROUNDCOLOR.CGColor];
//    [_searchbar sizeToFit];
//    _searchbar.placeholder = @"搜索";
//    [_searchbar setBarTintColor:BACKGROUNDCOLOR];
    _searchbar.delegate = self;
    self.tableView.tableHeaderView = _searchbar;
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:CANCELBUTTONCOLOR,NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    self.tableView.frame  = CGRectMake(0,0, self.view.width, APP_Frame_Height-64);
}
- (void)loadDataSource{
    [ChatListModel selectChatListShowOnOtherThreadWith:^(NSArray *result) {
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:result];
        [self customerReloadTableView];
    }];
}
- (void)refershCurrnetListViewIsAppear:(BOOL)isAppear{
    if (isAppear) {
        [self.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
    }else{
        [self.tableView setContentOffset:CGPointMake(0, 44) animated:NO];
    }
}
///消息分发测试
- (void)messageHandleWith:(ChatMessageModel *)messageModel{
    NSString *filterStr = [NSString stringWithFormat:@"chatListId = %d",messageModel.speakerId];
    NSPredicate *pre = [NSPredicate predicateWithFormat:filterStr];
    NSArray *result = [self.dataArray filteredArrayUsingPredicate:pre];
    if (result.count) {
        [self checkNewMessageModelIsCurrentVCWith:result.firstObject andMessage:messageModel];
    }else{
        [ChatListModel customerSearchAnUserChatListWith:messageModel.speakerId complite:^(ChatListModel *Model) {
            if (Model) {
                Model.isShow = YES;
                [self.dataArray addObject:Model];
                [self checkNewMessageModelIsCurrentVCWith:Model andMessage:messageModel];
            }
        }];
    }
}
- (void)checkNewMessageModelIsCurrentVCWith:(ChatListModel *)listModel andMessage:(ChatMessageModel *)msgModel{
    if ([self.navigationController.visibleViewController isKindOfClass:[HQChatListViewController class]]) {
        listModel.unReadCount +=1;
    }else{
        listModel.unReadCount = 0;
    }
    listModel.message = msgModel;
    [self customerReloadTableView];
}
#pragma mark ------ UItableViewDelegate ------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ChatListTableViewCell *ChatListcell = [ChatListTableViewCell cellWithTableView:tableView];
    ChatListcell.model = _dataArray[indexPath.row];
    return ChatListcell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 67.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10.f;
}
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    ChatListModel *currentListModel = self.dataArray[indexPath.row];
    UITableViewRowAction * deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self deleteCellMessageWith:indexPath];
    }];
    UITableViewRowAction * topRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"置顶" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
                [self setTopCellWithIndexPath:indexPath];
    }];
    topRowAction.backgroundColor  = [UIColor orangeColor];
    UITableViewRowAction *cancekTopRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"取消置顶" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self cancelTopCellRowAction:indexPath];
    }];
    cancekTopRowAction.backgroundColor  = [UIColor grayColor];

    if (currentListModel.topMessageNum > 0) {
        return  @[deleteRowAction,cancekTopRowAction];
    }else{
        return  @[deleteRowAction,topRowAction];
    }
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ChatListModel *group  = self.dataArray[indexPath.row];
    HQChatViewController *chatVc = [[HQChatViewController alloc] init];
    chatVc.listModel = group;
    [self.navigationController pushViewController:chatVc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark ------- 取消置顶 --------
- (void)cancelTopCellRowAction:(NSIndexPath *)indexPath{
    ChatListModel *listModel = self.dataArray[indexPath.row];
    listModel.topMessageNum = 0;
    [listModel UPDateFromDBOnOtherThread:nil andError:nil];
    [self customerReloadTableView];
}
#pragma mark ------- 置顶 ------
- (void)setTopCellWithIndexPath:(NSIndexPath *)indexPath{
    ChatListModel *fristModel = [self.dataArray firstObject];
    ChatListModel *listModel = self.dataArray[indexPath.row];
    listModel.topMessageNum = fristModel.topMessageNum+1;
    [listModel UPDateFromDBOnOtherThread:nil andError:nil];
    [self customerReloadTableView];
}
#pragma mark -------- 删除 -------
- (void)deleteCellMessageWith:(NSIndexPath *)indexPath{
    ChatListModel *listModel = self.dataArray[indexPath.row];
    if (listModel && indexPath) {
        listModel.isShow = NO;
        [self.tableView reloadData];
        [self.dataArray removeObject:listModel];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
        [listModel UPDateFromDBOnOtherThread:^{
            NSLog(@"delete success");
        } andError:^{
            NSLog(@"delete filad");
        }];
        [ChatMessageModel deleteChatGroupMessageWith:listModel andComplite:^(BOOL isSuccess) {
            NSLog(@"isSuccesss = %d",isSuccess);
        }];
    }

}
#pragma mark ------ Private  排序刷新 -----
- (void)customerReloadTableView{
    NSSortDescriptor *des2 = [[NSSortDescriptor alloc] initWithKey:@"topMessageNum" ascending:NO];
    NSSortDescriptor *des1 = [[NSSortDescriptor alloc] initWithKey:@"messageTime" ascending:NO];
    [self.dataArray sortUsingDescriptors:@[des2,des1]];
    [self.tableView reloadData];
}
- (void)contactPushToChatViewControllerWith:(HQMessageBaseController *)messsVC andChatMessage:(ChatListModel *)listModel{
    if ([messsVC isKindOfClass:[HQChatViewController class]]) {
        HQChatViewController *chatVC = (HQChatViewController *)messsVC;
        chatVC.listModel = listModel;
        WEAKSELF;
        [chatVC setReloadChatListFromDBCallBack:^{
            [weakSelf loadDataSource];
        }];
        [self.navigationController pushViewController:chatVC animated:NO];
    }
}
#pragma mark -------- UISearchBarDelegate --------
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    HQChatListSearchController *searchResultVC = [[HQChatListSearchController alloc] init];
    HQNavigationController *nav = [[HQNavigationController alloc] initWithRootViewController:searchResultVC];
    nav.view.backgroundColor = [UIColor clearColor];
    WEAKSELF;
    [searchResultVC setRefershChatListMessage:^{
        [weakSelf loadDataSource];
    }];
    [searchResultVC showInViewController:self fromSearchBar:self.searchbar];
    return NO;
}
#pragma mark ------- setter and getter --------
- (UITableView *)tableView{
    if (nil == _tableView) {
        UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        tableView.delegate = self;
        tableView.dataSource = self;
        [self.view addSubview:tableView];
        _tableView = tableView;
    }
    return _tableView;
}
- (NSMutableArray *)dataArray{
    if (nil == _dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return  _dataArray;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
