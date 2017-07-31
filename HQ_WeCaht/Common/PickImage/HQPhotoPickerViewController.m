
//
//  HQPhotoPickerViewController.m
//  HQPickerImage
//
//  Created by GoodSrc on 2017/3/16.
//  Copyright © 2017年 GoodSrc. All rights reserved.
//

#import "HQPhotoPickerViewController.h"
#import "HQPickerImageViewController.h"
#import "HQPickerPreviewController.h"
#import "HQVideoPlayerController.h"
#import "HQGifPhotoPreviewController.h"
#import "HQAssetCell.h"
#import "HQAssetModel.h"




@interface HQPhotoPickerViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>{
    
    NSMutableArray *_models;        ////数据源
    UIButton *_previewButton;       ///预览按钮
    UIButton *_doneButton;          ///确认
    UIImageView *_numberImageView;  ///
    UILabel *_numberLabel;
    UIButton *_originalPhotoButton;
    UILabel *_originalPhotoLabel;
    
    BOOL _shouldScrollToBottom;
//    BOOL _showTakePhotoBtn;

}
@property CGRect previousPreheatRect;
@property (nonatomic, strong) HQCollectionView *collectionView;


@end
static CGSize AssetGridThumbnailSize;



@implementation HQPhotoPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    HQPickerImageViewController *tzImagePickerVc = (HQPickerImageViewController *)self.navigationController;
    _shouldScrollToBottom = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = _model.name;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:tzImagePickerVc.cancelBtnTitleStr style:UIBarButtonItemStylePlain target:tzImagePickerVc action:@selector(cancelButtonClick)];
