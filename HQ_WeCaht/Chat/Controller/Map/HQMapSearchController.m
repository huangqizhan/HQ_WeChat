//
//  HQMapSearchController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/11.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQMapSearchController.h"
#import "HQLocationMapController.h"



@interface HQMapSearchController ()<AMapSearchDelegate>{
    
    BOOL _isLoading;
    
}

@property (nonatomic,weak) HQLocationMapController *locationVC;
@property (nonatomic,strong) HQSearchBar *searchBar;
@property (nonatomic,strong) AMapPOIKeywordsSearchRequest *keyWordRequest;
@property (nonatomic) AMapSearchAPI *search;


@property (nonatomic,strong) UIView *topBegView;
@property (nonatomic,strong) UIView *navigationView;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *pointArray;


@end

@implementation HQMapSearchController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createTopBegView];
    [self createNaviGationView];
    [self createSearchBar];
    [self.view addSubview:self.tableView];
    
    [self configSearchRequest];
    
    
}
- (void)createTopBegView{
    _topBegView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, 128)];
    _topBegView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_topBegView];
}
- (void)createNaviGationView{
    _navigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, 64)];
    _navigationView.backgroundColor = XZColor(43, 45, 40);
    [_topBegView addSubview:_navigationView];
    UIButton *lefetButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 40, 40)];
    [lefetButton setTitle:@"取消" forState:UIControlStateNormal];
    lefetButton.titleLabel.font = [UIFont systemFontOfSize:15];
//    [lefetButton addTarget:self action:@selector(cancelEditing:) forControlEvents:UIControlEventTouchUpInside];
    [_navigationView addSubview:lefetButton];
    
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(App_Frame_Width-50, 20, 40, 40)];
    [rightButton setTitle:@"发送" forState:UIControlStateNormal];
    [rightButton setTitleColor:CANCELBUTTONCOLOR forState:UIControlStateNormal];
//    [rightButton addTarget:self action:@selector(sendLocatonMsgAction:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [_navigationView addSubview:rightButton];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((App_Frame_Width-50)/2.0, 20, 50, 40)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    NSString *title = @"位置";
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:16]}];
    titleLabel.attributedText = att;
    [_navigationView addSubview:titleLabel];
}
- (void)createSearchBar{
    _searchBar = [HQSearchBar defaultSearchBarWithIsActive:NO];
    _searchBar.delegate = self;
    _searchBar.placeholder = @"搜索地址";
    [_topBegView addSubview:_searchBar];
}
- (void)configSearchRequest{
    _keyWordRequest= [[AMapPOIKeywordsSearchRequest alloc] init];
    _keyWordRequest.types = allPOISearchTypes;
    _keyWordRequest.requireExtension = YES;
    _keyWordRequest.cityLimit = YES;
    _keyWordRequest.requireSubPOIs = YES;
    _keyWordRequest.requireSubPOIs = YES;
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;
}
- (void)showSearchVCWith:(HQLocationMapController *)locationVC andNavigationView:(UIView *)navigationView andSearchBar:(HQSearchBar *)searchBar{
    self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    self.modalPresentationCapturesStatusBarAppearance = YES;
    WEAKSELF;
    [locationVC presentViewController:self animated:NO completion:^{
        _topBegView.backgroundColor = searchBar.barTintColor;
        [weakSelf showMapSearchWithAnimation];
    }];
}
- (void)showMapSearchWithAnimation{
    [_searchBar setShowsCancelButton:YES animated:YES];
    [_searchBar becomeFirstResponder];
    [UIView animateWithDuration:0.25 animations:^{
        _topBegView.top -= 64;
        _searchBar.top +=20;
        _tableView.top = _topBegView.bottom;
    } completion:^(BOOL finished) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
}
- (void)dismissWithAnimation{
    [UIView animateWithDuration:0.25 animations:^{
        _topBegView.top = 0;
        _searchBar.top -=20;
        _tableView.top = _topBegView.bottom-20;
    } completion:^(BOOL finished) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}
- (void)searbarDidDisMiss{
    [_searchBar setShowsCancelButton:NO animated:NO];
    [self dismissKeyboard];
    _searchBar.placeholder = @"搜索地址";
    _searchBar.text = nil;
    [self dismissWithAnimation];
}
- (void)dismissKeyboard {
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
        UIButton *searchBtn = [self.searchBar searchCancelButton];
        searchBtn.enabled = YES;
    }
}
#pragma mark  ----------- AMapSearchDelegate -----
/**
 * @brief 当请求发生错误时，会调用代理的此方法.
 * @param request 发生错误的请求.
 * @param error   返回的错误.
 */
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error{
    NSLog(@"search didFailWithError = %@",error.domain);
    _isLoading = NO;
    [self.pointArray removeAllObjects];
    [self.tableView reloadData];
}

/**
 * @brief POI查询回调函数
 * @param request  发起的请求，具体字段参考 AMapPOISearchBaseRequest 及其子类。
 * @param response 响应结果，具体字段参考 AMapPOISearchResponse 。
 */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response{
    NSLog(@"AMapPOISearchResponse response = %@",response);
    _isLoading = NO;
    [self.pointArray removeAllObjects];
    [self.pointArray addObjectsFromArray:response.pois];
    [self.tableView reloadData];
}

////重新搜索
- (void)reSearchAddressWithKeyWords:(NSString *)keyWord{
    if (keyWord.length <= 0) {
        return;
    }
    _isLoading = YES;
    [self.pointArray removeAllObjects];
    [self.tableView reloadData];
    [_search cancelAllRequests];
    _keyWordRequest.page = 1;
    _keyWordRequest.keywords = keyWord;
    [_search AMapPOIKeywordsSearch:_keyWordRequest];
}
#pragma mark ------ UISearchBarDelegate -------
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    return YES;
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self searbarDidDisMiss];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self reSearchAddressWithKeyWords:searchBar.text];
}

#pragma mark ------- UITableViewDelegate ------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.pointArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (_isLoading) {
        return 30;
    }else{
        return CGFLOAT_MIN;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, 30)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, App_Frame_Width-30, 20)];
    label.textColor = [UIColor lightGrayColor];
    label.font = [UIFont systemFontOfSize:14];
    [headView addSubview:label];
    if (_isLoading == YES) {
        label.text = @"正在加载...";
        return headView;
    }else{
        return nil;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HQMapSearchVcCell *poiCell = [tableView dequeueReusableCellWithIdentifier:@"HQMapSearchVcCell"];
    poiCell.poi = self.pointArray[indexPath.row];
    return poiCell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_searchResultCallBack) {
        _searchResultCallBack(self.pointArray[indexPath.row]);
    }
    [self dismissWithAnimation];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self dismissKeyboard];
}
- (NSMutableArray *)pointArray{
    if (_pointArray == nil) {
        _pointArray = [NSMutableArray new];
    }
    return _pointArray;
}
- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _topBegView.bottom-20, App_Frame_Width, APP_Frame_Height-64) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[HQMapSearchVcCell class] forCellReuseIdentifier:@"HQMapSearchVcCell"];
    }
    return _tableView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end












@interface HQMapSearchVcCell ()

@property (nonatomic,strong) UILabel *contentLabel;

@end

@implementation HQMapSearchVcCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.contentLabel];
    }
    return self;
}

- (void)setPoi:(AMapPOI *)poi{
    _poi = poi;
    _contentLabel.text = _poi.name;
}

- (UILabel *)contentLabel{
    if (_contentLabel == nil) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, App_Frame_Width-30, 30)];
        _contentLabel.font = [UIFont systemFontOfSize:16];
    }
    return _contentLabel;
}


@end

