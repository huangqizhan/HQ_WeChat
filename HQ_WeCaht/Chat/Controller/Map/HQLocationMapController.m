//
//  HQLocationMapController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/5.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQLocationMapController.h"
#import "HQSearchBar.h"
#import "HQLocationMapSearchFirstCell.h"
#import "HQMapSearchController.h"

#import <MAMapKit/MAMapKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>




@interface HQLocationMapController ()<MAMapViewDelegate,AMapLocationManagerDelegate,AMapSearchDelegate>{
    
    BOOL _isLoading;                        ///上啦加载是否正在继续
    BOOL _isLoadMore;                       ///是否加载更多
    BOOL _willDismiss;                      ///控制器将要释放
    BOOL _isRefershByPOI;                   ///是否刷新当前的附近周边数据
    NSInteger _currentPage;                 ///附近POI加载的页数
    BOOL _isOriginalFramStatus;             ///地图跟tableView的相对位置是否是刚开始的状态
    UIImageView *_accessoryView;            ///选择access视图
    CLLocation *_currentUserLocation;       ///定位之后用户的位置信息
    CLLocation *_lastRegionCLLocation;      ////记录上一次滑动后的地图中心点    和下一次的滑动距离作比较  如果大于50  调用附近接口
    NSString *_currentUserLocationAddress;  ///当前搜索的地址
    NSIndexPath *_lastSeleteIndexPath;      ///上一次选择的cell索引
    HQLocationMapSearchFirstCellType _headCellType;             ///第一个cell的状态
    HQLocationMapSearchLoadingFotterView *_tableFotterView;     ///fotterView
    
}

@property (nonatomic)NSMutableArray *pointsArray;

@property (nonatomic) HQSearchBar *searchBar;
@property (nonatomic) MAMapView *mapView;
@property (nonatomic) AMapLocationManager *locationManger;
@property (nonatomic) UITableView *tableView;
@property (nonatomic) UIView *navigationView;
@property (nonatomic) UIButton *locationBtn;
@property (nonatomic) AMapReGeocode *curCenterReGeocode;
@property (nonatomic) AMapSearchAPI *search;
@property (nonatomic) AMapPOIAroundSearchRequest *request;
@property (nonatomic) AMapWeatherSearchRequest *weatherRequest;
@property (nonatomic) AMapReGeocodeSearchRequest *regeo;
@property (nonatomic) AMapPOI *userCurrentPOI;
@property (nonatomic) UIImageView *pinchView;


@end

@implementation HQLocationMapController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"位置";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelEditing:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(sendLocatonMsgAction:)];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName:CANCELBUTTONCOLOR} forState:UIControlStateNormal];
    [self setUpData];
    [self createNaviGationView];
    [self createSearchBar];
    [self createMapView];
    [self createTableView];
    
}
- (void)setUpData{
    if (_userCurrentPOI == nil) {
        _userCurrentPOI = [[AMapPOI alloc] init];
    }
    _currentPage = 1;
    _headCellType = HQLocationMapSearchFirstCellLoadingType;
    _lastSeleteIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
}
- (void)createSearchBar{
    _searchBar = [HQSearchBar defaultSearchBar];
    _searchBar.delegate = self;
    _searchBar.placeholder = @"搜索地址";
    [self.view addSubview:_searchBar];
}

