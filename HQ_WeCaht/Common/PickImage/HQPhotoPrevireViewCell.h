//
//  HQPhotoPrevireViewCell.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/17.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HQAssetModel,HQPickerProcessView,HQPhotoPrevireView;

@interface HQPhotoPrevireViewCell : UICollectionViewCell

@property (nonatomic, strong) HQAssetModel *model;
@property (nonatomic, copy) void (^singleTapGestureBlock)();
@property (nonatomic, copy) void (^imageProgressUpdateBlock)(double progress);

@property (nonatomic, strong) HQPhotoPrevireView *previewView;

@property (nonatomic, assign) BOOL allowCrop;
@property (nonatomic, assign) CGRect cropRect;

- (void)recoverSubviews;



@end




@interface HQPhotoPrevireView : UIView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *imageContainerView;
@property (nonatomic, strong) HQPickerProcessView *progressView;

@property (nonatomic, assign) BOOL allowCrop;
@property (nonatomic, assign) CGRect cropRect;

@property (nonatomic, strong) HQAssetModel *model;
@property (nonatomic, strong) id asset;
@property (nonatomic, copy) void (^singleTapGestureBlock)();
@property (nonatomic, copy) void (^imageProgressUpdateBlock)(double progress);

- (void)recoverSubviews;
@end
