//
//  HQPickerImageViewController.h
//  HQPickerImage
//
//  Created by GoodSrc on 2017/3/14.
//  Copyright © 2017年 GoodSrc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HQNavigationController.h"
#import "HQAssetModel.h"


@class HQAssetModel;

@protocol HQPickerImageViewControllerDelegate;

@interface HQPickerImageViewController : HQNavigationController

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount delegate:(id<HQPickerImageViewControllerDelegate>)delegate;

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount columnNumber:(NSInteger)columnNumber delegate:(id<HQPickerImageViewControllerDelegate>)delegate;

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount columnNumber:(NSInteger)columnNumber delegate:(id<HQPickerImageViewControllerDelegate>)delegate pushPhotoPickerVc:(BOOL)pushPhotoPickerVc;

/// This init method just for previewing photos / 用这个初始化方法以预览图片
- (instancetype)initWithSelectedAssets:(NSMutableArray *)selectedAssets selectedPhotos:(NSMutableArray *)selectedPhotos index:(NSInteger)index;


/// 超时时间，默认为15秒，当取图片时间超过15秒还没有取成功时，会自动dismiss HUD；
@property (nonatomic, assign) NSInteger timeout;
/// Default is 828px / 默认828像素宽
@property (nonatomic, assign) CGFloat photoWidth;

/// Default is 600px / 默认600像素宽
@property (nonatomic, assign) CGFloat photoPreviewMaxWidth;
/// Default is 9 / 默认最大可选9张图片
@property (nonatomic, assign) NSInteger maxImagesCount;
/// 最小照片必选张数,默认是0
@property (nonatomic, assign) NSInteger minImagesCount;

@property (nonatomic, weak) id<HQPickerImageViewControllerDelegate> pickerDelegate;

/// 让完成按钮一直可以点击，无须最少选择一张图片
@property (nonatomic, assign) BOOL alwaysEnableDoneBtn;


/// 对照片排序，按修改时间升序，默认是YES。如果设置为NO,最新的照片会显示在最前面，内部的拍照按钮会排在第一个
@property (nonatomic, assign) BOOL sortAscendingByModificationDate;
/// 默认为YES，如果设置为NO,原图按钮将隐藏，用户不能选择发送原图
@property (nonatomic, assign) BOOL allowPickingOriginalPhoto;

/// Default is YES, if set NO, user can't picking video.
/// 默认为YES，如果设置为NO,用户将不能选择视频
@property (nonatomic, assign) BOOL allowPickingVideo;

/// Default is NO, if set YES, user can picking gif image.
/// 默认为NO，如果设置为YES,用户可以选择gif图片
@property (nonatomic, assign) BOOL allowPickingGif;

/// Default is YES, if set NO, user can't picking image.
/// 默认为YES，如果设置为NO,用户将不能选择发送图片
@property(nonatomic, assign) BOOL allowPickingImage;

/// Default is YES, if set NO, user can't take picture.
/// 默认为YES，如果设置为NO,拍照按钮将隐藏,用户将不能选择照片
@property(nonatomic, assign) BOOL allowTakePicture;

/// Default is YES, if set NO, user can't preview photo.
/// 默认为YES，如果设置为NO,预览按钮将隐藏,用户将不能去预览照片
@property (nonatomic, assign) BOOL allowPreview;

/// Default is YES, if set NO, the picker don't dismiss itself.
/// 默认为YES，如果设置为NO, 选择器将不会自己dismiss
@property(nonatomic, assign) BOOL autoDismiss;

/// 用户选中过的图片数组
@property (nonatomic, strong) NSMutableArray *selectedAssets;
@property (nonatomic, strong) NSMutableArray<HQAssetModel *> *selectedModels;


/// 最小可选中的图片宽度，默认是0，小于这个宽度的图片不可选中
@property (nonatomic, assign) NSInteger minPhotoWidthSelectable;
@property (nonatomic, assign) NSInteger minPhotoHeightSelectable;

/// 隐藏不可以选中的图片，默认是NO，不推荐将其设置为YES
@property (nonatomic, assign) BOOL hideWhenCanNotSelect;

