//
//  HQChatListViewController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/2/20.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HQChatListViewController.h"
#import "HQChatListSearchController.h"
#import "HQChatViewController.h"
#import "ContractModel+Action.h"
#import "UIViewController+HQPresentTranstion.h"
#import "HQPopoverAction.h"
#import "HQPopoverView.h"
#import "HQQRCodeViewController.h"
#import "ApplicationHelper.h"
#import "ARTestViewController.h"
#import "AR2DTestViewController.h"






@interface HQChatListViewController (){
    UIView *_testView;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) HQSearchBar *searchbar;

@end

@implementation HQChatListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    [self loadDataSource];
    UIButton *popBut = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [popBut setTitle:@"pop" forState:UIControlStateNormal];
    [popBut addTarget:self action:@selector(testButtonAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:popBut];
    
    UIButton *msgBut = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [msgBut setTitle:@"msg" forState:UIControlStateNormal];
    [msgBut addTarget:self action:@selector(testAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:msgBut];
    NSLog(@"home = %@",NSHomeDirectory());
    
//    CGRect rect= CGRectMake(20, 50, 100, 80);
//    UIEdgeInsets ed=UIEdgeInsetsMake(-3, -4, -5, -6);
//    CGRect  r=  UIEdgeInsetsInsetRect(rect, ed);
//    NSLog(@"%@",r);
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self customerReloadTableView];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self removeTranstionDelegate];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
- (void)saveUIDataWhenApplicationWillDissmiss{
    for (ChatListModel *list in self.dataArray) {
        [list UPDateFromDBOnOtherThread:nil andError:nil];
    }
}
- (void)testButtonAction{
    HQPopoverView *popoverView = [HQPopoverView popoverView];
    popoverView.style = HQHQPopoverActionDarkStyle;
    [popoverView showToPoint:CGPointMake(App_Frame_Width, 64) withActions:[self  getQQActions]];
}
- (void)testAction:(UIBarButtonItem *)item{
//    NSDictionary *diction = [self  creatTextNessageWithIndex:1];
//    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationReceiveNewMessageNotification object:diction];
}
- (NSDictionary *)creatTextNessageWithIndex:(int )index{
    NSTimeInterval timeral = [NSDate returnTheTimeralFrom1970];
    NSDictionary *dic = @{
                          @"contentString":@"新华社呼和浩特9月11日电 《联合国防治荒漠化公约》第十三次缔约方大会高级别会议11日在内蒙古鄂尔多斯市开幕。13969768213国家主席习近平发来贺信，向会议的召开致以热烈的祝贺，向出席会议的各国代表、http://news.xinhuanet.com/politics/2017-09/11/c_1121644248.htm国际机构负责人和各界人士致以诚挚的欢迎，并预祝大会圆满成功。习近平指出，13969768213土地荒漠化是影响人类生存和发展的全球重大生态问题。公约生效21年来，在各方共同努力下http://news.xinhuanet.com/politics/2017-09/11/c_1121644248.htm，全球荒漠化防治取得明显成效，但形势依然严峻，世界上仍有许多地方的人民饱受荒漠化之苦。http://news.xinhuanet.com/politics/2017-09/11/c_1121644248.htm这次大会以“携手防治荒漠，http://news.xinhuanet.com/politics/2017-09/11/c_1121644248.htm共谋人类福祉”为主题，共议公约新战略框架13969768213，http://news.xinhuanet.com/politics/2017-09/11/c_1121644248.htm必将对维护全球生态安全产生重大而积极的影响。习近平强调，防治荒漠化是人类面临的共同挑战，需要国际社会携手应对。我们要弘扬尊重自然、保护自然的理念，坚13969768213持生态优先、13969768213预防为主，坚定信心，面向未来，制定广泛合作、目标明确的公约新战略框架，共同推进全球荒漠生态系统治理，让荒漠造福人类。http://news.xinhuanet.com/politics/2017-09/11/c_1121644248.htm中国将坚定不移履行公约义务，按照本次缔约方大会确定的目标，一如既往加强同各成员国13969768213和国际组织的交流合作，共同为建设一个更加美好的世界而努力。国务院副总理汪洋在开幕式上宣读了习近平的贺信并发表主旨演讲。他强调，http://news.xinhuanet.com/politics/2017-09/11/c_1121644248.htm中国将认真履行习近平主席在139697682132015年联合国发展13969768213峰会上的郑重承诺，以落实2030年可持续发展议程为己任，http://news.xinhuanet.com/politics/2017-09/11/c_1121644248.htm以新发展理念为引领，把防治荒漠化作为生态文明建设的重要内容，全面加强国际交流合作，http://news.xinhuanet.com/politics/2017-09/11/c_1121644248.htm努力走出一条中国特色荒漠生态系统治理和民生改善相结合的13969768213道路。联合国秘书长古特雷斯向会议发来视13969768213频致辞。《联合国防治荒漠化公约》是联合国里约可持续发展大会框架下的三大环境公约之一，旨在推动国际社会在防治荒漠化和缓解干旱影响方面加强合作。13969768213缔约方大会是公约的最高决策机构，目前13969768213每两年举行一次，来自196个公约缔约方、20多个国际组织的正式代表约1400人出席本次会议http://news.xinhuanet.com/politics/2017-09/11/c_1121644248.htm。　相关报道：习近平致《联合国防治荒漠化公约》第十三次缔约方大会高级别会议的贺信　防治荒漠化是人类面临的共同挑战，需要国际社会携手应对。http://news.xinhuanet.com/politics/2017-09/11/c_1121644248.htm我们要弘扬尊重自然、保护自然的理念，坚持生态优13969768213先、预防为主，坚定信心，面向未来，制定广泛合作、目标明确的公约新战略框架，共同推进全球荒漠生态系统治理，让荒漠造福13969768213人类。http://news.xinhuanet.com/politics/2017-09/11/c_1121644248.htm中国将坚定不移履行公约义务，按照本次缔约方大会确定的目标，http://news.xinhuanet.com/politics/2017-09/11/c_1121644248.htm一如既往加强同各成员国和国际组织的交13969768213流合作，共同为建设一个更加美好13969768213的世界而努力！>>http://news.xinhuanet.com/politics/2017-09/11/c_1121644248.htm sdkjfnvksdjfv  file:///Applications/XAMPP/xamppfiles/htdocs/header/static/Test.html  ",
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
    [self.view addSubview:self.tableView];
    _searchbar = [HQSearchBar defaultSearchBarWithIsActive:NO];
    _searchbar.delegate = self;
    self.tableView.tableHeaderView = _searchbar;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
//    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:CANCELBUTTONCOLOR,NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
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
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ChatListTableViewCell *ChatListcell = [ChatListTableViewCell cellWithTableView:tableView];
    ChatListcell.model = _dataArray[indexPath.row];
    return ChatListcell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
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
////缩进
//- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSLog(@"indentationLevelForRowAtIndexPath = %@",indexPath);
//    return indexPath.row;
//}
//- (NSArray<UIDragItem *> *)tableView:(UITableView *)tableView itemsForBeginningDragSession:(id<UIDragSession>)session atIndexPath:(NSIndexPath *)indexPath{
//    return nil;
//}
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
- (NSArray <HQPopoverAction *> *)getQQActions{
    // AR3D action
    HQPopoverAction *multichatAction = [HQPopoverAction actionWithImage:[UIImage imageNamed:@"right_menu_multichat"] title:@"AR3D" handler:^(HQPopoverAction *action) {
        ARTestViewController *arVC = [[ARTestViewController alloc] init];
        arVC.type = ARTest_Move_Type;
        [self.navigationController presentViewController:arVC animated:YES completion:nil];
    }];
    // AR2D action
    HQPopoverAction *addFriAction = [HQPopoverAction actionWithImage:[UIImage imageNamed:@"right_menu_addFri"] title:@"AR2D" handler:^(HQPopoverAction *action) {
        AR2DTestViewController *ar2dVC = [AR2DTestViewController new];
        [self.navigationController presentViewController:ar2dVC animated:YES completion:nil];
    }];
    // 扫一扫 action
    HQPopoverAction *QRAction = [HQPopoverAction actionWithImage:[UIImage imageNamed:@"right_menu_QR"] title:@"扫一扫" handler:^(HQPopoverAction *action) {
        HQQRCodeViewController *rCodeVC = [[HQQRCodeViewController alloc] init];
        [self.navigationController pushViewController:rCodeVC animated:YES];
    }];
    // 付款 action
    HQPopoverAction *payMoneyAction = [HQPopoverAction actionWithImage:[UIImage imageNamed:@"right_menu_payMoney"] title:@"收付款" handler:^(HQPopoverAction *action) {
    }];
    return @[multichatAction, addFriAction, QRAction, payMoneyAction];
}
- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0 ,0, App_Frame_Width, APP_Frame_Height-64- 49 ) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = YES;
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _tableView;
}
- (NSMutableArray *)dataArray{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return  _dataArray;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