//    _showTakePhotoBtn = (([[HQImageManager manager] isCameraRollAlbum:_model.name]) && tzImagePickerVc.allowTakePicture);
    if (!tzImagePickerVc.sortAscendingByModificationDate && _isFirstAppear && iOS8Later) {
        [[HQImageManager manager] getCameraRoallAlbum:tzImagePickerVc.allowPickingVideo allPickingImage:tzImagePickerVc.allowPickingImage complite:^(HQAlbumModel * model) {
            _model = model;
            _models = [NSMutableArray arrayWithArray:_model.models];
            [self initSubviews];

        }];
    }else{
        if ( !iOS8Later || _isFirstAppear) {
            [[HQImageManager manager] getAssetsFromFetchResult:_model.result allowPickingVideo:tzImagePickerVc.allowPickingVideo allowPickingImage:tzImagePickerVc.allowPickingImage completion:^(NSArray<HQAssetModel *> *models) {
                _models = [NSMutableArray arrayWithArray:models];
                [self initSubviews];
            }];
        } else {
            _models = [NSMutableArray arrayWithArray:_model.models];
            [self initSubviews];
        }
    }
}
- (void)initSubviews{
    [self checkSelectedModels];
    [self configCollectionView];
    [self configBottomToolBar];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.backButtonClickHandle) {
        self.backButtonClickHandle(_model);
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self scrollCollectionViewToBottom];
    CGFloat scale = 2.0;
    if ([UIScreen mainScreen].bounds.size.width > 600) {
        scale = 1.0;
    }
    CGSize cellSize = ((UICollectionViewFlowLayout *)_collectionView.collectionViewLayout).itemSize;
    AssetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (iOS8Later) {
         [self updateCachedAssets];
    }
}
- (void)checkSelectedModels {
    for (HQAssetModel *model in _models) {
        model.isSelected = NO;
        NSMutableArray *selectedAssets = [NSMutableArray array];
        HQPickerImageViewController *tzImagePickerVc = (HQPickerImageViewController *)self.navigationController;
        for (HQAssetModel *model in tzImagePickerVc.selectedModels) {
            [selectedAssets addObject:model.asset];
        }
        if ([[HQImageManager manager] isAssetsArray:selectedAssets containAsset:model.asset]) {
            model.isSelected = YES;
        }
    }
}
- (void)configCollectionView {
    HQPickerImageViewController *tzImagePickerVc = (HQPickerImageViewController *)self.navigationController;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat margin = 5;
    CGFloat itemWH = (self.view.tz_width - (self.columnNumber + 1) * margin) / self.columnNumber;
    layout.itemSize = CGSizeMake(itemWH, itemWH);
    layout.minimumInteritemSpacing = margin;
    layout.minimumLineSpacing = margin;
    
    CGFloat top = 0;
    CGFloat collectionViewHeight = 0;
    if (self.navigationController.navigationBar.isTranslucent) {
        top = 44;
        if (iOS7Later) top += 20;
        collectionViewHeight = tzImagePickerVc.showSelectBtn ? self.view.tz_height - 50 - top : self.view.tz_height - top;;
    } else {
        CGFloat navigationHeight = 44;
        if (iOS7Later) navigationHeight += 20;
        collectionViewHeight = tzImagePickerVc.showSelectBtn ? self.view.tz_height - 50 - navigationHeight : self.view.tz_height - navigationHeight;
    }
    
    _collectionView = [[HQCollectionView alloc] initWithFrame:CGRectMake(0, top, self.view.tz_width, collectionViewHeight) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.alwaysBounceHorizontal = NO;
    _collectionView.contentInset = UIEdgeInsetsMake(margin, margin, margin, margin);
    
//    if (_showTakePhotoBtn && tzImagePickerVc.allowTakePicture ) {
//        _collectionView.contentSize = CGSizeMake(self.view.tz_width, ((_model.count + self.columnNumber) / self.columnNumber) * self.view.tz_width);
//    } else {
//    }
    _collectionView.contentSize = CGSizeMake(self.view.tz_width, ((_model.count + self.columnNumber - 1) / self.columnNumber) * self.view.tz_width);
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[HQAssetCell class] forCellWithReuseIdentifier:@"TZAssetCell"];
    [_collectionView registerClass:[HQAssetCameraCell class] forCellWithReuseIdentifier:@"TZAssetCameraCell"];
}
- (void)configBottomToolBar {
    HQPickerImageViewController *tzImagePickerVc = (HQPickerImageViewController *)self.navigationController;
    if (!tzImagePickerVc.showSelectBtn) return;
    
    CGFloat yOffset = 0;
    if (self.navigationController.navigationBar.isTranslucent) {
        yOffset = self.view.tz_height - 50;
    } else {
        CGFloat navigationHeight = 44;
        if (iOS7Later) navigationHeight += 20;
        yOffset = self.view.tz_height - 50 - navigationHeight;
    }
    
    UIView *bottomToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, yOffset, self.view.tz_width, 50)];
    CGFloat rgb = 253 / 255.0;
    bottomToolBar.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1.0];
    
    CGFloat previewWidth = [tzImagePickerVc.previewBtnTitleStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} context:nil].size.width + 2;
    if (!tzImagePickerVc.allowPreview) {
        previewWidth = 0.0;
    }
    _previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _previewButton.frame = CGRectMake(10, 3, previewWidth, 44);
    _previewButton.tz_width = !tzImagePickerVc.showSelectBtn ? 0 : previewWidth;
    [_previewButton addTarget:self action:@selector(previewButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _previewButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_previewButton setTitle:tzImagePickerVc.previewBtnTitleStr forState:UIControlStateNormal];
    [_previewButton setTitle:tzImagePickerVc.previewBtnTitleStr forState:UIControlStateDisabled];
    [_previewButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_previewButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    _previewButton.enabled = tzImagePickerVc.selectedModels.count;
    
    if (tzImagePickerVc.allowPickingOriginalPhoto) {
        CGFloat fullImageWidth = [tzImagePickerVc.fullImageBtnTitleStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil].size.width;
        _originalPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _originalPhotoButton.frame = CGRectMake(CGRectGetMaxX(_previewButton.frame), self.view.tz_height - 50, fullImageWidth + 56, 50);
        _originalPhotoButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
        [_originalPhotoButton addTarget:self action:@selector(originalPhotoButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _originalPhotoButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_originalPhotoButton setTitle:tzImagePickerVc.fullImageBtnTitleStr forState:UIControlStateNormal];
        [_originalPhotoButton setTitle:tzImagePickerVc.fullImageBtnTitleStr forState:UIControlStateSelected];
        [_originalPhotoButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_originalPhotoButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [_originalPhotoButton setImage:[UIImage imageNamedFromMyBundle:tzImagePickerVc.photoOriginDefImageName] forState:UIControlStateNormal];
        [_originalPhotoButton setImage:[UIImage imageNamedFromMyBundle:tzImagePickerVc.photoOriginSelImageName] forState:UIControlStateSelected];
//        _originalPhotoButton.selected = _isSelectOriginalPhoto;
        _originalPhotoButton.enabled = tzImagePickerVc.selectedModels.count > 0;
        
        _originalPhotoLabel = [[UILabel alloc] init];
        _originalPhotoLabel.frame = CGRectMake(fullImageWidth + 46, 0, 80, 50);
        _originalPhotoLabel.textAlignment = NSTextAlignmentLeft;
        _originalPhotoLabel.font = [UIFont systemFontOfSize:16];
        _originalPhotoLabel.textColor = [UIColor blackColor];
//        if (_isSelectOriginalPhoto){
//            [self getSelectedPhotoBytes];
//        }
    }
    
    _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _doneButton.frame = CGRectMake(self.view.tz_width - 44 - 12, 3, 44, 44);
    _doneButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_doneButton addTarget:self action:@selector(doneButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_doneButton setTitle:tzImagePickerVc.doneBtnTitleStr forState:UIControlStateNormal];
    [_doneButton setTitle:tzImagePickerVc.doneBtnTitleStr forState:UIControlStateDisabled];
    [_doneButton setTitleColor:tzImagePickerVc.oKButtonTitleColorNormal forState:UIControlStateNormal];
    [_doneButton setTitleColor:tzImagePickerVc.oKButtonTitleColorDisabled forState:UIControlStateDisabled];
    _doneButton.enabled = tzImagePickerVc.selectedModels.count || tzImagePickerVc.alwaysEnableDoneBtn;
    
    _numberImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamedFromMyBundle:tzImagePickerVc.photoNumberIconImageName]];
    _numberImageView.frame = CGRectMake(self.view.tz_width - 56 - 28, 10, 30, 30);
    _numberImageView.hidden = tzImagePickerVc.selectedModels.count <= 0;
    _numberImageView.backgroundColor = [UIColor clearColor];
    
    _numberLabel = [[UILabel alloc] init];
    _numberLabel.frame = _numberImageView.frame;
    _numberLabel.font = [UIFont systemFontOfSize:15];
    _numberLabel.textColor = [UIColor whiteColor];
    _numberLabel.textAlignment = NSTextAlignmentCenter;
    _numberLabel.text = [NSString stringWithFormat:@"%zd",tzImagePickerVc.selectedModels.count];
    _numberLabel.hidden = tzImagePickerVc.selectedModels.count <= 0;
    _numberLabel.backgroundColor = [UIColor clearColor];
    
    UIView *divide = [[UIView alloc] init];
    CGFloat rgb2 = 222 / 255.0;
    divide.backgroundColor = [UIColor colorWithRed:rgb2 green:rgb2 blue:rgb2 alpha:1.0];
    divide.frame = CGRectMake(0, 0, self.view.tz_width, 1);
    
    [bottomToolBar addSubview:divide];
    [bottomToolBar addSubview:_previewButton];
    [bottomToolBar addSubview:_doneButton];
    [bottomToolBar addSubview:_numberImageView];
    [bottomToolBar addSubview:_numberLabel];
    [self.view addSubview:bottomToolBar];
    [self.view addSubview:_originalPhotoButton];
    [_originalPhotoButton addSubview:_originalPhotoLabel];
}

- (void)getSelectedPhotoBytes {
    HQPickerImageViewController *imagePickerVc = (HQPickerImageViewController *)self.navigationController;
    [[HQImageManager manager] getPhotosBytesWithArray:imagePickerVc.selectedModels completion:^(NSString *totalBytes) {
        _originalPhotoLabel.text = [NSString stringWithFormat:@"(%@)",totalBytes];
    }];
}
#pragma mark - Click Event

- (void)previewButtonClick {
    HQPickerPreviewController *photoPreviewVc = [[HQPickerPreviewController alloc] init];
    [self pushPhotoPrevireViewController:photoPreviewVc];
}

- (void)originalPhotoButtonClick {
    _originalPhotoButton.selected = !_originalPhotoButton.isSelected;
//    _isSelectOriginalPhoto = _originalPhotoButton.isSelected;
    _originalPhotoLabel.hidden = !_originalPhotoButton.isSelected;
//    if (_isSelectOriginalPhoto) [self getSelectedPhotoBytes];
}

- (void)doneButtonClick {
    HQPickerImageViewController *tzImagePickerVc = (HQPickerImageViewController *)self.navigationController;
    if (tzImagePickerVc.minImagesCount && tzImagePickerVc.selectedModels.count < tzImagePickerVc.minImagesCount) {
        NSString *title = [NSString stringWithFormat:[NSBundle tz_localizedStringForKey:@"Select a minimum of %zd photos"], tzImagePickerVc.minImagesCount];
        [tzImagePickerVc showAlertWithTitle:title];
        return;
    }
    [tzImagePickerVc showProgressHUD];
    NSMutableArray *photos = [NSMutableArray array];
    NSMutableArray *assets = [NSMutableArray array];
    NSMutableArray *infoArr = [NSMutableArray array];
    for (NSInteger i = 0; i < tzImagePickerVc.selectedModels.count; i++) {
        [photos addObject:@1];
        [assets addObject:@1];
        [infoArr addObject:@1];
    }
    
    __block BOOL havenotShowAlert = YES;
    [HQImageManager manager].shouldFixOrientation = YES;
    for (NSInteger i = 0; i < tzImagePickerVc.selectedModels.count; i++) {
        HQAssetModel *model = tzImagePickerVc.selectedModels[i];
        [[HQImageManager manager] getPhotoWithAsset:model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded, id identifier) {
            if (isDegraded){
                return;
            }
            if (photo) {
//                photo = [self scaleImage:photo toSize:CGSizeMake(photo.size.width, photo.size.height)];
               // [self scaleImage:photo toSize:CGSizeMake(tzImagePickerVc.photoWidth, (int)(tzImagePickerVc.photoWidth * photo.size.height / photo.size.width))];
                [photos replaceObjectAtIndex:i withObject:photo];
            }
            if (info) {
                [infoArr replaceObjectAtIndex:i withObject:info];
            }
            if (identifier) {
                [assets replaceObjectAtIndex:i withObject:identifier];
            }
            for (id item in photos){
                if ([item isKindOfClass:[NSNumber class]]) return;
            }
            if (havenotShowAlert) {
                [self didGetAllPhotos:photos assets:assets infoArr:infoArr];
            }
        } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
            // 如果图片正在从iCloud同步中,提醒用户
            if (progress < 1 && havenotShowAlert) {
                [tzImagePickerVc hideProgressHUD];
                [tzImagePickerVc showAlertWithTitle:[NSBundle tz_localizedStringForKey:@"Synchronizing photos from iCloud"]];
                havenotShowAlert = NO;
                return;
            }
        } networkAccessAllowed:YES];
    }
    if (tzImagePickerVc.selectedModels.count <= 0) {
        [self didGetAllPhotos:photos assets:assets infoArr:infoArr];
    }
}
- (void)pushPhotoPrevireViewController:(HQPickerPreviewController *)photoPreviewVc {
    __weak typeof(self) weakSelf = self;
//    photoPreviewVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
    [photoPreviewVc setBackButtonClickBlock:^(BOOL isSelectOriginalPhoto) {
//        weakSelf.isSelectOriginalPhoto = isSelectOriginalPhoto;
        [weakSelf.collectionView reloadData];
        [weakSelf refreshBottomToolBarStatus];
    }];
    [photoPreviewVc setDoneButtonClickBlock:^(BOOL isSelectOriginalPhoto) {
//        weakSelf.isSelectOriginalPhoto = isSelectOriginalPhoto;
        [weakSelf doneButtonClick];
    }];
    [photoPreviewVc setDoneButtonClickBlockCropMode:^(UIImage *cropedImage, id asset) {
        [weakSelf didGetAllPhotos:@[cropedImage] assets:@[asset] infoArr:nil];
    }];
    [self.navigationController pushViewController:photoPreviewVc animated:YES];
}

