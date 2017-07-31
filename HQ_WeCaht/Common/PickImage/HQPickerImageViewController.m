//
//  HQPickerImageViewController.m
//  HQPickerImage
//
//  Created by GoodSrc on 2017/3/14.
//  Copyright © 2017年 GoodSrc. All rights reserved.
//

#import "HQPickerImageViewController.h"
#import "HQPhotoPickerViewController.h"
#import "HQPickerPreviewController.h"
#import "HQAssetModel.h"
#import "HQAssetCell.h"





@interface HQPickerImageViewController (){
    NSTimer *_timer;
    UILabel *_tipLabel;
    UIButton *_settingBtn;
    BOOL _pushPhotoPickerVc;
    BOOL _didPushPhotoPickerVc;
    
    UIButton *_progressHUD;
    UIView *_HUDContainer;
    UIActivityIndicatorView *_HUDIndicatorView;
    UILabel *_HUDLabel;
    
    UIStatusBarStyle _originStatusBarStyle;
    
}

@end

@implementation HQPickerImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //    self.view.backgroundColor = [UIColor whiteColor];
    //    self.navigationBar.barStyle = UIBarStyleBlack;
    //    self.navigationBar.translucent = YES;
    
     [HQImageManager manager].shouldFixOrientation = NO;
    self.oKButtonTitleColorNormal   = [UIColor colorWithRed:(83/255.0) green:(179/255.0) blue:(17/255.0) alpha:1.0];
    self.oKButtonTitleColorDisabled = [UIColor colorWithRed:(83/255.0) green:(179/255.0) blue:(17/255.0) alpha:0.5];
    
    if (iOS7Later) {
        self.navigationBar.barTintColor = [UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:1.0];
        self.navigationBar.tintColor = [UIColor whiteColor];
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
//    self.naviBgColor = [UIColor redColor];
//    self.naviTitleColor = [UIColor yellowColor];
//    self.naviTitleFont = [UIFont systemFontOfSize:20];
//    self.barItemTextFont = [UIFont systemFontOfSize:22];
}

- (void)setNaviBgColor:(UIColor *)naviBgColor {
    _naviBgColor = naviBgColor;
    self.navigationBar.barTintColor = naviBgColor;
}

- (void)setNaviTitleColor:(UIColor *)naviTitleColor {
    _naviTitleColor = naviTitleColor;
    [self configNaviTitleAppearance];
}

- (void)setNaviTitleFont:(UIFont *)naviTitleFont {
    _naviTitleFont = naviTitleFont;
    [self configNaviTitleAppearance];
}

- (void)configNaviTitleAppearance {
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = self.naviTitleColor;
    textAttrs[NSFontAttributeName] = self.naviTitleFont;
    self.navigationBar.titleTextAttributes = textAttrs;
}
- (void)setBarItemTextFont:(UIFont *)barItemTextFont {
    _barItemTextFont = barItemTextFont;
    [self configBarButtonItemAppearance];
}

- (void)setBarItemTextColor:(UIColor *)barItemTextColor {
    _barItemTextColor = barItemTextColor;
    [self configBarButtonItemAppearance];
}