- (void)createTableView{
    self.pointsArray = [NSMutableArray new];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _mapView.height+44+64 ,App_Frame_Width, APP_Frame_Height*0.45) style:UITableViewStylePlain];
    _tableView.backgroundColor = BackgroundColor_nearWhite;
    _tableView.separatorColor = BackgroundColor_lightGray;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 51;
    [_tableView registerClass:[HQLocationMapSearchFirstCell class] forCellReuseIdentifier:@"HQLocationMapSearchFirstCell"];
    [_tableView registerClass:[HQLocationMapSearchContentCell class] forCellReuseIdentifier:@"HQLocationMapSearchContentCell"];
    [self.view addSubview:_tableView];
    
    _tableFotterView = [[HQLocationMapSearchLoadingFotterView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, 50)];
    _accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AlbumCheckmark"]];

}
- (void)createMapView{
    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 64+44, App_Frame_Width, APP_Frame_Height-64-44 - APP_Frame_Height*0.45)];
    _mapView.delegate = self;
    _mapView.mapType = MAMapTypeStandard;
    
    _mapView.zoomEnabled = YES;
    _mapView.minZoomLevel = 4;
    _mapView.zoomLevel = 16;
    _mapView.maxZoomLevel = 20;
    _mapView.distanceFilter = 10;
    _mapView.desiredAccuracy = kCLLocationAccuracyBest;
    _mapView.userTrackingMode = MAUserTrackingModeFollow;

    
    _mapView.scrollEnabled = YES;
    _mapView.showsCompass = NO;
    _mapView.showsScale = YES;
    _mapView.showsUserLocation = YES;
    _mapView.scaleOrigin = CGPointMake(10, _mapView.height-30);
    _mapView.logoCenter = CGPointMake(App_Frame_Width-35, _mapView.height-10);
    [self.view addSubview:_mapView];
    
    _locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_locationBtn setBackgroundImage:[UIImage imageNamed:@"location_my"] forState:UIControlStateNormal];
    [_locationBtn setBackgroundImage:[UIImage imageNamed:@"location_my_HL"] forState:UIControlStateHighlighted];
    [self setLocationButtonStyle:YES];
    _locationBtn.frame = CGRectMake(App_Frame_Width - 8 - 50, _mapView.height-70+108, 50, 50);
    [_locationBtn addTarget:self action:@selector(backToUserLocation:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_locationBtn];
    
    _pinchView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"located_pin"]];
    _pinchView.frame = CGRectMake(0, 0, 18, 38);
    _pinchView.layer.anchorPoint = CGPointMake(0.5, 0.96);
    _pinchView.center = _mapView.center;
    [self.view addSubview:_pinchView];
    
    [self checkAuthorization];
}
- (void)backToUserLocation:(UIButton *)sender{
    _mapView.zoomLevel = 16;
    _isRefershByPOI = YES;
    [self setLocationButtonStyle:YES];
    [self.mapView setCenterCoordinate:_currentUserLocation.coordinate animated:YES];
}
- (void)setLocationButtonStyle:(BOOL)isLocationMe {
    NSString *backgroundImageString =  isLocationMe ? @"location_my_current": @"location_my";
    [_locationBtn setBackgroundImage:[UIImage imageNamed:backgroundImageString] forState:UIControlStateNormal];
}

- (void)createNaviGationView{
    _navigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, 64)];
    _navigationView.backgroundColor = XZColor(43, 45, 40);
    [self.view addSubview:_navigationView];
    UIButton *lefetButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 40, 40)];
    [lefetButton setTitle:@"取消" forState:UIControlStateNormal];
    lefetButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [lefetButton addTarget:self action:@selector(cancelEditing:) forControlEvents:UIControlEventTouchUpInside];
    [_navigationView addSubview:lefetButton];
    
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(App_Frame_Width-50, 20, 40, 40)];
    [rightButton setTitle:@"发送" forState:UIControlStateNormal];
    [rightButton setTitleColor:CANCELBUTTONCOLOR forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(sendLocatonMsgAction:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [_navigationView addSubview:rightButton];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((App_Frame_Width-50)/2.0, 20, 50, 40)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    NSString *title = @"位置";
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:16]}];
    titleLabel.attributedText = att;
    [_navigationView addSubview:titleLabel];
}

