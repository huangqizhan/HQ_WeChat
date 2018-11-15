//
//  HQFaceMoreCollectionViewCell.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/6.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HQFaceMorePageView.h"


@interface HQFaceMoreCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong) HQFaceMorePageView *pageView;
@property (nonatomic,strong) NSArray *moreFaceArray;

@end