- (void)didGetAllPhotos:(NSArray *)photos assets:(NSArray *)assets infoArr:(NSArray *)infoArr {
    HQPickerImageViewController *tzImagePickerVc = (HQPickerImageViewController *)self.navigationController;
    [tzImagePickerVc hideProgressHUD];
    
    if (tzImagePickerVc.autoDismiss) {
        [self callDelegateMethodWithPhotos:photos assets:assets infoArr:infoArr];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self callDelegateMethodWithPhotos:photos assets:assets infoArr:infoArr];
    }
}
- (void)callDelegateMethodWithPhotos:(NSArray *)photos assets:(NSArray *)assets infoArr:(NSArray *)infoArr {
    HQPickerImageViewController *tzImagePickerVc = (HQPickerImageViewController *)self.navigationController;
    if ([tzImagePickerVc.pickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingPhotos:sourceImageUuids:)]) {
        [tzImagePickerVc.pickerDelegate imagePickerController:tzImagePickerVc didFinishPickingPhotos:photos sourceImageUuids:assets];
    }
    if (tzImagePickerVc.didFinishPickingPhotosHandle) {
        tzImagePickerVc.didFinishPickingPhotosHandle(photos,assets);
    }
    if (tzImagePickerVc.didFinishPickingPhotosWithInfosHandle) {
        tzImagePickerVc.didFinishPickingPhotosWithInfosHandle(photos,assets,infoArr);
    }
}

