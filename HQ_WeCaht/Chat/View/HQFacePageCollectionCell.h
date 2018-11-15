//
//  HQFacePageCollectionCell.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/1.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HQFacePageView.h"
#import "HQGifPageView.h"


@interface HQFacePageCollectionCell : UICollectionViewCell

@property (nonatomic,strong) NSArray *emojArray;

@property (nonatomic,strong) HQFacePageView *pageView;

@end




@interface HQGifPageCollectionCell : UICollectionViewCell


@property (nonatomic,strong) NSArray *emojArray;

@property (nonatomic,strong) HQGifPageView *pageView;

@end