- (void)configBarButtonItemAppearance {
    UIBarButtonItem *barItem;
    if (iOS9Later) {
        barItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[HQPickerImageViewController class]]];
    } else {
        barItem = [UIBarButtonItem appearanceWhenContainedIn:[HQPickerImageViewController class], nil];
    }
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = self.barItemTextColor;
    textAttrs[NSFontAttributeName] = self.barItemTextFont;
    [barItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _originStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = _originStatusBarStyle;
//    [self hideProgressHUD];
}
- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount delegate:(id<HQPickerImageViewControllerDelegate>)delegate {
    return [self initWithMaxImagesCount:maxImagesCount columnNumber:4 delegate:delegate pushPhotoPickerVc:YES];
}

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount columnNumber:(NSInteger)columnNumber delegate:(id<HQPickerImageViewControllerDelegate>)delegate {
    return [self initWithMaxImagesCount:maxImagesCount columnNumber:columnNumber delegate:delegate pushPhotoPickerVc:YES];
}

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount columnNumber:(NSInteger)columnNumber delegate:(id<HQPickerImageViewControllerDelegate>)delegate pushPhotoPickerVc:(BOOL)pushPhotoPickerVc{
    _pushPhotoPickerVc = pushPhotoPickerVc;
    HQAlbumPickerController *albumPickerVc = [[HQAlbumPickerController alloc] init];
    albumPickerVc.columnNumber = columnNumber;
    self = [super initWithRootViewController:albumPickerVc];
    if (self) {
        self.maxImagesCount = maxImagesCount > 0 ? maxImagesCount : 9;
        self.pickerDelegate = delegate;
        self.selectedModels = [NSMutableArray array];
        // 默认准许用户选择原图和视频, 你也可以在这个方法后置为NO
        self.allowPickingOriginalPhoto = YES;
        self.allowPickingVideo = YES;
        self.allowPickingImage = YES;
        self.allowTakePicture = YES;
        self.sortAscendingByModificationDate = YES;
        self.autoDismiss = YES;
        self.columnNumber = columnNumber;
        [self configDefaultSetting];
        if (![HQImageManager manager].authorizationStatusAuthorized) {
            _tipLabel = [[UILabel alloc] init];
            _tipLabel.frame = CGRectMake(8, 120, self.view.tz_width - 16, 60);
            _tipLabel.textAlignment = NSTextAlignmentCenter;
            _tipLabel.numberOfLines = 0;
            _tipLabel.font = [UIFont systemFontOfSize:16];
            _tipLabel.textColor = [UIColor blackColor];
            NSString *appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleDisplayName"];
            if (!appName) appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleName"];
            NSString *tipText = @"您可以去设置界面进行设置";
            _tipLabel.text = tipText;
            [self.view addSubview:_tipLabel];
            
            _settingBtn = [UIButton buttonWithType:UIButtonTypeSystem];
            [_settingBtn setTitle:@"前往设置" forState:UIControlStateNormal];
            _settingBtn.frame = CGRectMake(0, 180, self.view.tz_width, 44);
            _settingBtn.titleLabel.font = [UIFont systemFontOfSize:18];
            [_settingBtn addTarget:self action:@selector(settingBtnClick) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:_settingBtn];
            
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(observeAuthrizationStatusChange) userInfo:nil repeats:YES];
        }else{
             [self pushPhotoPickerVc];
        }
    }
    return self;
}
/// This init method just for previewing photos / 用这个初始化方法以预览图片
- (instancetype)initWithSelectedAssets:(NSMutableArray *)selectedAssets selectedPhotos:(NSMutableArray *)selectedPhotos index:(NSInteger)index{
    HQPickerPreviewController *preViewVC = [[HQPickerPreviewController alloc] init];
    self =  [super initWithRootViewController:preViewVC];
    if (self) {
        [self configDefaultSetting];
    }
    return self;
}
/// This init method for crop photo / 用这个初始化方法以裁剪图片
- (instancetype)initCropTypeWithAsset:(id)asset photo:(UIImage *)photo completion:(void (^)(UIImage *cropImage,id asset))completion{
    HQPickerPreviewController *preViewVC = [[HQPickerPreviewController alloc] init];
    self = [super initWithRootViewController:preViewVC];
    if (self) {
        [self configDefaultSetting];
    }
    return self;
}
- (void)configDefaultSetting {
    self.timeout = 15;
    self.photoWidth = 828.0;
    self.photoPreviewMaxWidth = 600;
    self.naviTitleColor = [UIColor whiteColor];
    self.naviTitleFont = [UIFont systemFontOfSize:17];
    self.barItemTextFont = [UIFont systemFontOfSize:15];
    self.barItemTextColor = [UIColor whiteColor];
    self.allowPreview = YES;
    
    [self configDefaultImageName];
    [self configDefaultBtnTitle];
}
- (void)configDefaultImageName {
    self.takePictureImageName = @"takePicture.png";
    self.photoSelImageName = @"photo_sel_photoPickerVc.png";
    self.photoDefImageName = @"photo_def_photoPickerVc.png";
    self.photoNumberIconImageName = @"photo_number_icon.png";
    self.photoPreviewOriginDefImageName = @"preview_original_def.png";
    self.photoOriginDefImageName = @"photo_original_def.png";
    self.photoOriginSelImageName = @"photo_original_sel.png";
}
- (void)configDefaultBtnTitle {
    self.doneBtnTitleStr = [NSBundle tz_localizedStringForKey:@"Done"];
    self.cancelBtnTitleStr = [NSBundle tz_localizedStringForKey:@"Cancel"];
    self.previewBtnTitleStr = [NSBundle tz_localizedStringForKey:@"Preview"];
    self.fullImageBtnTitleStr = [NSBundle tz_localizedStringForKey:@"Full image"];
    self.settingBtnTitleStr = [NSBundle tz_localizedStringForKey:@"Setting"];
    self.processHintStr = [NSBundle tz_localizedStringForKey:@"Processing..."];
}
- (void)showAlertWithTitle:(NSString *)title {
    if (iOS8Later) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:[NSBundle tz_localizedStringForKey:@"OK"] style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [[[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:[NSBundle tz_localizedStringForKey:@"OK"] otherButtonTitles:nil, nil] show];
    }
}
- (void)showProgressHUD {
    if (!_progressHUD) {
        _progressHUD = [UIButton buttonWithType:UIButtonTypeCustom];
        [_progressHUD setBackgroundColor:[UIColor clearColor]];
        
        _HUDContainer = [[UIView alloc] init];
        _HUDContainer.frame = CGRectMake((self.view.tz_width - 120) / 2, (self.view.tz_height - 90) / 2, 120, 90);
        _HUDContainer.layer.cornerRadius = 8;
        _HUDContainer.clipsToBounds = YES;
        _HUDContainer.backgroundColor = [UIColor darkGrayColor];
        _HUDContainer.alpha = 0.7;
        
        _HUDIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _HUDIndicatorView.frame = CGRectMake(45, 15, 30, 30);
        
        _HUDLabel = [[UILabel alloc] init];
        _HUDLabel.frame = CGRectMake(0,40, 120, 50);
        _HUDLabel.textAlignment = NSTextAlignmentCenter;
        _HUDLabel.text = self.processHintStr;
        _HUDLabel.font = [UIFont systemFontOfSize:15];
        _HUDLabel.textColor = [UIColor whiteColor];
        
        [_HUDContainer addSubview:_HUDLabel];
        [_HUDContainer addSubview:_HUDIndicatorView];
        [_progressHUD addSubview:_HUDContainer];
    }
    [_HUDIndicatorView startAnimating];
    [[UIApplication sharedApplication].keyWindow addSubview:_progressHUD];
    
    // if over time, dismiss HUD automatic
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hideProgressHUD];
    });
}
- (void)hideProgressHUD {
    if (_progressHUD) {
        [_HUDIndicatorView stopAnimating];
        [_progressHUD removeFromSuperview];
    }
}
- (void)setMaxImagesCount:(NSInteger)maxImagesCount {
    _maxImagesCount = maxImagesCount;
    if (maxImagesCount > 1) {
        _showSelectBtn = YES;
        _allowCrop = NO;
    }
}
- (void)setShowSelectBtn:(BOOL)showSelectBtn {
    _showSelectBtn = showSelectBtn;
    // 多选模式下，不允许让showSelectBtn为NO
    if (!showSelectBtn && _maxImagesCount > 1) {
        _showSelectBtn = YES;
    }
}
- (void)setAllowCrop:(BOOL)allowCrop {
    _allowCrop = _maxImagesCount > 1 ? NO : allowCrop;
    if (allowCrop) { // 允许裁剪的时候，不能选原图和GIF
        self.allowPickingOriginalPhoto = NO;
        self.allowPickingGif = NO;
    }
}
- (void)setCircleCropRadius:(NSInteger)circleCropRadius {
    _circleCropRadius = circleCropRadius;
    _cropRect = CGRectMake(self.view.tz_width / 2 - circleCropRadius, self.view.tz_height / 2 - _circleCropRadius, _circleCropRadius * 2, _circleCropRadius * 2);
}

