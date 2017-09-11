//
//  HQContactViewController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/2/20.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQContactViewController.h"
#import "ContractModel+Action.h"
#import "HQContractSearchController.h"
#import "HQContractTableViewCell.h"
#import "HQContactDetailController.h"



@interface HQContactViewController (){
    
}

@property (nonatomic,strong) UISearchController *searchController;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) NSMutableArray *selectionArr;

@end

@implementation HQContactViewController

- (instancetype)init{
    self = [super init];
    if (self) {
        [self loadDataFromDB];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *butt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [butt addTarget:self action:@selector(rightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [butt setTitle:@"test" forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:butt];
    [self creatSubViews];
}
- (void)loadDataFromDB{
    [ContractModel searchUserModelOnAsyThread:^(NSArray *resultList,NSArray *locaArr) {
        [self.dataArray addObject:locaArr];
        NSDictionary *dic = [PublicCaculateManager groupContractWith:resultList];
        [self.selectionArr addObjectsFromArray:[dic.allKeys firstObject]];
        [self.dataArray addObjectsFromArray:[dic objectForKey:[dic.allKeys firstObject]]];
    }];
}


- (void)rightButtonAction:(UIButton *)sender{
    NSMutableArray *modelArray = [NSMutableArray new];
    ContractModel *model1 = [ContractModel customerInit];
    model1.userName = @"阿弥陀福";
    model1.userId = 11;
    model1.userType = @"user";
    model1.userHeadImaeUrl = @"http://d.lanrentuku.com/down/png/1610/16young-avatar-collection/boy.png";
    model1.isGroupChat = NO;
    [modelArray addObject:model1];
    
    ContractModel *model2 = [ContractModel customerInit];
    model2.userId = 12;
    model2.userType = @"user";
    model2.userName = @"白超";
    model2.userHeadImaeUrl = @"http://d.lanrentuku.com/down/png/1610/16young-avatar-collection/boy-3.png";
    model2.isGroupChat = NO;
    [modelArray addObject:model2];
    
    ContractModel *model3 = [ContractModel customerInit];
    model3.userName = @"常";
    model3.userId = 13;
    model3.userType = @"user";
    model3.userHeadImaeUrl = @"http://d.lanrentuku.com/down/png/1610/16young-avatar-collection/boy-1.png";
    model3.isGroupChat = NO;
    [modelArray addObject:model3];
    
    ContractModel *model4 = [ContractModel customerInit];
    model4.userName = @"低调";
    model4.userType = @"user";
    model4.userId = 14;
    model4.userHeadImaeUrl = @"http://d.lanrentuku.com/down/png/1610/16young-avatar-collection/man-1.png";
    model4.isGroupChat = NO;
    [modelArray addObject:model4];
    
    ContractModel *model5 = [ContractModel customerInit];
    model5.userName = @"二转";
    model5.userId = 15;
    model5.userType = @"user";
    model5.userHeadImaeUrl = @"http://d.lanrentuku.com/down/png/1610/16young-avatar-collection/girl-7.png";
    model5.isGroupChat = NO;
    [modelArray addObject:model5];
    
    ContractModel *model6 = [ContractModel customerInit];
    model6.userName = @"古钱";
    model6.userType = @"user";
    model6.userId = 16;
    model6.userHeadImaeUrl = @"http://d.lanrentuku.com/down/png/1610/16young-avatar-collection/girl-1.png";
    model6.isGroupChat = NO;
    [modelArray addObject:model6];
    
    ContractModel *model7 = [ContractModel customerInit];
    model7.userName = @"黄麒展";
    model7.userType = @"user";
    model7.userId = 17;
    model7.userHeadImaeUrl = @"http://d.lanrentuku.com/down/png/1610/16young-avatar-collection/boy-2.png";
    model7.isGroupChat = NO;
    [modelArray addObject:model7];
    
    ContractModel *model8 = [ContractModel customerInit];
    model8.userName = @"姐姐";
    model8.userType = @"user";
    model8.userId = 18;
    model8.userHeadImaeUrl = @"http://d.lanrentuku.com/down/png/1610/16young-avatar-collection/girl-7.png";
    model8.isGroupChat = NO;
    [modelArray addObject:model8];
    
    ContractModel *model9 = [ContractModel customerInit];
    model9.userName = @"卡号";
    model9.userId = 19;
    model9.userType = @"user";
    model9.userHeadImaeUrl = @"http://d.lanrentuku.com/down/png/1610/16young-avatar-collection/man.png";
    model9.isGroupChat = NO;
    [modelArray addObject:model9];
    
    ContractModel *model10 = [ContractModel customerInit];
    model10.userName = @"刘威";
    model10.userType = @"user";
    model10.userId = 20;
    model10.userHeadImaeUrl = @"http://d.lanrentuku.com/down/png/1610/16young-avatar-collection/man.png";
    model10.isGroupChat = NO;
    [modelArray addObject:model10];
    
    ContractModel *model11 = [ContractModel customerInit];
    model11.userName = @"娜娜";
    model11.userId = 21;
    model11.userType = @"user";
    model11.userHeadImaeUrl = @"http://d.lanrentuku.com/down/png/1610/16young-avatar-collection/girl-3.png";
    model11.isGroupChat = NO;
    [modelArray addObject:model11];
    
    ContractModel *model12 = [ContractModel customerInit];
    model12.userName = @"强哥";
    model12.userId = 22;
    model12.userType = @"user";
    model12.userHeadImaeUrl = @"http://d.lanrentuku.com/down/png/1610/16young-avatar-collection/boy-5.png";
    model12.isGroupChat = NO;
    [modelArray addObject:model12];
    
    ContractModel *model13 = [ContractModel customerInit];
    model13.userName = @"搜索";
    model13.userId = 23;
    model13.userType = @"user";
    model13.userHeadImaeUrl = @"http://d.lanrentuku.com/down/png/1610/16young-avatar-collection/boy-4.png";
    model13.isGroupChat = NO;
    [modelArray addObject:model13];
    
    ContractModel *model14 = [ContractModel customerInit];
    model14.userName = @"兔子";
    model14.userId = 24;
    model14.userType = @"user";
    model14.userHeadImaeUrl = @"http://d.lanrentuku.com/down/png/1610/16young-avatar-collection/girl-4.png";
    model14.isGroupChat = NO;
    [modelArray addObject:model14];
    
    ContractModel *model15 = [ContractModel customerInit];
    model15.userName = @"组织";
    model15.userId = 25;
    model15.userType = @"user";
    model15.userHeadImaeUrl = @"http://d.lanrentuku.com/down/png/1610/16young-avatar-collection/girl-5.png";
    model15.isGroupChat = NO;
    [modelArray addObject:model15];
    
    ContractModel *newFriend = [ContractModel customerInit];
    newFriend.userName = @"新朋友";
    newFriend.userType = @"newUser";
    newFriend.createTime = 1;
    newFriend.userHeadImaeUrl = @"plugins_FriendNotify";
    
    ContractModel *group = [ContractModel customerInit];
    group.userName = @"群聊";
    group.userType = @"groupUser";
    group.createTime = 2;
    group.userHeadImaeUrl = @"add_friend_icon_addgroup";
    
    ContractModel *tag = [ContractModel customerInit];
    tag.userName = @"标签";
    tag.userType = @"tagUser";
    tag.createTime = 3;
    tag.userHeadImaeUrl = @"Contact_icon_ContactTag";
    
    ContractModel *publicNUm = [ContractModel customerInit];
    publicNUm.userName = @"公众号";
    publicNUm.userType = @"publicUser";
    publicNUm.createTime = 4;
    publicNUm.userHeadImaeUrl = @"add_friend_icon_offical";

    for (ContractModel *model in modelArray) {
        [model saveToDBUserModelAsyThread:^{
            NSLog(@"save success");
        } andError:^{
            NSLog(@"save faid");
        }];
    }
    
}
- (void)creatSubViews{
    
    HQContractSearchController *searchVC = [[HQContractSearchController alloc] init];
    UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController:searchVC];
    [searchController.searchBar sizeToFit];
    searchController.searchResultsUpdater = self;
    [searchController.searchBar setImage:[UIImage imageNamed:@"VoiceSearchStartBtn"] forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateNormal];

    self.tableView.tableHeaderView = searchController.searchBar;
    _searchController = searchController;
    _searchController.delegate = self;
    searchController.searchBar.showsBookmarkButton = YES;
    searchController.searchBar.tintColor = CANCELBUTTONCOLOR;
    [searchController.searchBar setBarTintColor:BACKGROUNDCOLOR];
    [searchController.searchBar.layer setBorderWidth:0.5f];
    [searchController.searchBar.layer setBorderColor:BACKGROUNDCOLOR.CGColor];
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:CANCELBUTTONCOLOR,NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    self.tableView.sectionHeaderHeight = 25;
    searchController.dimsBackgroundDuringPresentation = YES;
    self.definesPresentationContext = YES;
    searchController.view.backgroundColor = [UIColor whiteColor];
    searchController.hidesNavigationBarDuringPresentation = YES;
    self.tableView.frame  = CGRectMake(0,0, self.view.width, APP_Frame_Height-64-49);
}
- (void)willPresentSearchController:(UISearchController *)searchController{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [searchController.searchBar setShowsCancelButton:YES animated:YES];
}
- (void)willDismissSearchController:(UISearchController *)searchController{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}
#pragma mark ------- UISearchResultsUpdating ------
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    NSLog(@"searchController = %@",searchController.searchBar.text);
}
#pragma mark -------- UITableViewDelegate   &&  UITableViewDataSourse ------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataArray[section] count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return CGFLOAT_MIN;
    }
    return 20;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HQContractTableViewCell *contractCell = [tableView dequeueReusableCellWithIdentifier:@"HQContractTableViewCellId"];
    ContractModel *model = self.dataArray[indexPath.section][indexPath.row];
    contractCell.contractModel = model;
    return contractCell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return nil;
    }else{
        return _selectionArr[section];
    }
}
- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return _selectionArr;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section != 0) {
        HQContactDetailController *detailvc = [[HQContactDetailController alloc] init];
        detailvc.contactModel = self.dataArray[indexPath.section][indexPath.row];
        [self.navigationController pushViewController:detailvc animated:YES];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark ------- setter and getter --------
- (UITableView *)tableView{
    if (nil == _tableView) {
        UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.sectionIndexColor = [UIColor blackColor];
        tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        [self.view addSubview:tableView];
        _tableView = tableView;
        [_tableView registerClass:[HQContractTableViewCell class] forCellReuseIdentifier:@"HQContractTableViewCellId"];
    }
    return _tableView;
}
- (NSMutableArray *)dataArray{
    if (nil == _dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return  _dataArray;
}
- (NSMutableArray *)selectionArr{
    if (_selectionArr == nil) {
        _selectionArr = [[NSMutableArray alloc] init];
        [_selectionArr addObject:UITableViewIndexSearch];
    }
    return _selectionArr;
}
- (void)messageHandleWith:(ChatMessageModel *)messageModel{
    NSLog(@"contact contentString = %@",messageModel.contentString);
}
@end