#pragma mark - UICollectionViewDataSource && Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _models.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // the cell lead to take a picture / 去拍照的cell
    HQPickerImageViewController *tzImagePickerVc = (HQPickerImageViewController *)self.navigationController;
    if (((tzImagePickerVc.sortAscendingByModificationDate && indexPath.row >= _models.count) || (!tzImagePickerVc.sortAscendingByModificationDate && indexPath.row == 0))) {
        HQAssetCameraCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TZAssetCameraCell" forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamedFromMyBundle:tzImagePickerVc.takePictureImageName];
        return cell;
    }
    // the cell dipaly photo or video / 展示照片或视频的cell
    HQAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TZAssetCell" forIndexPath:indexPath];
    cell.photoDefImageName = tzImagePickerVc.photoDefImageName;
    cell.photoSelImageName = tzImagePickerVc.photoSelImageName;
    HQAssetModel *model;
    if (tzImagePickerVc.sortAscendingByModificationDate ) {
        model = _models[indexPath.row];
    } else {
        model = _models[indexPath.row - 1];
    }
    cell.allowPickingGif = tzImagePickerVc.allowPickingGif;
    cell.model = model;
    cell.showSelectBtn = tzImagePickerVc.showSelectBtn;
    if (!tzImagePickerVc.allowPreview) {
        cell.selectPhotoButton.frame = cell.bounds;
    }
    
    __weak typeof(cell) weakCell = cell;
    __weak typeof(self) weakSelf = self;
    __weak typeof(_numberImageView.layer) weakLayer = _numberImageView.layer;
    cell.didSelectPhotoBlock = ^(BOOL isSelected) {
        HQPickerImageViewController *tzImagePickerVc = (HQPickerImageViewController *)weakSelf.navigationController;
        // 1. cancel select / 取消选择
        if (isSelected) {
            weakCell.selectPhotoButton.selected = NO;
            model.isSelected = NO;
            NSArray *selectedModels = [NSArray arrayWithArray:tzImagePickerVc.selectedModels];
            for (HQAssetModel *model_item in selectedModels) {
                if ([[[HQImageManager manager] getAssetIdentifier:model.asset] isEqualToString:[[HQImageManager manager] getAssetIdentifier:model_item.asset]]) {
                    [tzImagePickerVc.selectedModels removeObject:model_item];
                    break;
                }
            }
            [weakSelf refreshBottomToolBarStatus];
        } else {
            // 2. select:check if over the maxImagesCount / 选择照片,检查是否超过了最大个数的限制
            if (tzImagePickerVc.selectedModels.count < tzImagePickerVc.maxImagesCount) {
                weakCell.selectPhotoButton.selected = YES;
                model.isSelected = YES;
                [tzImagePickerVc.selectedModels addObject:model];
                [weakSelf refreshBottomToolBarStatus];
            } else {
                NSString *title = [NSString stringWithFormat:[NSBundle tz_localizedStringForKey:@"Select a maximum of %zd photos"], tzImagePickerVc.maxImagesCount];
                [tzImagePickerVc showAlertWithTitle:title];
            }
        }
        [UIView showOscillatoryAnimationWithLayer:weakLayer type:TZOscillatoryAnimationToSmaller];
    };
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    HQPickerImageViewController *tzImagePickerVc = (HQPickerImageViewController *)self.navigationController;
    NSInteger index = indexPath.row;
    if (!tzImagePickerVc.sortAscendingByModificationDate) {
        index = indexPath.row - 1;
    }
    HQAssetModel *model = _models[index];
    if (model.type == HQAssetModelMediaTypeVideo) {
        if (tzImagePickerVc.selectedModels.count > 0) {
            HQPickerImageViewController *imagePickerVc = (HQPickerImageViewController *)self.navigationController;
            [imagePickerVc showAlertWithTitle:[NSBundle tz_localizedStringForKey:@"Can not choose both video and photo"]];
        } else {
            HQVideoPlayerController *videoPlayerVc = [[HQVideoPlayerController alloc] init];
//            videoPlayerVc.model = model;
            [self.navigationController pushViewController:videoPlayerVc animated:YES];
        }
    } else if (model.type == HQAssetModelMediaTypePhotoGif && tzImagePickerVc.allowPickingGif) {
        if (tzImagePickerVc.selectedModels.count > 0) {
            HQPickerImageViewController *imagePickerVc = (HQPickerImageViewController *)self.navigationController;
            [imagePickerVc showAlertWithTitle:[NSBundle tz_localizedStringForKey:@"Can not choose both photo and GIF"]];
        } else {
            HQGifPhotoPreviewController *gifPreviewVc = [[HQGifPhotoPreviewController alloc] init];
//            gifPreviewVc.model = model;
            [self.navigationController pushViewController:gifPreviewVc animated:YES];
        }
    } else {
        HQPickerPreviewController *photoPreviewVc = [[HQPickerPreviewController alloc] init];
        photoPreviewVc.currentIndex = index;
        photoPreviewVc.models = _models;
        [self pushPhotoPrevireViewController:photoPreviewVc];
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (iOS8Later) {
         [self updateCachedAssets];
    }
}


