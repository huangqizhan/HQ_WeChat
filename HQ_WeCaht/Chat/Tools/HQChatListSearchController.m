//
//  HQSearchResultController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/1.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQChatListSearchController.h"
#import "HQChatListSecondSearchController.h"
#import "HQSearchResultContentCell.h"
#import "HQChatViewController.h"


@interface HQChatListSearchController (){
    BOOL _searchBarIsShow;
    UISearchBar *_fromSearchBar;
    UIStatusBarStyle _originStatusBarStyle;
    CGRect _fromSearchBarFrame;
    UIStatusBarStyle _targetStatusBarStyle;
    UIView *_searchResultView;
    CGFloat _searchBarMinWidth;
    CGSize _searchBarLeftViewSize;
    UIColor *_searchBarBackgroundColor;
    UIColor *_searchBarTintColor;
    UIView *_blockView;
    ChatListSearchControllerTableViewShowType _showType;
}

@property (nonatomic) HQSearchBar *searchBar;
@property (nonatomic) UIView *toNavigationBarView;
//@property (nonatomic) UIView *searchBackgroundView;
@property (nonatomic) UIVisualEffectView *begEffectView;
@property (nonatomic) UIView *fromNavigationBarView;
@property (nonatomic) UITableView *tableView;
@property (nonatomic,weak) HQBaseViewController *originController;
@property (nonatomic) UIViewController *subSearchController;
@property (nonatomic) UIButton *backButton;
@property (nonatomic) NSMutableArray *searchResultArray;

@end

@implementation HQChatListSearchController

- (instancetype)init{
    self = [super init];
    if (self) {
        [self commonInit];
        _showType = ChatListSearchControllerShowOriginalStatus;
        _searchResultArray = [NSMutableArray new];
    }
    return self;
}
- (void)commonInit {
    self.view.backgroundColor = [UIColor clearColor];
//    _searchBackgroundView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    _searchBackgroundView.backgroundColor = BACKGROUNDCOLOR;
//    _searchBackgroundView.alpha = 0.3;
//    [self.view addSubview:_searchBackgroundView]; begEffectView
//    UIImageView *begImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"IMG_0373" ofType:@".jpg"];
//    begImageView.image = [UIImage imageWithContentsOfFile:path];
//    [self.view addSubview:begImageView];
    
    _begEffectView = [[UIVisualEffectView alloc] initWithEffect: [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    _begEffectView.frame = [UIScreen mainScreen].bounds;
//    _begEffectView.backgroundColor = BACKGROUNDCOLOR;
//    _begEffectView.alpha = 0.3;
    [self.view addSubview:_begEffectView];
    
    self.toNavigationBarView = [[UIView alloc] init];
    [self.view addSubview:self.toNavigationBarView];
    
    self.searchBar = [HQSearchBar defaultSearchBarWithIsActive:YES];
    self.searchBar.delegate = self;
    [self.toNavigationBarView addSubview:self.searchBar];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    UIScreenEdgePanGestureRecognizer *pan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(screenEdgePanHandler:)];
    pan.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:pan];
    
}
- (void)screenEdgePanHandler:(UIPanGestureRecognizer *)pan {
    if (!self.subSearchController)
        return;
    
    CGFloat x = [pan translationInView:self.view.window].x;
    CGFloat progress = x / App_Frame_Width;
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            [self dismissKeyboard];
            [self.view.window addSubview:_blockView];
            [self setBackTransitionProgress:0 duration:0];
            break;
        case UIGestureRecognizerStateChanged:
            [self setBackTransitionProgress:progress duration:0];
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            [self backTransitionEnded:[pan velocityInView:self.view.window]];
            break;
        default:
            break;
    }
    
}