- (CGRect)cropRect {
    if (_cropRect.size.width > 0) {
        return _cropRect;
    }
    CGFloat cropViewWH = self.view.tz_width;
    return CGRectMake(0, (self.view.tz_height - self.view.tz_width) / 2, cropViewWH, cropViewWH);
}
- (void)setTimeout:(NSInteger)timeout {
    _timeout = timeout;
    if (timeout < 5) {
        _timeout = 5;
    } else if (_timeout > 60) {
        _timeout = 60;
    }
}
- (void)setColumnNumber:(NSInteger)columnNumber {
    _columnNumber = columnNumber;
    if (columnNumber <= 2) {
        _columnNumber = 2;
    } else if (columnNumber >= 6) {
        _columnNumber = 6;
    }
    
//    TZAlbumPickerController *albumPickerVc = [self.childViewControllers firstObject];
//    albumPickerVc.columnNumber = _columnNumber;
//    [TZImageManager manager].columnNumber = _columnNumber;
}
- (void)setMinPhotoWidthSelectable:(NSInteger)minPhotoWidthSelectable {
    _minPhotoWidthSelectable = minPhotoWidthSelectable;
    [HQImageManager manager].minPhotoWidthSelectable = minPhotoWidthSelectable;
}

- (void)setMinPhotoHeightSelectable:(NSInteger)minPhotoHeightSelectable {
    _minPhotoHeightSelectable = minPhotoHeightSelectable;
    [HQImageManager manager].minPhotoHeightSelectable = minPhotoHeightSelectable;
}

