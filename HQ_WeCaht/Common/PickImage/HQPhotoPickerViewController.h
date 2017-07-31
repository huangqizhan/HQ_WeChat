//
//  HQPhotoPickerViewController.h
//  HQPickerImage
//
//  Created by GoodSrc on 2017/3/16.
//  Copyright © 2017年 GoodSrc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HQAlbumModel;

@interface HQPhotoPickerViewController : UIViewController


@property (nonatomic, assign) BOOL isFirstAppear;
@property (nonatomic, assign) NSInteger columnNumber;
@property (nonatomic, strong) HQAlbumModel *model;

@property (nonatomic, copy) void (^backButtonClickHandle)(HQAlbumModel *model);


@end






@interface HQCollectionView : UICollectionView

@end