#pragma mark - Private Method

- (void)refreshBottomToolBarStatus {
    HQPickerImageViewController *tzImagePickerVc = (HQPickerImageViewController *)self.navigationController;
    
    _previewButton.enabled = tzImagePickerVc.selectedModels.count > 0;
    _doneButton.enabled = tzImagePickerVc.selectedModels.count > 0 || tzImagePickerVc.alwaysEnableDoneBtn;
    
    _numberImageView.hidden = tzImagePickerVc.selectedModels.count <= 0;
    _numberLabel.hidden = tzImagePickerVc.selectedModels.count <= 0;
    _numberLabel.text = [NSString stringWithFormat:@"%zd",tzImagePickerVc.selectedModels.count];
    
    _originalPhotoButton.enabled = tzImagePickerVc.selectedModels.count > 0;
//    _originalPhotoButton.selected = (_isSelectOriginalPhoto && _originalPhotoButton.enabled);
    _originalPhotoLabel.hidden = (!_originalPhotoButton.isSelected);
//    if (_isSelectOriginalPhoto) [self getSelectedPhotoBytes];
}


/// Scale image / 缩放图片
- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size {
    if (image.size.width < size.width) {
        return image;
    }
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)scrollCollectionViewToBottom {
    HQPickerImageViewController *tzImagePickerVc = (HQPickerImageViewController *)self.navigationController;
    if (_shouldScrollToBottom && _models.count > 0 && tzImagePickerVc.sortAscendingByModificationDate) {
        NSInteger item = _models.count - 1;
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
        _shouldScrollToBottom = NO;
    }
}