- (void)cancelEditing:(UIBarButtonItem *)sender{
    [self cancel:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)sendLocatonMsgAction:(UIBarButtonItem *)sender{
    MBProgressHUD *hud = [HQPopover showActivityIndicatiorHUDWithTitle:@"请稍后..." inView:self.view];
    CGFloat width = App_Frame_Width*3.0/5.0;
    CGFloat height = (APP_Frame_Height)/4.0;
    CGFloat rate = width/height;
    CGRect imageRect;
    if ((_mapView.width/_mapView.height) > rate) {
        imageRect = CGRectMake((_mapView.width-_mapView.height*rate)/2.0, 0, _mapView.height*rate, _mapView.height);
    }else{
        imageRect = CGRectMake(0, (_mapView.height-_mapView.width/rate)/2.0, _mapView.width, _mapView.width/rate);
    }
    [_mapView takeSnapshotInRect:imageRect withCompletionBlock:^(UIImage *resultImage, CGRect rect) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [HQPopover hideHUD:hud animated:YES];
            if (_searchResultCallBack && resultImage) {
                _searchResultCallBack(resultImage,_mapView.centerCoordinate,_currentUserLocationAddress);
            }
            [self cancelEditing:nil];
        });
    }];
}
- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)checkAuthorization {
    if (![CLLocationManager locationServicesEnabled]) {
        [self promptNoAuthorizationAlert];
    }else {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        switch (status) {
            case kCLAuthorizationStatusDenied:
            case kCLAuthorizationStatusRestricted:
                [self promptNoAuthorizationAlert];
                break;
            case kCLAuthorizationStatusAuthorizedAlways:
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                [self startUpdatingLocation];
                break;
            case kCLAuthorizationStatusNotDetermined:
                [self startUpdatingLocation];
                break;
        }
    }
    
}
- (void)endUpdatingLocation{
    self.mapView.userTrackingMode = MAUserTrackingModeNone;
    self.mapView.showsUserLocation = NO;
    self.mapView.delegate = nil;
    [self.locationManger stopUpdatingLocation];
}
- (void)willDismissSelf {
//    resultController = nil;
    _willDismiss = YES;
    [self endUpdatingLocation];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)cancel:(UIBarButtonItem *)item {
    if (_willDismiss)
        return;
    [self willDismissSelf];
    
//    [self.delegate didCancelLocationViewController:self];
}
- (void)startUpdatingLocation {
    _mapView.distanceFilter = 10;
    _mapView.desiredAccuracy = kCLLocationAccuracyBest;
    _mapView.userTrackingMode = MAUserTrackingModeFollow;
    
    _locationManger  = [[AMapLocationManager alloc] init];
    _locationManger.delegate = self;
    _locationManger.locatingWithReGeocode = YES;
    [_locationManger startUpdatingLocation];

    
    _request = [[AMapPOIAroundSearchRequest alloc] init];
    _request.types =(NSString *)allPOISearchTypes;
    _request.sortrule = 1;
    _request.requireExtension = YES;
    _request.requireSubPOIs = NO;
    _request.radius = 5000;
    _request.page = 1;
    _request.offset = 20;
    
    _weatherRequest = [[AMapWeatherSearchRequest alloc] init];
    
    _regeo = [[AMapReGeocodeSearchRequest alloc] init];
    _regeo.radius = 3000;
    _regeo.requireExtension = NO;
    
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
}
- (void)promptNoAuthorizationAlert{
    WEAK_SELF;
    [HQPopover showMessageAlertWithTitle:nil message:@"  无法获取你的位置信息。\n请到手机系统的[设置]->[隐私]->[定位服务]中打开定位服务,并允许微信使用定位服务。" actionTitle:@"确定" actionHandler:^{
        [weakSelf cancel:nil];
    }];
}
#pragma mark --------- UITableViewDelegate     &&  -----DataSourse --------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.pointsArray.count+1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        HQLocationMapSearchFirstCell *firstCell = [tableView dequeueReusableCellWithIdentifier:@"HQLocationMapSearchFirstCell"];
        firstCell.type = _headCellType;
        firstCell.currentSearchKye = _userCurrentPOI.address;
        firstCell.accessoryView = (indexPath == _lastSeleteIndexPath && self.pointsArray.count)? _accessoryView :nil;
        WEAKSELF;
        [firstCell setReloadButtonClick:^{
            [weakSelf reloadAroundPoiData];
        }];
        return firstCell;
    }else{
        HQLocationMapSearchContentCell *contentCell = [tableView dequeueReusableCellWithIdentifier:@"HQLocationMapSearchContentCell"];
        contentCell.poi = self.pointsArray[indexPath.row-1];
        contentCell.accessoryView = (indexPath == _lastSeleteIndexPath)? _accessoryView :nil;
        return contentCell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (_isLoading) {
        return;
    }
    if (indexPath.row == 0) {
        [self.mapView setCenterCoordinate:_currentUserLocation.coordinate animated:YES];
        _currentUserLocationAddress = _userCurrentPOI.address;
    }else{
        HQLocationMapSearchContentCell *locationCell = (HQLocationMapSearchContentCell *)cell;
        _currentUserLocationAddress = locationCell.poi.address;
        AMapGeoPoint *point = locationCell.poi.location;
        CLLocationCoordinate2D coordinate2D = CLLocationCoordinate2DMake(point.latitude, point.longitude);
        [self.mapView setCenterCoordinate:coordinate2D animated:YES];
    }
    if (_lastSeleteIndexPath) {
        UITableViewCell *lastSeleteCell = [tableView cellForRowAtIndexPath:_lastSeleteIndexPath];
        lastSeleteCell.accessoryView = nil;
    }
    cell.accessoryView = _accessoryView;
    _lastSeleteIndexPath = indexPath;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (!_isOriginalFramStatus && scrollView.contentOffset.y > 10) {
        [self changeFrameToBeBigger:YES];
    }else if (_isOriginalFramStatus && scrollView.contentOffset.y < -10) {
        [self changeFrameToBeBigger:NO];
    }
    if (scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height +10 && scrollView.contentSize.height >= scrollView.height) {
        if (!_isLoading) {
            [self loadMoreHandle];
        }
    }
}
////加载更多处理
- (void)loadMoreHandle{
    _currentPage += 1;
    _isLoadMore = YES;
    self.tableView.tableFooterView =  _tableFotterView;
    _isLoading = YES;
    [self fetchPOIAroundCenterCoordinate];
}
- (void)changeFrameToBeBigger:(BOOL)bigger {
    if (_isOriginalFramStatus == bigger)return;
    _isOriginalFramStatus = bigger;
    self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.25
                          delay:(bigger? 0 : 0.1)
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame= self.tableView.frame;
                         frame.size.height = floor(APP_Frame_Height *
                                                   (bigger ? 0.7 : 0.45));
                         frame.origin.y = APP_Frame_Height - frame.size.height;
                         self.tableView.frame = frame;
                         
                         frame = self.mapView.frame;
                         CGFloat barY = CGRectGetMaxY(self.searchBar.frame);
                         CGFloat height = APP_Frame_Height - CGRectGetHeight(self.tableView.frame) - barY;
                         CGFloat heightDelt = (CGRectGetHeight(frame) - height)/2;
                         frame.origin.y = barY;
                         frame.size.height = height;
                         self.mapView.frame = frame;
                         
                         frame = self.locationBtn.frame;
                         frame.origin.y = CGRectGetMinY(_tableView.frame) - 18 - 50;
                         self.locationBtn.frame = frame;
                         
                         _pinchView.center = _mapView.center;
                         
                         _mapView.logoCenter = CGPointMake(APP_Frame_Height - 3 - _mapView.logoSize.width/2, CGRectGetHeight(self.mapView.frame) - 3 - _mapView.logoSize.height/2 - heightDelt);
                         _mapView.scaleOrigin = CGPointMake(10, _mapView.height-30);
                     }
                     completion:^(BOOL finished) {
                         self.view.userInteractionEnabled = YES;
                     }];
    
}
#pragma mark --------- MAMapViewDelegate ----
/**
 * @brief 地图区域即将改变时会调用此接口
 * @param mapView 地图View
 * @param animated 是否动画
 */