#pragma mark --------- 搜索选中的主题  -------
- (void)searchDidSeletedTitle:(NSString *)title{
    [self addChildSubControllerWithAnimationWithTitle:title];
}
- (void)addChildSubControllerWithAnimationWithTitle:(NSString *)title{
    HQChatListSecondSearchController *secondVC = [[HQChatListSecondSearchController alloc] init];
    secondVC.view.frame = CGRectMake(App_Frame_Width,64 , App_Frame_Width, APP_Frame_Height-64);
    self.subSearchController = secondVC;
    
    self.backButton.hidden = NO;
    self.backButton.right = 0;
    
    [self addChildViewController:secondVC];
    [self.view addSubview:secondVC.view];
    NSString *searchTitle,*searchImage;
    if ([title isEqualToString:@"文章"]) {
        searchTitle = @"搜索文章";
        searchImage = @"fts_searchicon_article";
    }else if ([title isEqualToString:@"朋友圈"]){
        searchTitle = @"搜索朋友圈";
        searchImage = @"fts_searchicon_sns";
    }else{
        searchTitle = @"搜索公众号";
        searchImage = @"fts_searchicon_brandcontact";
    }
    self.searchBar.placeholder = searchTitle;
    [self.searchBar setImage:[UIImage imageNamed:searchImage] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionLayoutSubviews|UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backButton.left = 0;
        CGRect frame = _searchBar.frame;
        frame.origin.x = CGRectGetMaxX(self.backButton.frame) - 6;
        frame.size.width = App_Frame_Width - frame.origin.x;
        _searchBarMinWidth = frame.size.width;
        _searchBar.frame = frame;
        self.subSearchController.view.frame = CGRectMake(0, 64, App_Frame_Width, APP_Frame_Height - 64);
    } completion:^(BOOL finished) {
    }];
}
- (void)removeSubControllerWithAnimation{
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionLayoutSubviews|UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backButton.right = 0;
        CGRect frame = _searchBar.frame;
        frame.origin.x = 0;
        frame.size.width = App_Frame_Width;
        _searchBar.frame = frame;
        self.subSearchController.view.frame = CGRectMake(App_Frame_Width, 64, App_Frame_Width, APP_Frame_Height - 64);
    } completion:^(BOOL finished) {
        [self backTransitionComplete];
    }];
}
- (void)backTransitionEnded:(CGPoint)velocity {
    CGFloat _x = self.subSearchController.view.frame.origin.x;
    CGFloat _t;
    CGFloat progress;
    CGFloat factor = 1.1;
    if (fabs(velocity.x) < App_Frame_Width * 2) {
        progress = (2 * _x >= App_Frame_Width) ? 1 : 0;
        _t = 0.25;
    }else if (velocity.x < 0) {
        progress = 0;
        _t = fabs(_x / velocity.x) * factor;
    }else {
        progress = 1;
        _t = (App_Frame_Width - _x) / velocity.x * factor;
    }
    
    if (_t > 0.25)
        _t = 0.25;
    else if (_t < 0.1)
        _t = 0.1;
    [self setBackTransitionProgress:progress duration:_t];
}
- (void)setBackTransitionProgress:(CGFloat)progress duration:(CGFloat)duration {
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionLayoutSubviews |
     UIViewAnimationCurveEaseInOut animations:^{
         CGRect frame = self.subSearchController.view.frame;
         frame.origin.x = progress * App_Frame_Width;
         self.subSearchController.view.frame = frame;
         
         frame = self.searchBar.frame;
         frame.size.width = _searchBarMinWidth + (App_Frame_Width - _searchBarMinWidth) *progress;
         frame.origin.x = App_Frame_Width - frame.size.width;
         self.searchBar.frame = frame;
         
         self.backButton.alpha = 1 - progress;
     } completion:^(BOOL finished) {
         if (progress == 1) {
             [self backTransitionComplete];
         }
         if (duration > 0 && (progress == 0 || progress == 1)){
         }
     }];
}
- (void)backHandler:(UIButton *)sender{
    [self removeSubControllerWithAnimation];
}
- (void)backTransitionComplete {
    self.backButton.alpha = 1;
    self.backButton.hidden = YES;
    [self.subSearchController.view removeFromSuperview];
    [self.subSearchController removeFromParentViewController];
    self.subSearchController = nil;
    [_searchBar setImage:nil forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
//    _searchBar.placeholder = @"搜索";
}

- (void)showInViewController:(HQBaseViewController *)controller fromSearchBar:(HQSearchBar *)SearchBar{
    _originController = controller;
    _fromSearchBar = SearchBar;
    _originStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    _fromSearchBarFrame = [_fromSearchBar convertRect:_fromSearchBar.bounds toView:[UIApplication sharedApplication].delegate.window];
    self.toNavigationBarView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, CGRectGetMaxY(_fromSearchBarFrame));
    self.toNavigationBarView.backgroundColor = _fromSearchBar.barTintColor;
    CGRect frame = _fromSearchBar.frame;
    frame.origin.x = 0;
    frame.origin.y = CGRectGetHeight(self.toNavigationBarView.frame) - CGRectGetHeight(_fromSearchBar.frame);
    self.searchBar.frame = frame;
    self.searchBar.placeholder = _fromSearchBar.placeholder;
    
    self.fromNavigationBarView = [controller.navigationController.navigationBar resizableSnapshotViewFromRect:CGRectMake(0, -20, [UIScreen mainScreen].bounds.size.width, 64) afterScreenUpdates:NO withCapInsets:UIEdgeInsetsZero];
    [self.view addSubview:self.fromNavigationBarView];
    
    _targetStatusBarStyle = controller.preferredStatusBarStyle;
    
    
    UIViewController *targetController = self.navigationController ? self.navigationController : self;
    targetController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    targetController.modalPresentationCapturesStatusBarAppearance = YES;
    WEAKSELF;
    [controller.navigationController presentViewController:targetController animated:NO completion:^{
        [weakSelf showWithAniamtionWith:controller];;
    }];
}
- (void)showWithAniamtionWith:(HQBaseViewController *)controller{
    [self.searchBar becomeFirstResponder];
    [self.searchBar setShowsCancelButton:YES animated:YES];
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut |
     UIViewAnimationOptionLayoutSubviews
                     animations:^{
                             [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
                         CGRect frame = self.fromNavigationBarView.frame;
                         frame.origin.y = -frame.size.height;
                         self.fromNavigationBarView.frame = frame;
                         _targetStatusBarStyle = UIStatusBarStyleDefault;
                         [self setNeedsStatusBarAppearanceUpdate];
                     }
                     completion:^(BOOL finished) {
                     }];
    [UIView animateWithDuration:0.25 delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [controller refershCurrnetListViewIsAppear:NO];
                         CGRect frame = self.toNavigationBarView.frame;
                         frame.origin.y = -frame.size.height + 64;
                         self.toNavigationBarView.frame = frame;
                         frame = _searchBar.frame;
                         frame.size.width = [UIScreen mainScreen].bounds.size.width;
                         _searchBar.frame = frame;
//                         self.searchBackgroundView.alpha = 0.98;
//                         self.begEffectView.alpha = 0.98;
                     }completion:^(BOOL finished) {
                         [self.view addSubview:self.tableView];
                         [self.toNavigationBarView insertSubview:self.backButton belowSubview:self.searchBar];
                         self.backButton.hidden = YES;
                     }];
}
- (void)dismissWithAniamtion{
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.tableView removeFromSuperview];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut| UIViewAnimationOptionLayoutSubviews animations:^{
        [_originController refershCurrnetListViewIsAppear:YES];
        CGRect frame = self.fromNavigationBarView.frame;
        frame.origin.y = 0;
        self.fromNavigationBarView.frame = frame;
        frame = self.toNavigationBarView.frame;
        frame.origin.y = 0;
        self.toNavigationBarView.frame = frame;
        frame = _searchBar.frame;
        frame.size.width = CGRectGetWidth(_fromSearchBarFrame);
        _searchBar.frame = frame;
        if (self.subSearchController) {
            self.subSearchController.view.top = self.toNavigationBarView.bottom;
        }
//        self.searchBackgroundView.alpha = 0;
//        self.begEffectView.alpha = 0;
        [_searchBar setPositionAdjustment:UIOffsetMake(_searchBar.endEdiateWidth/2.0+18, 0) forSearchBarIcon:UISearchBarIconSearch];
        _targetStatusBarStyle = UIStatusBarStyleLightContent;
        [self setNeedsStatusBarAppearanceUpdate];
    } completion:^(BOOL finished) {
        [self.navigationController ? self.navigationController : self dismissViewControllerAnimated:NO completion:^(){
            [self.navigationController setNavigationBarHidden:NO animated:YES];
            [self.fromNavigationBarView removeFromSuperview];
        }];
    }];
}
- (void)searbarDidDisMiss{
    [_searchBar setShowsCancelButton:NO animated:NO];
    _searchBar.width = App_Frame_Width;
    _searchBar.left = 0;
    [self dismissKeyboard];
//    _searchBar.placeholder = @"搜索";
    _searchBar.text = nil;
    [_searchBar setImage:nil forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    if (self.subSearchController) {
        [self.subSearchController removeFromParentViewController];
        [self.subSearchController.view removeFromSuperview];
    }
    [self dismissWithAniamtion];
}
- (void)dismissKeyboard {
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
        UIButton *searchBtn = [self.searchBar searchCancelButton];
        searchBtn.enabled = YES;
    }
}
- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, App_Frame_Width, APP_Frame_Height-64) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView registerClass:[HQSearchResultContentCell class] forCellReuseIdentifier:@"HQSearchResultContentCell"];
        [_tableView registerClass:[HQSearchResultRecentlyContactCell class] forCellReuseIdentifier:@"HQSearchResultRecentlyContactCell"];
        [_tableView registerClass:[HQSearchResultChatMessageCell class] forCellReuseIdentifier:@"HQSearchResultChatMessageCell"];
    }
    return _tableView;
}
- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"barbuttonicon_back"];
        [_backButton setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _backButton.tintColor = [UIColor lightGrayColor];
        [_backButton sizeToFit];
        _backButton.frame = CGRectMake(0, 72, 12 * 2, 13 * 2);
        [_backButton addTarget:self action:@selector(backHandler:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark --------- UITableViewDelegate  UITableViewDataSourse -----
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (_showType == ChatListSearchControllerShowOriginalStatus) {
        tableView.separatorColor = [UIColor clearColor];
        return 1;
    }else{
        tableView.separatorColor = [UIColor lightGrayColor];
        return _searchResultArray.count;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_showType == ChatListSearchControllerShowOriginalStatus) {
        return 1;
    }else{
        return [_searchResultArray[section] count];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (_showType == ChatListSearchControllerShowOriginalStatus) {
        return CGFLOAT_MIN;
    }else{
        return [_searchResultArray[section] count] ? 30 : CGFLOAT_MIN;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_showType == ChatListSearchControllerShowOriginalStatus) {
        return APP_Frame_Height-64;
    }else{
        return 60;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (_showType == ChatListSearchControllerShowOriginalStatus) {
        return nil;
    }else{
        if ([_searchResultArray[section] count]) {
            UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, 30)];
            headerView.backgroundColor = [UIColor whiteColor];
            UILabel *contetLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, App_Frame_Width-30, 20)];
            contetLabel.font = [UIFont systemFontOfSize:15*SCREENSCALE];
            contetLabel.textColor = [UIColor lightGrayColor];
            [headerView addSubview:contetLabel];
            if (section == 0) {
                contetLabel.text = [NSString stringWithFormat:@"常用联系人 %ld",[_searchResultArray[section] count]];
                return headerView;
            }else{
                contetLabel.text = [NSString stringWithFormat:@"聊天消息 %ld",[_searchResultArray[section] count]];
                return headerView;
            }
        }
        return nil;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_showType == ChatListSearchControllerShowOriginalStatus) {
        HQSearchResultContentCell *contentCell = [tableView dequeueReusableCellWithIdentifier:@"HQSearchResultContentCell"];
        WEAKSELF;
        [contentCell setButtonItemDidClick:^(NSString *title){
            [weakSelf searchDidSeletedTitle:title];
        }];
        return contentCell;
    }else{
        if (indexPath.section == 0) {
            HQSearchResultRecentlyContactCell *recentCell = [tableView dequeueReusableCellWithIdentifier:@"HQSearchResultRecentlyContactCell"];
            recentCell.listModel = _searchResultArray[indexPath.section][indexPath.row];
            return recentCell;
        }else{
            HQSearchResultChatMessageCell *messageCell = [tableView dequeueReusableCellWithIdentifier:@"HQSearchResultChatMessageCell"];
            messageCell.messageModel = _searchResultArray[indexPath.section][indexPath.row];
            return messageCell;
        }
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_showType == ChatListSearchControllerShowOriginalStatus) {
        [self dismissKeyboard];
    }else{
        [self dismissKeyboard];
        if (indexPath.section == 0) {
            HQChatViewController *chatVC = [[HQChatViewController alloc] init];
            chatVC.listModel = _searchResultArray[indexPath.section][indexPath.row];
            [chatVC setReloadChatListFromDBCallBack:^{
               if (_refershChatListMessage)
                   _refershChatListMessage();
            }];
            [self.navigationController pushViewController:chatVC animated:YES];
        }else{
            
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self dismissKeyboard];
}
#pragma mark --------- UISearchBarDelegate -----
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchBar.text.length <= 0) {
        _showType = ChatListSearchControllerShowOriginalStatus;
        [self.tableView reloadData];
    }
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self searchFromLoadDBWithSearchKey:searchBar.text];
}
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    if (@available(iOS 11.0, *)) {
        [searchBar setPositionAdjustment:UIOffsetMake(0, 0) forSearchBarIcon:UISearchBarIconSearch];
    }
    return YES;
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self searbarDidDisMiss];
}
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{

    return YES;
}
- (void)searchFromLoadDBWithSearchKey:(NSString *)searchKey{
    if (searchKey.length <= 0) {
        return;
    }
    [ChatListModel fuzzySearchWithSearchKey:searchKey andComplite:^(NSArray *result ,NSArray *messages) {
        _showType = ChatListSearchControllerShowSearchResultStatus;
        [_searchResultArray removeAllObjects];
        [_searchResultArray addObject:result];
        [_searchResultArray addObject:messages];
        [self.tableView reloadData];
    }];
}
@end






