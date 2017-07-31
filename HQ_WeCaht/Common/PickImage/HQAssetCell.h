//
//  HQAssetCell.h
//  HQPickerImage
//
//  Created by GoodSrc on 2017/3/17.
//  Copyright © 2017年 GoodSrc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

typedef enum : NSUInteger {
    HQAssetCellTypePhoto = 0,
    HQAssetCellTypeLivePhoto,
    HQAssetCellTypePhotoGif,
    HQAssetCellTypeVideo,
    HQAssetCellTypeAudio,
}HQAssetCellType;


@class HQAssetModel,HQAlbumModel;

@interface HQAssetCell : UICollectionViewCell

@property (weak, nonatomic) UIButton *selectPhotoButton;
@property (nonatomic, strong) HQAssetModel *model;
@property (nonatomic, copy) void (^didSelectPhotoBlock)(BOOL);
@property (nonatomic, assign) HQAssetCellType type;
@property (nonatomic, assign) BOOL allowPickingGif;
@property (nonatomic, copy) NSString *representedAssetIdentifier;
@property (nonatomic, assign) PHImageRequestID imageRequestID;

@property (nonatomic, copy) NSString *photoSelImageName;
@property (nonatomic, copy) NSString *photoDefImageName;

@property (nonatomic, assign) BOOL showSelectBtn;



@end



@interface HQAlbumCell : UITableViewCell

@property (nonatomic, strong) HQAlbumModel *model;
@property (weak, nonatomic) UIButton *selectedCountButton;


@end





@interface HQAssetCameraCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;

@end