/// 单选模式,maxImagesCount为1时才生效
@property (nonatomic, assign) BOOL showSelectBtn;   ///< 在单选模式下，照片列表页中，显示选择按钮,默认为NO
@property (nonatomic, assign) BOOL allowCrop;       ///< 允许裁剪,默认为YES，showSelectBtn为NO才生效
@property (nonatomic, assign) CGRect cropRect;      ///< 裁剪框的尺寸
@property (nonatomic, assign) BOOL needCircleCrop;  ///< 需要圆形裁剪框
@property (nonatomic, assign) NSInteger circleCropRadius;  ///< 圆形裁剪框半径大小
@property (nonatomic, copy) void (^cropViewSettingBlock)(UIView *cropView);     ///< 自定义裁剪框的其他属性

- (void)showAlertWithTitle:(NSString *)title;
- (void)showProgressHUD;
- (void)hideProgressHUD;



@property (nonatomic, assign) NSInteger columnNumber;
@property (nonatomic, copy) NSString *doneBtnTitleStr;
@property (nonatomic, copy) NSString *cancelBtnTitleStr;
@property (nonatomic, copy) NSString *previewBtnTitleStr;
@property (nonatomic, copy) NSString *fullImageBtnTitleStr;
@property (nonatomic, copy) NSString *settingBtnTitleStr;
@property (nonatomic, copy) NSString *processHintStr;

@property (nonatomic, copy) NSString *takePictureImageName;
@property (nonatomic, copy) NSString *photoSelImageName;
@property (nonatomic, copy) NSString *photoDefImageName;
@property (nonatomic, copy) NSString *photoOriginSelImageName;
@property (nonatomic, copy) NSString *photoOriginDefImageName;
@property (nonatomic, copy) NSString *photoPreviewOriginDefImageName;
@property (nonatomic, copy) NSString *photoNumberIconImageName;


/// Appearance / 外观颜色 + 按钮文字
@property (nonatomic, strong) UIColor *oKButtonTitleColorNormal;
@property (nonatomic, strong) UIColor *oKButtonTitleColorDisabled;
@property (nonatomic, strong) UIColor *naviBgColor;
@property (nonatomic, strong) UIColor *naviTitleColor;
@property (nonatomic, strong) UIFont *naviTitleFont;
@property (nonatomic, strong) UIColor *barItemTextColor;
@property (nonatomic, strong) UIFont *barItemTextFont;

- (void)cancelButtonClick;

// 这个照片选择器会自己dismiss，当选择器dismiss的时候，会执行下面的handle
// 你也可以设置autoDismiss属性为NO，选择器就不会自己dismis了
// 如果isSelectOriginalPhoto为YES，表明用户选择了原图
// 你可以通过一个asset获得原图，通过这个方法：[[TZImageManager manager] getOriginalPhotoWithAsset:completion:]
// photos数组里的UIImage对象，默认是828像素宽，你可以通过设置photoWidth属性的值来改变它
@property (nonatomic, copy) void (^didFinishPickingPhotosHandle)(NSArray<UIImage *> *photos,NSArray *assets);
@property (nonatomic, copy) void (^didFinishPickingPhotosWithInfosHandle)(NSArray<UIImage *> *photos,NSArray *assets,NSArray<NSDictionary *> *infos);
@property (nonatomic, copy) void (^imagePickerControllerDidCancelHandle)();

// 如果用户选择了一个视频，下面的handle会被执行
// 如果系统版本大于iOS8，asset是PHAsset类的对象，否则是ALAsset类的对象
@property (nonatomic, copy) void (^didFinishPickingVideoHandle)(UIImage *coverImage,id asset);


// 如果用户选择了一个gif图片，下面的handle会被执行
@property (nonatomic, copy) void (^didFinishPickingGifImageHandle)(UIImage *animatedImage,id sourceAssets);


@end







@protocol HQPickerImageViewControllerDelegate <NSObject>

@optional




- (void)imagePickerController:(HQPickerImageViewController *)picker didFinishPickingImages:(NSArray<TempModle *> *)photos;


- (void)imagePickerController:(HQPickerImageViewController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceImageUuids:(NSArray *)imageUuids ;

- (void)imagePickerpPhotoControllerDidCancel:(HQPickerImageViewController *)picker;

// 如果系统版本大于iOS8，asset是PHAsset类的对象，否则是ALAsset类的对象 视频
- (void)imagePickerController:(HQPickerImageViewController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset;

// 如果用户选择了一个gif图片，下面的handle会被执行
- (void)imagePickerController:(HQPickerImageViewController *)picker didFinishPickingGifImage:(UIImage *)animatedImage sourceAssets:(id)asset;



@end


@interface HQAlbumPickerController : UIViewController
@property (nonatomic, assign) NSInteger columnNumber;


@end
