//
//  HQImageManager.h
//  HQPickerImage
//
//  Created by GoodSrc on 2017/3/16.
//  Copyright © 2017年 GoodSrc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>


@class HQAlbumModel,HQAssetModel;


@class ALAsset;

@interface HQImageManager : NSObject

////PHCachingImageManager是PHImageManager的子类，主要用于缓存PHAsset，这样可以快速获取照片或视频。
@property (nonatomic,strong) PHCachingImageManager *cachingImageManager;

+ (instancetype)manager;

@property (nonatomic, assign) BOOL shouldFixOrientation;

/// Default is 600px / 默认600像素宽
@property (nonatomic, assign) CGFloat photoPreviewMaxWidth;

/// 默认4列, HQPhotoPickerController中的照片collectionView
@property (nonatomic, assign) NSInteger columnNumber;

/// 对照片排序，按修改时间升序，默认是YES。如果设置为NO,最新的照片会显示在最前面，内部的拍照按钮会排在第一个
@property (nonatomic, assign) BOOL sortAscendingByModificationDate;

/// 最小可选中的图片宽度，默认是0，小于这个宽度的图片不可选中
@property (nonatomic, assign) NSInteger minPhotoWidthSelectable;
@property (nonatomic, assign) NSInteger minPhotoHeightSelectable;
@property (nonatomic, assign) BOOL hideWhenCanNotSelect;



/// Return YES if Authorized 返回YES如果得到了授权
- (BOOL)authorizationStatusAuthorized;




/// Get Album 获得相册/相册数组
- (void)getCameraRoallAlbum:(BOOL)allPickingVodio allPickingImage:(BOOL)allPickImage complite:(void (^)(HQAlbumModel *))complite;
- (void)getAllAlbum:(BOOL)allPickingVodio allPickingImage:(BOOL)allPickImage complite:(void (^)(NSArray <HQAlbumModel *>*))complite;




/// Get Assets 获得Asset数组
- (void)getAssetsFromFetchResult:(id)result allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(NSArray<HQAssetModel *> *models))completion;
///  Get asset at index 获得下标为index的单个照片
///  if index beyond bounds, return nil in callback 如果索引越界, 在回调中返回 nil
- (void)getAssetFromFetchResult:(id)result atIndex:(NSInteger)index allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(HQAssetModel *))completion;


/// Get photo 获得照片
- (void)getPostImageWithAlbumModel:(HQAlbumModel *)model completion:(void (^)(UIImage *postImage))completion;

- (PHImageRequestID)getPhotoWithAsset:(id)asset completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded ,id identifier))completion;
- (PHImageRequestID)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded,id identifier))completion;
- (PHImageRequestID)getPhotoWithAsset:(id)asset completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded,id identifier))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed;
- (PHImageRequestID)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded,id identifier))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed;
/// Get full Image 获取原图
/// 该方法会先返回缩略图，再返回原图，如果info[PHImageResultIsDegradedKey] 为 YES，则表明当前返回的是缩略图，否则是原图。


- (void)getOriginalPhotoWithAsset:(id)asset completion:(void (^)(UIImage *photo,NSDictionary *info))completion;
- (void)getOriginalPhotoWithAsset:(id)asset newCompletion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion;
- (void)getOriginalPhotoDataWithAsset:(id)asset completion:(void (^)(NSData *data,NSDictionary *info,BOOL isDegraded))completion;

/// Save photo 保存照片
- (void)savePhotoWithImage:(UIImage *)image completion:(void (^)(NSError *error))completion;
////保存图片   返回图片信息  
- (void)NewSavePhotoWithImage:(UIImage *)image completion:(void (^)(UIImage *photo,NSDictionary *info, NSString *identifier))completion faild:(void (^)(NSError *error))faild;

/// Export video 导出视频
- (void)getVideoOutputPathWithAsset:(id)asset completion:(void (^)(NSString *outputPath))completion;

/// Get photo bytes 获得一组照片的大小
- (void)getPhotosBytesWithArray:(NSArray *)photos completion:(void (^)(NSString *totalBytes))completion;

/// Judge is a assets array contain the asset 判断一个assets数组是否包含这个asset
- (BOOL)isAssetsArray:(NSArray *)assets containAsset:(id)asset;

////获取  assets 的id 
- (NSString *)getAssetIdentifier:(id)asset;
- (BOOL)isCameraRollAlbum:(NSString *)albumName;

/// 修正图片转向
- (UIImage *)fixOrientation:(UIImage *)aImage;


/// 检查照片大小是否满足最小要求
- (BOOL)isPhotoSelectableWithAsset:(id)asset;
- (CGSize)photoSizeWithAsset:(id)asset;

@end