- (void)reloadPhotoArray {
    HQPickerImageViewController *tzImagePickerVc = (HQPickerImageViewController *)self.navigationController;
    [[HQImageManager manager] getCameraRoallAlbum:tzImagePickerVc.allowPickingVideo allPickingImage:tzImagePickerVc.allowPickingImage complite:^(HQAlbumModel *model) {
        _model = model;
        [[HQImageManager manager] getAssetsFromFetchResult:_model.result allowPickingVideo:tzImagePickerVc.allowPickingVideo allowPickingImage:tzImagePickerVc.allowPickingImage completion:^(NSArray<HQAssetModel *> *models) {
            [tzImagePickerVc hideProgressHUD];
            HQAssetModel *assetModel;
            if (tzImagePickerVc.sortAscendingByModificationDate) {
                assetModel = [models lastObject];
                [_models addObject:assetModel];
            } else {
                assetModel = [models firstObject];
                [_models insertObject:assetModel atIndex:0];
            }
            
            if (tzImagePickerVc.maxImagesCount <= 1) {
                if (tzImagePickerVc.allowCrop) {
                    HQPickerPreviewController *photoPreviewVc = [[HQPickerPreviewController alloc] init];
//                    photoPreviewVc.currentIndex = _models.count - 1;
//                    photoPreviewVc.models = _models;
                    [self pushPhotoPrevireViewController:photoPreviewVc];
                } else {
                    [tzImagePickerVc.selectedModels addObject:assetModel];
                    [self doneButtonClick];
                }
                return;
            }
            if (tzImagePickerVc.selectedModels.count < tzImagePickerVc.maxImagesCount) {
                assetModel.isSelected = YES;
                [tzImagePickerVc.selectedModels addObject:assetModel];
                [self refreshBottomToolBarStatus];
            }
            [_collectionView reloadData];
            
            _shouldScrollToBottom = YES;
            [self scrollCollectionViewToBottom];
        }];
    }];
}
#pragma mark - Asset Caching

