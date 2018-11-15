//
//  HQBroswerCollectionViewCell.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/4/12.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HQBroswerPrevireView,HQBroswerModel;

@interface HQBroswerCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong) HQBroswerPrevireView *previreView;

@property (nonatomic,weak) HQBroswerModel *broswerModel;

@property (nonatomic, copy) void (^singleTapGestureBlock)();


@end



@interface HQBroswerPrevireView : UIView

@property (nonatomic,weak) HQBroswerModel *broswerModel;
@property (nonatomic, assign) BOOL allowCrop;
@property (nonatomic, assign) CGRect cropRect;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, copy) void (^singleTapGestureBlock)();
@property (nonatomic, copy) void (^imageProgressUpdateBlock)(double progress);


@end