- (void)mapView:(MAMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    NSLog(@"regionWillChangeAnimated");
}

/**
 * @brief 地图区域改变完成后会调用此接口
 * @param mapView 地图View
 * @param animated 是否动画
 */
- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    ///animated 为YES时 点击cell时触发和点击定位按钮  为NO时 是手动拖动
    CLLocationCoordinate2D coordinate2D = [self.mapView convertPoint:self.mapView.center toCoordinateFromView:self.mapView];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate2D.latitude longitude:coordinate2D.longitude];
    if (!_lastRegionCLLocation) {
        _lastRegionCLLocation  = self.mapView.userLocation.location;
    }
    CLLocationDistance distance = [_lastRegionCLLocation distanceFromLocation:location];
    if (distance > 50) {
        _lastRegionCLLocation = location;
        if (_isRefershByPOI  ||   !animated) {
            _isRefershByPOI = NO;
            [self reloadAroundPoiData];
        }
        [self setLocationButtonStyle:NO];
        CGFloat _y = self.pinchView.bottom;
        [UIView animateKeyframesWithDuration:0.75 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeCubicPaced | UIViewKeyframeAnimationOptionOverrideInheritedDuration | UIViewKeyframeAnimationOptionBeginFromCurrentState animations:^{
            [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.5 animations:^{
                self.pinchView.bottom = _y;
            }];
            [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
                self.pinchView.bottom = _y - 12;
            }];
            [UIView addKeyframeWithRelativeStartTime:1 relativeDuration:0 animations:^{
                self.pinchView.bottom = _y;
            }];
        } completion:nil];
    }
}
- (void)reloadAroundPoiData{
    _currentPage += 1;
    _isLoadMore = NO;
    self.tableView.tableFooterView =  nil;
    _isLoading = NO;
    _lastSeleteIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self changeFrameToBeBigger:NO];
    _headCellType = HQLocationMapSearchFirstCellLoadingType;
    [self.pointsArray removeAllObjects];
    [self.tableView reloadData];
    [self fetchPOIAroundCenterCoordinate];
}
//获取地图中心附近的POI
- (void)fetchPOIAroundCenterCoordinate {
    CLLocationCoordinate2D coordinate2D = self.mapView.centerCoordinate;
    AMapGeoPoint *point = [AMapGeoPoint locationWithLatitude:coordinate2D.latitude     longitude:coordinate2D.longitude];
    
    _request.location = point;
    _request.page = _currentPage;
    _regeo.location = point;
    [self.search cancelAllRequests];
    [self.search AMapReGoecodeSearch:_regeo];
    [self.search AMapPOIAroundSearch:_request];
}