- (void)resetCachedAssets {
    [[HQImageManager manager].cachingImageManager stopCachingImagesForAllAssets];
    self.previousPreheatRect = CGRectZero;
}
- (void)updateCachedAssets {
    BOOL isViewVisible = [self isViewLoaded] && [[self view] window] != nil;
    if (!isViewVisible) { return; }
    
    // The preheat window is twice the height of the visible rect.
    CGRect preheatRect = _collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
    
    /*
     Check if the collection view is showing an area that is significantly
     different to the last preheated area.
     */
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    if (delta > CGRectGetHeight(_collectionView.bounds) / 3.0f) {
        
        // Compute the assets to start caching and to stop caching.
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenRect:self.previousPreheatRect andRect:preheatRect removedHandler:^(CGRect removedRect) {
            NSArray *indexPaths = [self aapl_indexPathsForElementsInRect:removedRect];
            [removedIndexPaths addObjectsFromArray:indexPaths];
        } addedHandler:^(CGRect addedRect) {
            NSArray *indexPaths = [self aapl_indexPathsForElementsInRect:addedRect];
            [addedIndexPaths addObjectsFromArray:indexPaths];
        }];
        
        NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
        
        // Update the assets the PHCachingImageManager is caching.
        [[HQImageManager manager].cachingImageManager startCachingImagesForAssets:assetsToStartCaching
                                                                       targetSize:AssetGridThumbnailSize
                                                                      contentMode:PHImageContentModeAspectFill
                                                                          options:nil];
        [[HQImageManager manager].cachingImageManager stopCachingImagesForAssets:assetsToStopCaching
                                                                      targetSize:AssetGridThumbnailSize
                                                                     contentMode:PHImageContentModeAspectFill
                                                                         options:nil];
        
        // Store the preheat rect to compare against in the future.
        self.previousPreheatRect = preheatRect;
    }
}
- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler {
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths {
    if (indexPaths.count == 0) { return nil; }
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        if (indexPath.item < _models.count) {
            HQAssetModel *model = _models[indexPath.item];
            [assets addObject:model.asset];
        }
    }
    
    return assets;
}

- (NSArray *)aapl_indexPathsForElementsInRect:(CGRect)rect {
    NSArray *allLayoutAttributes = [_collectionView.collectionViewLayout layoutAttributesForElementsInRect:rect];
    if (allLayoutAttributes.count == 0) { return nil; }
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:allLayoutAttributes.count];
    for (UICollectionViewLayoutAttributes *layoutAttributes in allLayoutAttributes) {
        NSIndexPath *indexPath = layoutAttributes.indexPath;
        [indexPaths addObject:indexPath];
    }
    return indexPaths;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end



@implementation HQCollectionView

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    if ( [view isKindOfClass:[UIControl class]]) {
        return YES;
    }
    return [super touchesShouldCancelInContentView:view];
}

@end