- (void)setHideWhenCanNotSelect:(BOOL)hideWhenCanNotSelect {
    _hideWhenCanNotSelect = hideWhenCanNotSelect;
    [HQImageManager manager].hideWhenCanNotSelect = hideWhenCanNotSelect;
}

- (void)setPhotoPreviewMaxWidth:(CGFloat)photoPreviewMaxWidth {
    _photoPreviewMaxWidth = photoPreviewMaxWidth;
    if (photoPreviewMaxWidth > 800) {
        _photoPreviewMaxWidth = 800;
    } else if (photoPreviewMaxWidth < 500) {
        _photoPreviewMaxWidth = 500;
    }
    [HQImageManager manager].photoPreviewMaxWidth = _photoPreviewMaxWidth;
}

- (void)setSelectedAssets:(NSMutableArray *)selectedAssets {
    _selectedAssets = selectedAssets;
    _selectedModels = [NSMutableArray array];
    for (id asset in selectedAssets) {
        HQAssetModel *model = [HQAssetModel modelWithAsset:asset type:HQAssetModelMediaTypePhoto];
        model.isSelected = YES;
        [_selectedModels addObject:model];
    }
}
- (void)setAllowPickingImage:(BOOL)allowPickingImage {
    _allowPickingImage = allowPickingImage;
    NSString *allowPickingImageStr = _allowPickingImage ? @"1" : @"0";
    [[NSUserDefaults standardUserDefaults] setObject:allowPickingImageStr forKey:@"tz_allowPickingImage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setAllowPickingVideo:(BOOL)allowPickingVideo {
    _allowPickingVideo = allowPickingVideo;
    NSString *allowPickingVideoStr = _allowPickingVideo ? @"1" : @"0";
    [[NSUserDefaults standardUserDefaults] setObject:allowPickingVideoStr forKey:@"tz_allowPickingVideo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)setSortAscendingByModificationDate:(BOOL)sortAscendingByModificationDate {
    _sortAscendingByModificationDate = sortAscendingByModificationDate;
    [HQImageManager manager].sortAscendingByModificationDate = sortAscendingByModificationDate;
}
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (iOS7Later) viewController.automaticallyAdjustsScrollViewInsets = NO;
    if (_timer) { [_timer invalidate]; _timer = nil;}
    [super pushViewController:viewController animated:animated];
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
- (void)settingBtnClick {
    if (iOS8Later) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    } else {
        NSURL *privacyUrl = [NSURL URLWithString:@"prefs:root=Privacy&path=PHOTOS"];
        if ([[UIApplication sharedApplication] canOpenURL:privacyUrl]) {
            [[UIApplication sharedApplication] openURL:privacyUrl];
        } else {
            NSString *message = [NSBundle tz_localizedStringForKey:@"Can not jump to the privacy settings page, please go to the settings page by self, thank you"];
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:[NSBundle tz_localizedStringForKey:@"Sorry"] message:message delegate:nil cancelButtonTitle:[NSBundle tz_localizedStringForKey:@"OK"] otherButtonTitles: nil];
            [alert show];
        }
    }
}

- (void)observeAuthrizationStatusChange {
    if ([[HQImageManager manager] authorizationStatusAuthorized]) {
        [_tipLabel removeFromSuperview];
        [_settingBtn removeFromSuperview];
        [_timer invalidate];
        _timer = nil;
        [self pushPhotoPickerVc];
    }
}
- (void)pushPhotoPickerVc{
    _didPushPhotoPickerVc = NO;
    // 判断是否需要push到照片选择页，如果_pushPhotoPickerVc为NO,则不push
    if ((!_didPushPhotoPickerVc && _pushPhotoPickerVc)) {
        [[HQImageManager manager] getCameraRoallAlbum:NO allPickingImage:YES complite:^(HQAlbumModel * model) {
            HQPhotoPickerViewController *photoPickerVC = [[HQPhotoPickerViewController alloc] init];
            photoPickerVC.model = model;
            photoPickerVC.isFirstAppear = YES;
            photoPickerVC.columnNumber = self.columnNumber;
            [self pushViewController:photoPickerVC animated:YES];
            _didPushPhotoPickerVc = YES;
        }];
    }
}
#pragma mark - Public