#pragma mark --------- AMapLocationManagerDelegate ---------

- (void)amapLocationManager:(AMapLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"didFailWithError");
}
/**
 *  @brief 连续定位回调函数.注意：如果实现了本方法，则定位信息不会通过amapLocationManager:didUpdateLocation:方法回调。
 *  @param manager 定位 AMapLocationManager 类。
 *  @param location 定位结果。
 *  @param reGeocode 逆地理信息。
 */
- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)reGeocode{
    [_mapView setCenterCoordinate:location.coordinate animated:NO];
    _currentUserLocation = location;
    if (reGeocode.city) {
        _weatherRequest.city = reGeocode.city;
        [self.search AMapWeatherSearch:_weatherRequest];
    }
    if (location) {
        [manager stopUpdatingLocation];
    }
}

/**
 *  @brief 定位权限状态改变时回调函数
 *  @param manager 定位 AMapLocationManager 类。
 *  @param status 定位权限状态。
 */
- (void)amapLocationManager:(AMapLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    switch (status) {
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
            [self promptNoAuthorizationAlert];
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
//            [self startUpdatingLocation];
            break;
        case kCLAuthorizationStatusNotDetermined:
//            [self startUpdatingLocation];
            break;
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
    _currentPage -= 1;
    if (_currentPage <= 1) {
        _currentPage = 1;
    }
    if ([request isKindOfClass:[AMapPOIAroundSearchRequest class]]) {
        _headCellType = HQLocationMapSearchFirstCellFaildType;
        [self.tableView reloadData];
    }
}

/**
 * @brief POI查询回调函数
 * @param request  发起的请求，具体字段参考 AMapPOISearchBaseRequest 及其子类。
 * @param response 响应结果，具体字段参考 AMapPOISearchResponse 。
 */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response{
    NSLog(@"AMapPOISearchResponse response = %@",response);
    _isLoading = NO;
    _headCellType = HQLocationMapSearchFirstCellFinishedType;
    [self.pointsArray addObjectsFromArray:response.pois];
    [self.tableView reloadData];
}
/**
 * @brief 逆地理编码查询回调函数
 * @param request  发起的请求，具体字段参考 AMapReGeocodeSearchRequest 。
 * @param response 响应结果，具体字段参考 AMapReGeocodeSearchResponse 。
 */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response{
    NSLog(@"逆地理编码查询回调函数 %@",response);
    _currentUserLocationAddress = _userCurrentPOI.address = response.regeocode.formattedAddress;
    [self.tableView reloadData];
}
/**
 * @brief 天气查询回调
 * @param request  发起的请求，具体字段参考 AMapWeatherSearchRequest 。
 * @param response 响应结果，具体字段参考 AMapWeatherSearchResponse 。
 */
- (void)onWeatherSearchDone:(AMapWeatherSearchRequest *)request response:(AMapWeatherSearchResponse *)response{
    NSLog(@"天气查询回调 = %@",response);
}
#pragma mark   ---------- UISearchBarDelegate --------
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    HQMapSearchController *searchVC = [[HQMapSearchController alloc] init];
    [searchVC setSearchResultCallBack:^(AMapAOI *poi){
        _isRefershByPOI = YES;
        [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude) animated:YES];
    }];
    [searchVC showSearchVCWith:self andNavigationView:_navigationView andSearchBar:_searchBar];
    return NO;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
