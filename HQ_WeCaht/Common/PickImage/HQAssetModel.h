//
//  HQAssetModel.h
//  HQPickerImage
//
//  Created by GoodSrc on 2017/3/16.
//  Copyright © 2017年 GoodSrc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef enum : NSUInteger {
    
    HQAssetModelMediaTypePhoto = 0,   ///一般图片
    
    HQAssetModelMediaTypeLivePhoto,  ///动画图片
    
    HQAssetModelMediaTypePhotoGif,   ///GIF 图片
    
    HQAssetModelMediaTypeVideo,      ///视屏
    
    HQAssetModelMediaTypeAudio       ///音频
    
} HQAssetModelMediaType;



@interface HQAssetModel : NSObject

@property (nonatomic, strong) id asset;             ///< PHAsset or ALAsset
@property (nonatomic, assign) BOOL isSelected;      ///< The select status of a photo,

@property (nonatomic, assign) HQAssetModelMediaType type;
@property (nonatomic, copy) NSString *timeLength;

@property (nonatomic, assign) CGSize size;

@property (nonatomic, copy) NSString *burstIdentifier;

/// 用一个PHAsset/ALAsset实例，初始化一个照片模型
+ (instancetype)modelWithAsset:(id)asset type:(HQAssetModelMediaType)type;
+ (instancetype)modelWithAsset:(id)asset type:(HQAssetModelMediaType)type timeLength:(NSString *)timeLength;

@end



@class PHFetchResult;

///专辑
@interface HQAlbumModel : NSObject

///专辑名
@property (nonatomic, strong) NSString *name;
///数量
@property (nonatomic, assign) NSInteger count;
///< PHFetchResult<PHAsset> or ALAssetsGroup<ALAsset>
@property (nonatomic, strong) id result;

@property (nonatomic, strong) NSArray *models;
@property (nonatomic, strong) NSArray *selectedModels;
@property (nonatomic, assign) NSUInteger selectedCount;
@end




@interface TempModle : NSObject

///本地标识符
@property (nonatomic,copy) NSString *localIdentifier;
///image
@property (nonatomic,strong) UIImage *image;
///原始大小
@property (nonatomic,assign) CGSize origalSize;
///显示的size 
@property (nonatomic,assign) CGSize size;

@end