- (void)cancelButtonClick {
    if (self.autoDismiss) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self callDelegateMethod];
        }];
    } else {
        [self callDelegateMethod];
    }
}

- (void)callDelegateMethod {
    // 兼容旧版本
//    if ([self.pickerDelegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]) {
//        [self.pickerDelegate imagePickerControllerDidCancel:self];
//    }
//    if ([self.pickerDelegate respondsToSelector:@selector(tz_imagePickerControllerDidCancel:)]) {
//        [self.pickerDelegate tz_imagePickerControllerDidCancel:self];
//    }
//    if (self.imagePickerControllerDidCancelHandle) {
//        self.imagePickerControllerDidCancelHandle();
//    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end




@interface HQAlbumPickerController ()<UITableViewDataSource,UITableViewDelegate> {

    UITableView *_tableView;
    
}
@property (nonatomic, strong) NSMutableArray *albumArr;

@end

@implementation HQAlbumPickerController

- (instancetype)init{
    self = [super init];
    if (self) {

    }
    return self;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    HQPickerImageViewController *imagePickerVc = (HQPickerImageViewController *)self.navigationController;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = [NSBundle tz_localizedStringForKey:@"Photos"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:imagePickerVc.cancelBtnTitleStr style:UIBarButtonItemStylePlain target:imagePickerVc action:@selector(cancelButtonClick)];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle tz_localizedStringForKey:@"Back"] style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    HQPickerImageViewController *imagePickerVc = (HQPickerImageViewController *)self.navigationController;
    
    if (_albumArr) {
        for (HQAlbumModel *albumModel in _albumArr) {
            albumModel.selectedModels = imagePickerVc.selectedModels;
        }
        [_tableView reloadData];
    } else {
        [self configTableView];
    }
    if (imagePickerVc.allowTakePicture) {
        self.navigationItem.title = [NSBundle tz_localizedStringForKey:@"Photos"];
    } else if (imagePickerVc.allowPickingVideo) {
        self.navigationItem.title = [NSBundle tz_localizedStringForKey:@"Videos"];
    }
}
- (void)configTableView {
    HQPickerImageViewController *imagePickerVc = (HQPickerImageViewController *)self.navigationController;
    [[HQImageManager manager] getAllAlbum:NO allPickingImage:imagePickerVc.allowPickingImage complite:^(NSArray<HQAlbumModel *> *models) {
        _albumArr = [NSMutableArray arrayWithArray:models];
        for (HQAlbumModel *albumModel in _albumArr) {
            albumModel.selectedModels = imagePickerVc.selectedModels;
        }
        if (!_tableView) {
            CGFloat top = 0;
            CGFloat tableViewHeight = 0;
            if (self.navigationController.navigationBar.isTranslucent) {
                top = 44;
                if (iOS7Later) top += 20;
                tableViewHeight = self.view.tz_height - top;
            } else {
                CGFloat navigationHeight = 44;
                if (iOS7Later) navigationHeight += 20;
                tableViewHeight = self.view.tz_height - navigationHeight;
            }
            
            _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, top, self.view.tz_width, tableViewHeight) style:UITableViewStylePlain];
            _tableView.rowHeight = 90;
            _tableView.tableFooterView = [[UIView alloc] init];
            _tableView.dataSource = self;
            _tableView.delegate = self;
            [_tableView registerClass:[HQAlbumCell class] forCellReuseIdentifier:@"HQAlbumCell"];
            [self.view addSubview:_tableView];
        } else {
            [_tableView reloadData];
        }
    }];
}
#pragma mark - UITableViewDataSource && Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _albumArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HQAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HQAlbumCell"];
    HQPickerImageViewController *imagePickerVc = (HQPickerImageViewController *)self.navigationController;
    cell.selectedCountButton.backgroundColor = imagePickerVc.oKButtonTitleColorNormal;
    cell.model = _albumArr[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HQPhotoPickerViewController *photoPickerVc = [[HQPhotoPickerViewController alloc] init];
    photoPickerVc.columnNumber = self.columnNumber;
    HQAlbumModel *model = _albumArr[indexPath.row];
    photoPickerVc.isFirstAppear = YES;
    photoPickerVc.model = model;
    __weak typeof(self) weakSelf = self;
    [photoPickerVc setBackButtonClickHandle:^(HQAlbumModel *model) {
        [weakSelf.albumArr replaceObjectAtIndex:indexPath.row withObject:model];
    }];
    [self.navigationController pushViewController:photoPickerVc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
